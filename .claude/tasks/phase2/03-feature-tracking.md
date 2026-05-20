# Task 03: 자동 추적 (5개 지표) — Phase 2

> **선제 조건**: Task 01 완료 (Supabase 실 연결 — sessions, distractions 데이터 필요)
> **Claude Code 담당**: 5개 지표 정의, 엔티티/인터페이스 전체 코드, Supabase RPC 함수 설계, ADHD UX 규칙 적용 기준
> **Codex 담당**: 모든 코드 작성 (도메인 구현, RPC SQL, Provider, UI 위젯, 테스트 전부)
> **PRD ref**: Section 5-5 (Tracking), business.md
> **읽기**: `.claude/context/adhd-domain.md`
> **ADHD UX 원칙**: 90% 자동, 수동 입력 없음, "못 한 것" 절대 표시 금지

---

## 1. 설계 명세 (Claude Code)

### 1-1. 5개 지표 정의

| 지표 ID | 이름 | 계산 방법 | 표시 단위 |
|---------|------|----------|----------|
| `avg_initiation_time` | 착수 시간 | `AVG(session.started_at - task.created_at)` where task has session | 분 |
| `distraction_count` | 이탈 횟수 | `COUNT(distractions)` by type (7일) | 건, 타입별 분포 |
| `recovery_rate` | 복귀율 | `COUNT(returned_at IS NOT NULL) / COUNT(*)` | % |
| `completion_rate` | 완료율 | `COUNT(sessions WHERE status='completed') / COUNT(sessions)` | % |
| `focus_peak_hour` | 집중 피크 시간 | `sessions WHERE status='completed' GROUP BY EXTRACT(hour FROM started_at)` | 시간대 |

**표시 규칙 (RULE 07 엄격 적용)**:
- `avg_initiation_time`: "평균 {N}분 만에 시작했어요" — 느린 경우에도 부정적 표현 없음
- `distraction_count`: "이번 주 이탈 {N}번" (판단 없음, 타입별 파이 차트)
- `recovery_rate`: "{N}%가 돌아왔어요" (복귀 성공을 강조)
- `completion_rate`: "{N}개 완료했어요" (미완료 개수 절대 표시 금지)
- `focus_peak_hour`: "{시간}시~{시간+1}시에 가장 잘 집중해요"
- 데이터 없음: "아직 기록이 없어요. 오늘 첫 세션을 시작해볼까요?" (수치심 없음)

### 1-2. 도메인 엔티티

```dart
// lib/features/stats/domain/entities/tracking_stats.dart
@freezed
class TrackingStats with _$TrackingStats {
  const factory TrackingStats({
    /// null이면 데이터 없음
    Duration? avgInitiationTime,
    required int totalDistractions,
    required Map<String, int> distractionsByType, // 'urgent'|'impulsive'|'rest' → count
    /// 0.0 ~ 1.0, null이면 이탈 없었음
    double? recoveryRate,
    /// 0.0 ~ 1.0
    required double completionRate,
    required int totalSessionsCompleted,
    required int totalSessionsStarted,
    /// null이면 데이터 부족
    int? focusPeakHour,  // 0~23
    required DateTimeRange period,
  }) = _TrackingStats;
}

// lib/features/stats/domain/entities/focus_pattern.dart
@freezed
class FocusPattern with _$FocusPattern {
  const factory FocusPattern({
    required int hour,                // 0~23
    required int sessionsCompleted,
    required double avgCompletionRate,
  }) = _FocusPattern;
}
```

### 1-3. StatsRepository 인터페이스

```dart
// lib/features/stats/domain/repositories/stats_repository.dart
abstract interface class StatsRepository {
  /// 최근 N일 통합 지표 반환.
  Future<TrackingStats> getStats({
    required String userId,
    required int days, // 7 or 30
  });

  /// 시간대별 집중 패턴 (24개 데이터 포인트).
  Future<List<FocusPattern>> getFocusPatterns({
    required String userId,
    required int days,
  });
}
```

**UseCases**:

```dart
// lib/features/stats/domain/usecases/get_tracking_stats_usecase.dart
class GetTrackingStatsUseCase {
  const GetTrackingStatsUseCase(this._repository);
  final StatsRepository _repository;

  Future<TrackingStats> call({required String userId, int days = 7}) =>
      _repository.getStats(userId: userId, days: days);
}

// lib/features/stats/domain/usecases/get_focus_patterns_usecase.dart
class GetFocusPatternsUseCase {
  const GetFocusPatternsUseCase(this._repository);
  final StatsRepository _repository;

  Future<List<FocusPattern>> call({required String userId, int days = 30}) =>
      _repository.getFocusPatterns(userId: userId, days: days);
}
```

### 1-4. Supabase RPC 함수 설계

`supabase/migrations/20260518000010_stats_functions.sql`:

```sql
-- [CRITICAL FIX] p_user_id 파라미터 제거 — auth.uid() 내부 사용으로 RLS 우회 차단
-- 클라이언트는 임의 userId를 전달할 수 없음
CREATE OR REPLACE FUNCTION get_tracking_stats(
  p_days INTEGER DEFAULT 7
) RETURNS JSONB AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_since TIMESTAMPTZ := NOW() - (p_days || ' days')::INTERVAL;
  v_result JSONB;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT jsonb_build_object(
    'avg_initiation_seconds',
    (SELECT AVG(EXTRACT(EPOCH FROM (s.started_at - t.created_at)))
     FROM sessions s
     JOIN tasks t ON t.id = s.task_id
     WHERE s.user_id = v_user_id AND s.started_at >= v_since),

    'total_distractions',
    (SELECT COUNT(*) FROM distractions d
     JOIN sessions s ON s.id = d.session_id
     WHERE s.user_id = v_user_id AND d.occurred_at >= v_since),

    'distractions_by_type',
    (SELECT jsonb_object_agg(type, cnt)
     FROM (
       SELECT d.type, COUNT(*) as cnt
       FROM distractions d
       JOIN sessions s ON s.id = d.session_id
       WHERE s.user_id = v_user_id AND d.occurred_at >= v_since
       GROUP BY d.type
     ) sq),

    'recovery_count',
    (SELECT COUNT(*) FROM distractions d
     JOIN sessions s ON s.id = d.session_id
     WHERE s.user_id = v_user_id
       AND d.occurred_at >= v_since
       AND d.returned_at IS NOT NULL),

    'total_distraction_count',
    (SELECT COUNT(*) FROM distractions d
     JOIN sessions s ON s.id = d.session_id
     WHERE s.user_id = v_user_id AND d.occurred_at >= v_since),

    'sessions_completed',
    (SELECT COUNT(*) FROM sessions
     WHERE user_id = v_user_id
       AND started_at >= v_since
       AND status = 'completed'),

    'sessions_total',
    (SELECT COUNT(*) FROM sessions
     WHERE user_id = v_user_id AND started_at >= v_since)
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 시간대별 집중 패턴 함수
CREATE OR REPLACE FUNCTION get_focus_patterns(
  p_days INTEGER DEFAULT 30
) RETURNS TABLE(hour INTEGER, sessions_completed BIGINT, avg_completion_rate FLOAT) AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_since TIMESTAMPTZ := NOW() - (p_days || ' days')::INTERVAL;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  RETURN QUERY
  SELECT
    EXTRACT(hour FROM started_at)::INTEGER as hour,
    COUNT(*) FILTER (WHERE status = 'completed') as sessions_completed,
    COUNT(*) FILTER (WHERE status = 'completed')::FLOAT / NULLIF(COUNT(*), 0) as avg_completion_rate
  FROM sessions
  WHERE user_id = v_user_id AND started_at >= v_since
  GROUP BY EXTRACT(hour FROM started_at)
  ORDER BY hour;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 1-5. StatsNotifier 상태

```dart
@freezed
sealed class StatsUiState with _$StatsUiState {
  const factory StatsUiState.loading() = _Loading;
  const factory StatsUiState.loaded({
    required TrackingStats stats,
    required List<FocusPattern> focusPatterns,
    @Default(7) int selectedDays,
  }) = _Loaded;
  const factory StatsUiState.empty() = _Empty; // 데이터 없음
  const factory StatsUiState.error(String message) = _Error;
}
```

### 1-6. 에러 케이스

| 상황 | 처리 |
|------|------|
| 데이터 없음 (0 세션) | `StatsUiState.empty()` 표시 |
| RPC 호출 실패 | `StatsUiState.error` + 재시도 버튼 |
| 게스트 userId | empty 상태 (로컬 InMemory에서 집계 불가) |
| 집계 결과 null 필드 | null-safe 처리, 해당 카드 숨김 |
| division by zero (sessions_total=0) | completionRate=0.0 처리 |

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task03-tracking.md`:

```
Project: OwnUrTime Flutter
Context: Phase 2 Task 03 — 자동 추적 5개 지표.
신규 피처: lib/features/stats/ 생성.

## 주의사항
- RULE 07 엄격 적용: "못 한 것" 표시 금지
- 완료율 표시: "N개 완료" O, "N개 미완료" X
- 모든 문자열 ARB 키 사용

## 항목 1: 도메인 레이어
엔티티/인터페이스/UseCase를 설계 명세 코드 그대로 작성.

## 항목 2: StatsRemoteDataSource 구현
파일: lib/features/stats/data/datasources/stats_remote_datasource.dart
```dart
class SupabaseStatsDataSource {
  const SupabaseStatsDataSource(this._client);
  final SupabaseClient _client;

  // [CRITICAL FIX] p_user_id 파라미터 제거 — 서버에서 auth.uid() 자동 사용
  Future<Map<String, dynamic>> getRawStats(int days) async {
    final response = await _client.rpc(
      'get_tracking_stats',
      params: {'p_days': days},
    );
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getFocusPatterns(int days) async {
    final response = await _client.rpc(
      'get_focus_patterns',
      params: {'p_user_id': userId, 'p_days': days},
    );
    return (response as List).cast<Map<String, dynamic>>();
  }
}
```

## 항목 3: StatsRepositoryImpl
파일: lib/features/stats/data/repositories/stats_repository_impl.dart
- getRawStats 결과 → TrackingStats entity 매핑
- null 값 처리: avg_initiation_seconds가 null이면 avgInitiationTime = null
- completionRate: sessions_total=0이면 0.0
- getFocusPatterns → List<FocusPattern>

## 항목 4: StatsNotifier
파일: lib/features/stats/presentation/providers/stats_provider.dart
- build(): authProvider에서 userId 읽어 usecase 호출
- selectedDays 변경 메서드: setDays(int days) → 재조회
- 게스트이면 → StatsUiState.empty()

## 항목 5: StatsScreen
파일: lib/features/stats/presentation/screens/stats_screen.dart

레이아웃:
```
Scaffold(appBar: "나의 기록")
└── SingleChildScrollView
    ├── 기간 선택 (7일 | 30일 SegmentedButton)
    ├── StatCard (착수 시간)
    ├── StatCard (완료율)
    ├── StatCard (복귀율)
    ├── DistractionTypeChart (이탈 유형 파이 차트)
    └── FocusPeakCard (집중 피크 시간)
```

empty 상태: "아직 기록이 없어요. 오늘 첫 세션을 시작해볼까요!" + 시작 버튼

## 항목 6: StatCard 위젯
파일: lib/features/stats/presentation/widgets/stat_card.dart
```dart
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, this.subtitle});
  final String label;
  final String value;
  final String? subtitle;
}
```
디자인: 카드 배경, label(caption), value(headline), subtitle(body2)

## 항목 7: DistractionTypeChart 위젯
파일: lib/features/stats/presentation/widgets/distraction_type_chart.dart
<!-- [FIX] 의존성 추가 전 사용자 승인 필요 — 구현 시작 전 확인 -->
- `fl_chart` 패키지 PieChart 사용 (pubspec에 추가, 사용자 승인 후)
- urgent/impulsive/rest 3가지 색상
- 중앙: 총 이탈 횟수
- 범례: 아이콘 + 타입명 + 건수

## 항목 8: FocusPeakCard 위젯
파일: lib/features/stats/presentation/widgets/focus_peak_card.dart
- focusPeakHour가 null이면 숨김
- "{hour}시~{hour+1}시에 가장 잘 집중해요" 텍스트
- 24시간 막대 그래프 (fl_chart BarChart) — completedSessions 기준

## 항목 9: GoRouter에 /stats 라우트 추가
파일: lib/core/router/app_router.dart
- /stats 추가
- TaskListScreen AppBar에 stats 아이콘 버튼 추가

## 항목 10: SQL 마이그레이션 파일
- supabase/migrations/20260518000010_stats_functions.sql (설계 명세 그대로)

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과
```

### 2-2. 구현 파일 목록

| 파일 | 담당 |
|------|------|
| `lib/features/stats/domain/entities/tracking_stats.dart` | Codex |
| `lib/features/stats/domain/entities/focus_pattern.dart` | Codex |
| `lib/features/stats/domain/repositories/stats_repository.dart` | Codex |
| `lib/features/stats/domain/usecases/get_tracking_stats_usecase.dart` | Codex |
| `lib/features/stats/domain/usecases/get_focus_patterns_usecase.dart` | Codex |
| `lib/features/stats/data/datasources/stats_remote_datasource.dart` | Codex |
| `lib/features/stats/data/repositories/stats_repository_impl.dart` | Codex |
| `lib/features/stats/data/providers/stats_providers.dart` | Codex |
| `lib/features/stats/presentation/providers/stats_provider.dart` | Codex |
| `lib/features/stats/presentation/screens/stats_screen.dart` | Codex |
| `lib/features/stats/presentation/widgets/stat_card.dart` | Codex |
| `lib/features/stats/presentation/widgets/distraction_type_chart.dart` | Codex |
| `lib/features/stats/presentation/widgets/focus_peak_card.dart` | Codex |
| `lib/core/router/app_router.dart` | Codex (/stats 추가) |
| `supabase/migrations/20260518000010_stats_functions.sql` | Codex |
| `pubspec.yaml` | Codex (fl_chart 추가) |

---

## 3. 테스트 명세

### `test/features/stats/domain/get_tracking_stats_usecase_test.dart`

```
TC-01: 정상 데이터 반환
  setup: FakeStatsRepo.getStats() → TrackingStats(completionRate: 0.8, ...)
  기대: usecase() returns TrackingStats

TC-02: 데이터 없음 (0 세션)
  setup: FakeStatsRepo.getStats() → TrackingStats(totalSessionsStarted: 0, completionRate: 0.0)
  기대: usecase() returns TrackingStats(totalSessionsStarted: 0)
```

### `test/features/stats/presentation/stats_notifier_test.dart`

```
TC-03: 게스트 → empty 상태
  setup: authProvider.state = AuthState.guest()
  기대: StatsUiState.empty()

TC-04: 인증 + 데이터 있음 → loaded
  setup: authProvider.state = authenticated, FakeRepo.getStats → stats
  기대: StatsUiState.loaded(stats: ...)

TC-05: setDays(30) → 재조회
  setup: 초기 7일 loaded 상태
  setDays(30) 호출
  기대: FakeRepo.getStats(days: 30) 호출됨
```

### `test/features/stats/data/stats_repository_impl_test.dart`

```
TC-06: avg_initiation_seconds null → avgInitiationTime null
  setup: raw = {'avg_initiation_seconds': null, ...}
  기대: TrackingStats(avgInitiationTime: null)

TC-07: sessions_total=0 → completionRate=0.0 (division by zero 없음)
  setup: raw = {'sessions_completed': 0, 'sessions_total': 0}
  기대: TrackingStats(completionRate: 0.0)

TC-08: distractions_by_type null → 빈 Map
  setup: raw = {'distractions_by_type': null}
  기대: TrackingStats(distractionsByType: {})
```

---

## 4. l10n 추가 (Codex)

`app_ko.arb`:
```json
"statsTitle": "나의 기록",
"stats7Days": "7일",
"stats30Days": "30일",
"statsInitiationTimeLabel": "착수 시간",
"statsInitiationTimeValue": "평균 {minutes}분 만에 시작했어요",
"@statsInitiationTimeValue": {"placeholders": {"minutes": {"type": "int"}}},
"statsCompletionLabel": "세션 완료",
"statsCompletionValue": "{count}개 완료했어요",
"@statsCompletionValue": {"placeholders": {"count": {"type": "int"}}},
"statsRecoveryLabel": "복귀율",
"statsRecoveryValue": "{percent}%가 돌아왔어요",
"@statsRecoveryValue": {"placeholders": {"percent": {"type": "int"}}},
"statsDistractionLabel": "이탈 기록",
"statsDistractionTotal": "이번 기간 {count}번",
"@statsDistractionTotal": {"placeholders": {"count": {"type": "int"}}},
"statsFocusPeakLabel": "집중 피크",
"statsFocusPeakValue": "{hour}시~{nextHour}시에 가장 잘 집중해요",
"@statsFocusPeakValue": {"placeholders": {"hour": {"type": "int"}, "nextHour": {"type": "int"}}},
"statsEmptyMessage": "아직 기록이 없어요. 오늘 첫 세션을 시작해볼까요!",
"statsDistractionUrgent": "긴급한 일",
"statsDistractionImpulsive": "충동적 이탈",
"statsDistractionRest": "휴식"
```

---

## 5. Done When

- [ ] 7일 이상 세션 데이터로 5개 지표 모두 표시됨
- [ ] "미완료" "못 한" 등 부정 표현 코드에 없음 (grep 확인)
- [ ] 데이터 없음 → empty 상태 표시 (수치심 없는 메시지)
- [ ] 7일/30일 전환 → 지표 재계산됨
- [ ] `supabase db reset` 통과 (stats 함수 포함)
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` TC-01~TC-08 전체 통과
