# Task 05: 레이어-2 보상 — Phase 2

> **선제 조건**: Task 01 완료 (Supabase 연결), Task 03 완료 (DistractionRepository.getRecoveryCount 필요)
> **Claude Code 담당**: BadgeType 정의, 뱃지 조건 로직 설계, Supabase 스키마 설계, 유료 lock 아키텍처
> **Codex 담당**: 모든 코드 작성 (엔티티, Repository, 평가 UseCase, 언박싱 애니메이션, lock 화면, 테스트 전부)
> **PRD ref**: Section 6 (Reward Design), business.md (유료 전환 touchpoint)
> **핵심**: "컨디션 나쁜 날 시작 = 가장 희귀한 뱃지" — 이것이 가장 강력한 보상이자 유료 전환 포인트

---

## 1. 설계 명세 (Claude Code)

### 1-1. Badge 엔티티

```dart
// lib/features/reward/domain/entities/badge.dart
@freezed
class Badge with _$Badge {
  const factory Badge({
    required String id,
    required String userId,
    required BadgeType type,
    required DateTime earnedAt,
    /// 레이어 구분: layer2=공개, layer3=유료 잠금
    required BadgeLayer layer,
  }) = _Badge;
}

enum BadgeLayer { layer2, layer3 }

enum BadgeType {
  // === 레이어 2 (공개, 이번 태스크 구현) ===
  /// mood ≤ 2인 날 세션 시작. 가장 희귀.
  hardStart,
  /// 이탈 후 복귀 누적 10회.
  comeback10,
  /// 3일 연속 세션 완료.
  streak3,
  /// 7일 연속 세션 완료.
  streak7,
  /// 오전 7시 이전 세션 시작.
  earlyBird,
  /// 오후 11시 이후 세션 시작.
  nightOwl,

  // === 레이어 3 (유료 잠금, 이번 태스크에서 lock UI만 구현) ===
  masterFocus,   // 25분 세션 20회 완료
  perfectWeek,   // 7일 모두 완료
  centurion,     // 누적 세션 100회
}

// 각 뱃지 메타 정보
extension BadgeTypeX on BadgeType {
  BadgeLayer get layer => switch (this) {
    BadgeType.hardStart ||
    BadgeType.comeback10 ||
    BadgeType.streak3 ||
    BadgeType.streak7 ||
    BadgeType.earlyBird ||
    BadgeType.nightOwl => BadgeLayer.layer2,
    _ => BadgeLayer.layer3,
  };

  bool get isRare => this == BadgeType.hardStart;

  String get nameKey => 'badge${name[0].toUpperCase()}${name.substring(1)}Name';
  String get descKey => 'badge${name[0].toUpperCase()}${name.substring(1)}Desc';
}
```

### 1-2. BadgeRepository 인터페이스

```dart
// lib/features/reward/domain/repositories/badge_repository.dart
abstract interface class BadgeRepository {
  /// 이미 수여된 뱃지 타입인지 확인 (중복 방지).
  Future<bool> hasEarned(String userId, BadgeType type);

  /// 뱃지 저장.
  Future<Badge> save({
    required String userId,
    required BadgeType type,
  });

  /// 사용자의 모든 뱃지 반환.
  Future<List<Badge>> getAll(String userId);
}
```

### 1-3. EvaluateBadgeUseCase 설계

```dart
// lib/features/reward/domain/usecases/evaluate_badge_usecase.dart

// [HIGH-3 FIX] EvaluateBadgeUseCase 분리: 규칙 평가(순수)와 영속성을 분리
// EvaluateBadgeRulesUseCase: 순수 함수 — 조건 충족 뱃지 목록 반환 (DB 없음)
class EvaluateBadgeRulesUseCase {
  /// [alreadyEarned]: 기존 수여 뱃지 세트 (caller가 전달)
  /// [moodLevel]: 세션 시작 기분 (1~5)
  /// [consecutiveDays]: 연속일 (BadgeRepository에서 조회)
  /// [recoveryCount]: 누적 복귀 횟수 (DistractionRepository에서 조회)
  List<BadgeType> call({
    required Set<BadgeType> alreadyEarned,
    required DateTime sessionStartedAt,
    required int consecutiveDays,
    required int recoveryCount,
    int? moodLevel,
  }) {
    final newBadges = <BadgeType>[];

    // hardStart 최우선 (가장 희귀 + 가장 가치 있는 순간)
    if (moodLevel != null && moodLevel <= 2 && !alreadyEarned.contains(BadgeType.hardStart)) {
      newBadges.add(BadgeType.hardStart);
    }
    // comeback10
    if (recoveryCount >= 10 && !alreadyEarned.contains(BadgeType.comeback10)) {
      newBadges.add(BadgeType.comeback10);
    }
    // streak3 / streak7 (연속일 클수록 나중에 표시)
    if (consecutiveDays >= 3 && !alreadyEarned.contains(BadgeType.streak3)) {
      newBadges.add(BadgeType.streak3);
    }
    if (consecutiveDays >= 7 && !alreadyEarned.contains(BadgeType.streak7)) {
      newBadges.add(BadgeType.streak7);
    }
    // earlyBird / nightOwl
    if (sessionStartedAt.hour < 7 && !alreadyEarned.contains(BadgeType.earlyBird)) {
      newBadges.add(BadgeType.earlyBird);
    }
    if (sessionStartedAt.hour >= 23 && !alreadyEarned.contains(BadgeType.nightOwl)) {
      newBadges.add(BadgeType.nightOwl);
    }
    // [HIGH-6 FIX] 다중 뱃지 동시 해금 시 hardStart만 표시 (나머지는 다음 세션까지 throttle)
    // hardStart가 있으면 다른 뱃지 제거 — 희귀 보상 희석 방지
    if (newBadges.contains(BadgeType.hardStart) && newBadges.length > 1) {
      return [BadgeType.hardStart]; // hardStart 단독 표시, 나머지는 다음 평가에서 처리
    }
    return newBadges;
  }
}

// AwardBadgesUseCase: 영속성 — 규칙 평가 결과를 저장하고 반환
class AwardBadgesUseCase {
  const AwardBadgesUseCase(this._badgeRepository, this._distractionRepository);
  final BadgeRepository _badgeRepository;
  final DistractionRepository _distractionRepository;

  Future<List<BadgeType>> call({
    required String userId,
    required DateTime sessionStartedAt,
    required int consecutiveDays,
    int? moodLevel,
  }) async {
    final alreadyEarned = (await _badgeRepository.getAll(userId)).toSet();
    final recoveryCount = await _distractionRepository.getRecoveryCount(userId);

    final newBadges = const EvaluateBadgeRulesUseCase().call(
      alreadyEarned: alreadyEarned,
      sessionStartedAt: sessionStartedAt,
      consecutiveDays: consecutiveDays,
      recoveryCount: recoveryCount,
      moodLevel: moodLevel,
    );

    for (final type in newBadges) {
      await _badgeRepository.save(userId: userId, type: type);
    }
    return newBadges;
  }
}
```

**연속일 계산 UseCase**:

```dart
// lib/features/reward/domain/usecases/get_consecutive_days_usecase.dart
class GetConsecutiveDaysUseCase {
  const GetConsecutiveDaysUseCase(this._repository);
  final BadgeRepository _repository; // 또는 StatsRepository

  /// Supabase에서 연속 세션 완료 일수 계산.
  Future<int> call(String userId) async {
    // sessions 날짜 목록 → 연속 날짜 계산
    // Supabase RPC: get_consecutive_days(p_user_id)
    throw UnimplementedError(); // Codex 구현
  }
}
```

### 1-4. Supabase 스키마

`supabase/migrations/20260518000020_badges_table.sql`:

```sql
CREATE TABLE badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  badge_type TEXT NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  -- 중복 수여 방지
  UNIQUE(user_id, badge_type)
);

ALTER TABLE badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own badges"
  ON badges FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own badges"
  ON badges FOR INSERT WITH CHECK (user_id = auth.uid());

-- [CRITICAL FIX] p_user_id 파라미터 제거 — auth.uid() 내부 사용으로 RLS 우회 차단
CREATE OR REPLACE FUNCTION get_consecutive_days()
RETURNS INTEGER AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_count INTEGER := 0;
  v_date DATE := CURRENT_DATE;
  v_has_session BOOLEAN;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  LOOP
    SELECT EXISTS(
      SELECT 1 FROM sessions
      WHERE user_id = v_user_id
        AND DATE(started_at) = v_date
        AND status = 'completed'
    ) INTO v_has_session;

    EXIT WHEN NOT v_has_session;

    v_count := v_count + 1;
    v_date := v_date - 1;
  END LOOP;

  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 1-5. 언박싱 애니메이션 설계

`hardStart` 뱃지는 특별 애니메이션:
1. 화면 전체 오버레이 (반투명 배경)
2. 뱃지 아이콘 scale 0 → 1 (300ms, Curves.elasticOut)
3. 빛 발산 효과 (RadialGradient + opacity fade)
4. 제목: "가장 빛나는 시작" (hardStart 전용)
5. 본문: 뱃지 설명 텍스트
6. "확인" 버튼으로 닫기

일반 레이어 2 뱃지:
1. SnackBar 스타일 알림 (화면 상단)
2. 뱃지 아이콘 + "새 뱃지 획득!" 텍스트
3. 3초 후 자동 닫기

### 1-6. TimerNotifier 연동 포인트

세션 완료 시 (`TimerNotifier._complete()`) 뱃지 평가 호출:

```dart
// lib/features/session/presentation/providers/timer_provider.dart
// 기존 _complete() 메서드에 추가
Future<void> _complete() async {
  // ... 기존 코드 (analytics, 세션 저장 등)

  // 뱃지 평가
  final moodLevel = ref.read(moodCheckProvider).lastMoodLevel; // getter 추가 필요
  final consecutiveDays = await ref.read(consecutiveDaysProvider.future);
  final newBadges = await ref.read(evaluateBadgeUseCaseProvider).call(
    userId: currentUserId,
    sessionStartedAt: _startedAt!, // 세션 시작 시각
    consecutiveDays: consecutiveDays,
    moodLevel: moodLevel,
  );

  if (newBadges.isNotEmpty) {
    ref.read(badgeUnlockProvider.notifier).show(newBadges);
  }
}
```

### 1-7. 에러 케이스

| 상황 | 처리 |
|------|------|
| `hasEarned` 실패 (네트워크) | 뱃지 평가 skip (세션 완료는 방해 않음) |
| `save` 실패 (UNIQUE 제약 위반) | 무시 (이미 수여됨) |
| 게스트 사용자 | 뱃지 평가 skip (로그인 후 재평가 불가) |
| `getRecoveryCount` 실패 | comeback10 평가 skip |

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task05-reward-layer2.md`:

```
Project: OwnUrTime Flutter
Context: Phase 2 Task 05 — 레이어-2 보상 (뱃지).
기존 lib/features/reward/ 폴더에 추가.

## 항목 1: 도메인 레이어
설계 명세 코드 그대로 작성:
- lib/features/reward/domain/entities/badge.dart (BadgeType, BadgeLayer, extension 포함)
- lib/features/reward/domain/repositories/badge_repository.dart
- lib/features/reward/domain/usecases/evaluate_badge_usecase.dart
- lib/features/reward/domain/usecases/get_badges_usecase.dart (getAll 호출 래퍼)
- lib/features/reward/domain/usecases/get_consecutive_days_usecase.dart

## 항목 2: SupabaseBadgeDataSource
파일: lib/features/reward/data/datasources/badge_remote_datasource.dart
```dart
class SupabaseBadgeDataSource {
  const SupabaseBadgeDataSource(this._client);
  final SupabaseClient _client;

  Future<bool> hasEarned(String userId, String badgeType) async {
    final response = await _client
        .from('badges')
        .select('id')
        .eq('user_id', userId)
        .eq('badge_type', badgeType)
        .maybeSingle();
    return response != null;
  }

  Future<Map<String, dynamic>> save(String userId, String badgeType) async {
    final response = await _client
        .from('badges')
        .upsert({'user_id': userId, 'badge_type': badgeType})
        .select()
        .single();
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAll(String userId) async {
    final response = await _client
        .from('badges')
        .select()
        .eq('user_id', userId)
        .order('earned_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }
}
```

## 항목 3: BadgeRepositoryImpl
파일: lib/features/reward/data/repositories/badge_repository_impl.dart
- hasEarned, save, getAll 각각 datasource 위임

## 항목 4: GetConsecutiveDaysUseCase 구현
<!-- [FIX] UseCase에서 Supabase 직접 호출 → RULE 03 위반. BadgeRepository 경유 필요 -->
<!-- [CRITICAL FIX] p_user_id 파라미터 제거 — RPC 내부에서 auth.uid() 사용 -->
```dart
Future<int> call() => _repository.getConsecutiveDays();
```
BadgeRepository 인터페이스에 추가:
```dart
Future<int> getConsecutiveDays();
```
BadgeRepositoryImpl에서 Supabase RPC 호출:
```dart
@override
Future<int> getConsecutiveDays() async {
  // p_user_id 없음 — 서버가 auth.uid() 자동 사용
  final response = await _client.rpc('get_consecutive_days');
  return (response as int?) ?? 0;
}
```

## 항목 5: BadgeUnlockNotifier (언박싱 표시 제어)
파일: lib/features/reward/presentation/providers/badge_unlock_provider.dart
```dart
@freezed
sealed class BadgeUnlockState with _$BadgeUnlockState {
  const factory BadgeUnlockState.idle() = _Idle;
  const factory BadgeUnlockState.showing(List<BadgeType> badges) = _Showing;
}

class BadgeUnlockNotifier extends _$BadgeUnlockNotifier {
  @override
  BadgeUnlockState build() => const BadgeUnlockState.idle();

  void show(List<BadgeType> badges) =>
      state = BadgeUnlockState.showing(badges);

  void dismiss() => state = const BadgeUnlockState.idle();
}
```

## 항목 6: BadgeUnlockOverlay (언박싱 애니메이션)
파일: lib/features/reward/presentation/widgets/badge_unlock_overlay.dart
- state가 showing이면 화면 전체 오버레이 표시
- hardStart 뱃지: 풀 스크린 애니메이션 (설계 명세 5단계)
  <!-- [FIX] flutter_animate 의존성 추가 전 사용자 승인 필요 -->
  - `flutter_animate` 패키지: .scale(begin: Offset(0,0), end: Offset(1,1), duration: 300ms, curve: Curves.elasticOut) (사용자 승인 후 pubspec 추가)
  - 빛 발산: DecoratedBox + RadialGradient + AnimatedOpacity
- 일반 뱃지: SnackBar 스타일 (Material SnackBar 사용)
- "확인" 버튼 → notifier.dismiss()
- SessionScreen의 Stack 최상위에 배치

## 항목 7: BadgeCollectionScreen
파일: lib/features/reward/presentation/screens/badge_collection_screen.dart

레이아웃:
```
Scaffold(appBar: "내 뱃지")
└── GridView.count(crossAxisCount: 3)
    ├── (획득 뱃지) BadgeCard (컬러)
    └── (미획득 레이어2) BadgeCard (회색, 조건 텍스트)
    └── (레이어3 잠금) PremiumLockCard (실루엣 + 잠금 아이콘)
```

## 항목 8: BadgeCard 위젯
파일: lib/features/reward/presentation/widgets/badge_card.dart
- 획득: 아이콘 컬러 + 이름 텍스트
- 미획득: 아이콘 회색 + 조건 텍스트 (예: "mood 낮은 날 시작하면 획득!")
- hardStart는 특별 배경 (금색 테두리)

## 항목 9: PremiumLockCard 위젯
파일: lib/features/reward/presentation/widgets/premium_lock_card.dart
- 뱃지 실루엣 (회색 필터)
- 잠금 아이콘 오버레이
- 탭 → PaywallScreen으로 이동 (Task 09 라우트, 아직 없으면 '/paywall' 플레이스홀더)

## 항목 10: TimerNotifier._complete() 수정
파일: lib/features/session/presentation/providers/timer_provider.dart
기존 _complete() 끝부분에 뱃지 평가 코드 추가 (설계 명세 연동 포인트 코드)
- moodCheckProvider에서 lastMoodLevel getter 추가 필요
- evaluateBadgeUseCase 호출 → newBadges 반환
- badgeUnlockProvider.show(newBadges)

## 항목 11: GoRouter /badges 라우트 추가
파일: lib/core/router/app_router.dart
- /badges 추가
- 설정 화면 또는 TaskListScreen에서 접근 가능

## 항목 12: SQL 마이그레이션
- supabase/migrations/20260518000020_badges_table.sql (설계 명세 그대로)

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과
```

---

## 3. 테스트 명세

### `test/features/reward/domain/evaluate_badge_usecase_test.dart`

```
TC-01: hardStart — mood=2 → hardStart 뱃지 수여
  setup: FakeBadgeRepo.hasEarned(hardStart) → false, moodLevel=2
  기대: 반환 리스트에 BadgeType.hardStart 포함
  기대: FakeBadgeRepo.save(hardStart) 호출됨

TC-02: hardStart — 이미 수여됨 → 중복 수여 없음
  setup: FakeBadgeRepo.hasEarned(hardStart) → true, moodLevel=1
  기대: hardStart 미포함

TC-03: hardStart — mood=3 → hardStart 미수여
  기대: hardStart 미포함

TC-04: comeback10 — recoveryCount=10, 미수여 → 수여
  setup: FakeDistractionRepo.getRecoveryCount() → 10
  기대: comeback10 포함

TC-05: comeback10 — recoveryCount=9 → 미수여
  기대: comeback10 미포함

TC-06: streak3 — consecutiveDays=3 → 수여
  기대: streak3 포함

TC-07: streak7 — consecutiveDays=7 → streak3 + streak7 동시 수여 (미수여 상태)
  기대: [streak3, streak7] 포함

TC-08: earlyBird — sessionStartedAt.hour=6 → 수여
  기대: earlyBird 포함

TC-09: earlyBird — sessionStartedAt.hour=7 → 미수여
  기대: earlyBird 미포함

TC-10: 복수 뱃지 동시 수여
  setup: mood=2, consecutiveDays=3
  기대: [hardStart, streak3] 포함
```

### `test/features/reward/data/badge_repository_impl_test.dart`

```
TC-11: save 성공 → Badge 반환
TC-12: save UNIQUE 제약 위반 → exception rethrow (중복 처리)
TC-13: getAll → List<Badge> 반환
```

### `test/features/reward/presentation/badge_unlock_notifier_test.dart`

```
TC-14: 초기 상태 → idle
TC-15: show([hardStart]) → showing([hardStart])
TC-16: dismiss → idle
```

---

## 4. l10n 추가 (Codex)

`app_ko.arb`:
```json
"badgesTitle": "내 뱃지",
"badgeHardStartName": "빛나는 시작",
"badgeHardStartDesc": "컨디션이 좋지 않은 날 세션을 시작했어요. 가장 용감한 시작이에요.",
"badgeHardStartCondition": "mood가 낮은 날 세션을 시작하면 획득",
"badgeComeback10Name": "복귀의 달인",
"badgeComeback10Desc": "이탈 후 10번 돌아왔어요. 복귀하는 것 자체가 실력이에요.",
"badgeComeback10Condition": "이탈 후 복귀 10회 달성",
"badgeStreak3Name": "3일 연속",
"badgeStreak3Desc": "3일 연속으로 세션을 완료했어요!",
"badgeStreak3Condition": "3일 연속 세션 완료",
"badgeStreak7Name": "7일 연속",
"badgeStreak7Desc": "7일 연속 완주! 대단해요.",
"badgeStreak7Condition": "7일 연속 세션 완료",
"badgeEarlyBirdName": "아침형 집중",
"badgeEarlyBirdDesc": "오전 7시 이전에 세션을 시작했어요.",
"badgeEarlyBirdCondition": "오전 7시 이전 세션 시작",
"badgeNightOwlName": "올빼미 집중",
"badgeNightOwlDesc": "밤 11시 이후에도 집중했어요.",
"badgeNightOwlCondition": "밤 11시 이후 세션 시작",
"badgeUnlockTitle": "새 뱃지를 획득했어요!",
"badgeHardStartUnlockTitle": "가장 빛나는 시작",
"badgePremiumLocked": "OwnUrTime Pro에서 해금",
"badgeNotEarnedYet": "아직 획득하지 못했어요"
```

---

## 5. Done When

- [ ] mood ≤ 2 + 세션 시작 + 완료 → hardStart 뱃지 애니메이션 표시됨
- [ ] Supabase badges 테이블에 뱃지 저장 확인
- [ ] 중복 수여 없음 (hardStart 2번 시도 → 1개만)
- [ ] 뱃지 갤러리: 획득/미획득 구분 표시
- [ ] 레이어 3 뱃지: 잠금 UI + CTA (클릭 시 /paywall 이동)
- [ ] `supabase db reset` 통과
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` TC-01~TC-16 전체 통과
