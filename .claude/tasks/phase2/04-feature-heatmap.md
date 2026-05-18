# Task 04: 히트맵 — Phase 2

> **선제 조건**: Task 01 완료 (sessions 데이터), Task 03 완료 (stats 피처 폴더 존재)
> **Claude Code 담당**: 히트맵 데이터 모델 설계, 색상 강도 로직 설계, ADHD UX 원칙 적용 기준
> **Codex 담당**: 모든 코드 작성 (위젯, 데이터 집계, GoRouter 통합, 테스트 전부)
> **PRD ref**: business.md (Free Tier: Basic heatmap), Section 5-5
> **ADHD UX 원칙**: "채워진 날만 강조", 빈 날은 회색 중립 (수치심 없음)

---

## 1. 설계 명세 (Claude Code)

### 1-1. HeatmapDay 엔티티

```dart
// lib/features/stats/domain/entities/heatmap_day.dart
@freezed
class HeatmapDay with _$HeatmapDay {
  const factory HeatmapDay({
    required DateTime date,
    required int sessionsCompleted,    // 0 이상
    required int totalFocusMinutes,   // 완료 세션 합산 분
  }) = _HeatmapDay;

  /// 활동이 있는 날인지 (히트맵 강조 기준)
  bool get hasActivity => sessionsCompleted > 0;
}
```

### 1-2. 색상 강도 매핑 (설계 기준)

```
sessionsCompleted = 0  → Color(0xFFEEEEEE)       // 중립 회색
sessionsCompleted = 1  → brandColor.withOpacity(0.25)
sessionsCompleted = 2  → brandColor.withOpacity(0.50)
sessionsCompleted = 3  → brandColor.withOpacity(0.75)
sessionsCompleted >= 4 → brandColor.withOpacity(1.00)
```

브랜드 컬러는 `AppTheme.primaryColor` 사용.

### 1-3. HeatmapRepository 인터페이스

```dart
// lib/features/stats/domain/repositories/heatmap_repository.dart
abstract interface class HeatmapRepository {
  /// 최근 weeks 주의 일별 세션 집계.
  /// 오늘 기준 과거 방향으로 weeks*7 개 HeatmapDay 반환.
  Future<List<HeatmapDay>> getRecentWeeks({
    required String userId,
    required int weeks,  // 기본 8주
  });

  /// 특정 날짜의 세션 요약 목록 (탭 시 표시용).
  Future<List<SessionSummary>> getDayDetail({
    required String userId,
    required DateTime date,
  });
}

// 탭 상세용 세션 요약
@freezed
class SessionSummary with _$SessionSummary {
  const factory SessionSummary({
    required String sessionId,
    required String taskTitle,
    required DateTime startedAt,
    required DateTime? completedAt,
    required int focusMinutes,
  }) = _SessionSummary;
}
```

**UseCase**:

```dart
// lib/features/stats/domain/usecases/get_heatmap_usecase.dart
class GetHeatmapUseCase {
  const GetHeatmapUseCase(this._repository);
  final HeatmapRepository _repository;

  Future<List<HeatmapDay>> call({required String userId, int weeks = 8}) =>
      _repository.getRecentWeeks(userId: userId, weeks: weeks);
}

// lib/features/stats/domain/usecases/get_day_detail_usecase.dart
class GetDayDetailUseCase {
  const GetDayDetailUseCase(this._repository);
  final HeatmapRepository _repository;

  Future<List<SessionSummary>> call({
    required String userId,
    required DateTime date,
  }) => _repository.getDayDetail(userId: userId, date: date);
}
```

### 1-4. Supabase 집계 SQL

`supabase/migrations/20260518000011_heatmap_functions.sql`:

```sql
-- [CRITICAL FIX] p_user_id 파라미터 제거 — auth.uid() 내부 사용으로 RLS 우회 차단
CREATE OR REPLACE FUNCTION get_heatmap_data(
  p_weeks INTEGER DEFAULT 8
) RETURNS TABLE(
  date DATE,
  sessions_completed BIGINT,
  total_focus_minutes BIGINT
) AS $$
DECLARE
  v_user_id UUID := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  RETURN QUERY
  SELECT
    DATE(started_at) as date,
    COUNT(*) FILTER (WHERE status = 'completed') as sessions_completed,
    COALESCE(SUM(
      CASE WHEN status = 'completed'
        THEN EXTRACT(EPOCH FROM (completed_at - started_at)) / 60
        ELSE 0
      END
    ), 0)::BIGINT as total_focus_minutes
  FROM sessions
  WHERE user_id = v_user_id
    AND started_at >= NOW() - (p_weeks * 7 || ' days')::INTERVAL
  GROUP BY DATE(started_at)
  ORDER BY date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 특정 날짜 세션 상세
CREATE OR REPLACE FUNCTION get_day_sessions(
  p_date DATE
) RETURNS TABLE(
  session_id UUID,
  task_title TEXT,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  focus_minutes INTEGER
) AS $$
DECLARE
  v_user_id UUID := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  RETURN QUERY
  SELECT
    s.id,
    COALESCE(t.title, '제목 없음') as task_title,
    s.started_at,
    s.completed_at,
    CASE WHEN s.completed_at IS NOT NULL
      THEN EXTRACT(EPOCH FROM (s.completed_at - s.started_at))::INTEGER / 60
      ELSE 0
    END as focus_minutes
  FROM sessions s
  LEFT JOIN tasks t ON t.id = s.task_id
  WHERE s.user_id = v_user_id
    AND DATE(s.started_at) = p_date
    AND s.status = 'completed'
  ORDER BY s.started_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 1-5. HeatmapNotifier 상태

```dart
@freezed
sealed class HeatmapUiState with _$HeatmapUiState {
  const factory HeatmapUiState.loading() = _Loading;
  const factory HeatmapUiState.loaded({
    required List<HeatmapDay> days,
    DateTime? selectedDate,            // null = 선택 없음
    @Default([]) List<SessionSummary> selectedDaySessions,
    @Default(false) bool isDayDetailLoading,
  }) = _Loaded;
  const factory HeatmapUiState.empty() = _Empty;
  const factory HeatmapUiState.error(String message) = _Error;
}
```

**Notifier 동작**:
```
build() → getHeatmapUseCase() → loaded 또는 empty (모든 일수 sessionsCompleted=0)
selectDay(date) →
  state = loaded(selectedDate: date, isDayDetailLoading: true)
  getDayDetailUseCase(date) →
  state = loaded(selectedDaySessions: result, isDayDetailLoading: false)
```

### 1-6. 에러 케이스

| 상황 | 처리 |
|------|------|
| 모든 날 세션 없음 | `HeatmapUiState.empty()` |
| RPC 실패 | `HeatmapUiState.error` + 재시도 버튼 |
| 탭 상세 로드 실패 | 상세 영역만 에러 표시, 히트맵 유지 |
| 게스트 userId | empty 상태 |

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task04-heatmap.md`:

```
Project: OwnUrTime Flutter
Context: Phase 2 Task 04 — 히트맵 위젯.
기존 lib/features/stats/ 피처에 통합.

## 주의사항
- 빈 날(sessionsCompleted=0): 회색 중립 처리 (강조 없음)
- "공백", "빈 날" 등 부정적 개념 UI에 표현 금지
- 탭 상세: 완료한 세션만 표시 (abandoned 세션 표시 금지)

## 항목 1: 도메인 레이어
설계 명세 엔티티/인터페이스/UseCase 그대로 작성.
추가 파일:
- lib/features/stats/domain/entities/heatmap_day.dart
- lib/features/stats/domain/entities/session_summary.dart
- lib/features/stats/domain/repositories/heatmap_repository.dart
- lib/features/stats/domain/usecases/get_heatmap_usecase.dart
- lib/features/stats/domain/usecases/get_day_detail_usecase.dart

## 항목 2: SupabaseHeatmapDataSource
파일: lib/features/stats/data/datasources/heatmap_remote_datasource.dart
```dart
class SupabaseHeatmapDataSource {
  const SupabaseHeatmapDataSource(this._client);
  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getHeatmapData(String userId, int weeks) async {
    final response = await _client.rpc(
      'get_heatmap_data',
      params: {'p_user_id': userId, 'p_weeks': weeks},
    );
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getDaySessions(String userId, DateTime date) async {
    final response = await _client.rpc(
      'get_day_sessions',
      params: {'p_user_id': userId, 'p_date': date.toIso8601String().substring(0, 10)},
    );
    return (response as List).cast<Map<String, dynamic>>();
  }
}
```

## 항목 3: HeatmapRepositoryImpl
파일: lib/features/stats/data/repositories/heatmap_repository_impl.dart
- RPC 결과 → List<HeatmapDay> 매핑
- 빠진 날짜(세션 없음) 자동 채우기: weeks*7일 범위의 모든 날짜 생성 후 RPC 결과 병합

날짜 채우기 로직:
<!-- [FIX] DateTime.now() → DateTime.now().toUtc() 사용 — 로컬 시간은 timezone 경계에서 날짜 버킷 불일치 발생 -->
```dart
final allDays = List.generate(weeks * 7, (i) {
  final utcNow = DateTime.now().toUtc();
  final date = utcNow.subtract(Duration(days: weeks * 7 - 1 - i));
  return DateTime.utc(date.year, date.month, date.day);
});
final filled = allDays.map((date) {
  final found = rpcResult.firstWhere(
    (d) => isSameDay(d.date, date),
    orElse: () => HeatmapDay(date: date, sessionsCompleted: 0, totalFocusMinutes: 0),
  );
  return found;
}).toList();
```

## 항목 4: HeatmapNotifier
파일: lib/features/stats/presentation/providers/heatmap_provider.dart
동작: 설계 명세 그대로 구현.

## 항목 5: HeatmapWidget (메인 위젯)
파일: lib/features/stats/presentation/widgets/heatmap_widget.dart

레이아웃:
```
Column
├── Row: 월 표시 + "최근 {weeks}주" 레이블
├── HeatmapGridView (GridView.builder, crossAxisCount: 7)
│   └── HeatmapDayCell * (weeks*7)개
└── DayDetailBottomSheet (selectedDate != null일 때)
```

GridView 설정:
- crossAxisCount: 7 (요일별)
- aspectRatio: 1.0 (정사각형 셀)
- 간격: 2px

## 항목 6: HeatmapDayCell 위젯
파일: lib/features/stats/presentation/widgets/heatmap_day_cell.dart
```dart
class HeatmapDayCell extends StatelessWidget {
  const HeatmapDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });
  final HeatmapDay day;
  final bool isSelected;
  final VoidCallback onTap;

  Color _cellColor(BuildContext context) {
    if (day.sessionsCompleted == 0) return const Color(0xFFEEEEEE);
    final base = Theme.of(context).colorScheme.primary;
    return switch (day.sessionsCompleted) {
      1 => base.withOpacity(0.25),
      2 => base.withOpacity(0.50),
      3 => base.withOpacity(0.75),
      _ => base,
    };
  }
}
```
- 선택 상태: 테두리 강조 (Border.all(color: primary, width: 2))
- GestureDetector onTap → notifier.selectDay(day.date)

## 항목 7: DayDetailSheet 위젯
파일: lib/features/stats/presentation/widgets/heatmap_day_detail_sheet.dart
BottomSheet:
- 날짜 표시: "M월 D일"
- 세션 목록 (SessionSummary 기반): taskTitle + focusMinutes + 시간
- 세션 없음: 표시 안 함 (빈 날 탭 시 sheet 미표시)
- 로딩 중: CircularProgressIndicator

## 항목 8: StatsScreen에 HeatmapWidget 통합
파일: lib/features/stats/presentation/screens/stats_screen.dart
기존 StatsScreen 상단에 HeatmapWidget 추가
(Task 03에서 만든 파일)

## 항목 9: SQL 마이그레이션
- supabase/migrations/20260518000011_heatmap_functions.sql (설계 명세 그대로)

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과
```

### 2-2. 구현 파일 목록

| 파일 | 담당 |
|------|------|
| `lib/features/stats/domain/entities/heatmap_day.dart` | Codex |
| `lib/features/stats/domain/entities/session_summary.dart` | Codex |
| `lib/features/stats/domain/repositories/heatmap_repository.dart` | Codex |
| `lib/features/stats/domain/usecases/get_heatmap_usecase.dart` | Codex |
| `lib/features/stats/domain/usecases/get_day_detail_usecase.dart` | Codex |
| `lib/features/stats/data/datasources/heatmap_remote_datasource.dart` | Codex |
| `lib/features/stats/data/repositories/heatmap_repository_impl.dart` | Codex |
| `lib/features/stats/presentation/providers/heatmap_provider.dart` | Codex |
| `lib/features/stats/presentation/widgets/heatmap_widget.dart` | Codex |
| `lib/features/stats/presentation/widgets/heatmap_day_cell.dart` | Codex |
| `lib/features/stats/presentation/widgets/heatmap_day_detail_sheet.dart` | Codex |
| `lib/features/stats/presentation/screens/stats_screen.dart` | Codex (히트맵 추가) |
| `supabase/migrations/20260518000011_heatmap_functions.sql` | Codex |

---

## 3. 테스트 명세

### `test/features/stats/data/heatmap_repository_impl_test.dart`

```
TC-01: 빠진 날짜 자동 채우기
  setup: RPC 결과 = [{date: 2026-05-10, sessionsCompleted: 2}] (weeks=1)
  기대: 반환 리스트 7개, 2026-05-10은 sessionsCompleted=2, 나머지는 0

TC-02: 모든 날 데이터 없음 → 7개 HeatmapDay(sessionsCompleted: 0)
  setup: RPC 결과 = []
  기대: 7개 모두 sessionsCompleted=0

TC-03: getDayDetail → 완료 세션만 반환
  setup: RPC 결과 2개 (completed=1, abandoned=0) → completed 1개만
  기대: List 길이 1
```

### `test/features/stats/presentation/heatmap_notifier_test.dart`

```
TC-04: build → loaded 상태
  setup: FakeRepo.getRecentWeeks() → [HeatmapDay * 7]
  기대: HeatmapUiState.loaded(days: [...])

TC-05: selectDay → isDayDetailLoading=true → loaded(selectedDaySessions)
  selectDay(date) 호출
  기대: 중간에 isDayDetailLoading=true
  기대: 최종 isDayDetailLoading=false, selectedDaySessions=[...]

TC-06: 게스트 → empty
  setup: authProvider = guest
  기대: HeatmapUiState.empty()
```

### `test/features/stats/presentation/heatmap_day_cell_test.dart`

```
TC-07: sessionsCompleted=0 → 회색 배경 (Color 0xFFEEEEEE)
TC-08: sessionsCompleted=2 → opacity 0.50 배경
TC-09: 탭 → onTap callback 호출됨
```

---

## 4. l10n 추가 (Codex)

`app_ko.arb`:
```json
"heatmapTitle": "활동 기록",
"heatmapRecentWeeks": "최근 {weeks}주",
"@heatmapRecentWeeks": {"placeholders": {"weeks": {"type": "int"}}},
"heatmapDayDetailTitle": "{month}월 {day}일",
"@heatmapDayDetailTitle": {"placeholders": {"month": {"type": "int"}, "day": {"type": "int"}}},
"heatmapSessionItem": "{title} · {minutes}분",
"@heatmapSessionItem": {"placeholders": {"title": {"type": "String"}, "minutes": {"type": "int"}}}
```

`app_en.arb`:
```json
"heatmapTitle": "Activity",
"heatmapRecentWeeks": "Last {weeks} weeks",
"@heatmapRecentWeeks": {"placeholders": {"weeks": {"type": "int"}}},
"heatmapDayDetailTitle": "{month}/{day}",
"@heatmapDayDetailTitle": {"placeholders": {"month": {"type": "int"}, "day": {"type": "int"}}},
"heatmapSessionItem": "{title} · {minutes} min",
"@heatmapSessionItem": {"placeholders": {"title": {"type": "String"}, "minutes": {"type": "int"}}}
```

---

## 5. Done When

- [ ] 히트맵: 세션 있는 날 색상 강도로 표시됨
- [ ] 세션 없는 날: 회색 중립 (강조/수치심 없음)
- [ ] 셀 탭 → 해당 날 완료 세션 목록 BottomSheet 표시
- [ ] 완료 세션 없는 날 탭 → BottomSheet 미표시
- [ ] `supabase db reset` 통과
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` TC-01~TC-09 전체 통과
