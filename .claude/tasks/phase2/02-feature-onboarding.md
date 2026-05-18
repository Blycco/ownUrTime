# Task 02: 온보딩 — Phase 2

> **선제 조건**: Task 01 완료 (Supabase 연결)
> **Claude Code 담당**: 온보딩 플로우 설계, 도메인 인터페이스/엔티티, 상태 머신, GoRouter redirect 설계
> **Codex 담당**: 모든 코드 작성 (도메인 구현체, UI 위젯, 애니메이션, l10n, 테스트 전부)
> **PRD ref**: Section 7 (Onboarding), adhd-domain.md
> **읽기**: `.claude/context/adhd-domain.md`, `.claude/context/dart-patterns.md`
> **ADHD UX 원칙**: 강요 없음, 스킵 가능, 인지 부하 최소화, 모든 단계 1탭으로 넘어감

---

## 1. 설계 명세 (Claude Code)

### 1-0. Day+1 재방문 플로우 (신규)
<!-- [HIGH-5 FIX] Day+1 복귀 사용자 UX 미정의 → day_2_return 이벤트만 있고 실제 화면 없음 -->

**조건**: `onboarding_v1_completed == true` && 마지막 세션 완료 후 24시간 이상 경과

**복귀 트리거** (앱 포어그라운드 진입 시 체크):
```dart
// AppLifecycleState.resumed → AppReturnChecker
// SharedPreferences: 'last_session_completed_at' 타임스탬프 저장
// 24시간 이상 경과 → TaskListScreen 상단에 복귀 배너 표시 (1회만)
```

**복귀 배너 UI** (TaskListScreen 최상단 1줄, 비강요):
```
"어제보다 오늘 → 2분이면 충분해요" [시작하기] 버튼 → /tasks/start
```
- 스크롤 시 자동 사라짐 (강요 없음)
- 탭하거나 무시하면 다음 방문까지 미표시

### 1-1. 온보딩 플로우

```
앱 첫 실행
    │
    ▼
onboarding_v1_completed == false?
    │ YES                 │ NO
    ▼                     ▼
/onboarding           day+1 복귀 체크 → /tasks
    │
    ▼
[Step 1] 착수의 어려움
    │ "다음" 또는 스킵
    ▼
[Step 2] 유지의 어려움
    │ "다음" 또는 스킵
    ▼
[Step 3] 복귀의 어려움
    │ "시작하기" 또는 스킵
    ▼
[Step 4] 알림 권한 (opt-in)
    │ "켜기" 또는 "나중에"
    ▼
markCompleted() + PostHog event
    │
    ▼
/tasks (TaskListScreen)
    │
    ▼ (자동, 첫 세션 전)
기분 체크 모달 표시
```

### 1-2. 도메인 엔티티 / 인터페이스

**OnboardingStatus** entity:

```dart
// lib/features/onboarding/domain/entities/onboarding_status.dart
@freezed
class OnboardingStatus with _$OnboardingStatus {
  const factory OnboardingStatus({
    required bool isCompleted,
    required bool notificationOptedIn,
    /// 온보딩 버전 — 향후 새 온보딩 추가 시 재표시 가능
    @Default(1) int version,
  }) = _OnboardingStatus;
}
```

**OnboardingRepository** interface:

```dart
// lib/features/onboarding/domain/repositories/onboarding_repository.dart
abstract interface class OnboardingRepository {
  /// 현재 온보딩 완료 여부 반환.
  Future<OnboardingStatus> getStatus();

  /// 온보딩 완료 처리. version=1로 저장.
  Future<void> markCompleted({required bool notificationOptedIn});

  /// 개발 목적 초기화 (debug build only).
  Future<void> resetForDebug();
}
```

**UseCases**:

```dart
// lib/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart
class GetOnboardingStatusUseCase {
  const GetOnboardingStatusUseCase(this._repository);
  final OnboardingRepository _repository;

  Future<OnboardingStatus> call() => _repository.getStatus();
}

// lib/features/onboarding/domain/usecases/complete_onboarding_usecase.dart
class CompleteOnboardingUseCase {
  const CompleteOnboardingUseCase(this._repository);
  final OnboardingRepository _repository;

  Future<void> call({required bool notificationOptedIn}) =>
      _repository.markCompleted(notificationOptedIn: notificationOptedIn);
}
```

### 1-3. OnboardingState 상태 머신

```dart
// lib/features/onboarding/presentation/providers/onboarding_provider.dart

@freezed
sealed class OnboardingUiState with _$OnboardingUiState {
  /// 초기 로딩 (SharedPreferences 읽는 중)
  const factory OnboardingUiState.loading() = _Loading;

  /// 온보딩 슬라이드 표시 중
  const factory OnboardingUiState.inProgress({
    @Default(0) int currentStep, // 0, 1, 2 (총 3단계)
  }) = _InProgress;

  /// 알림 권한 요청 단계
  const factory OnboardingUiState.notificationStep() = _NotificationStep;

  /// 완료
  const factory OnboardingUiState.completed() = _Completed;

  /// 이미 완료된 사용자 (앱 재진입)
  const factory OnboardingUiState.alreadyCompleted() = _AlreadyCompleted;
}
```

**OnboardingNotifier** 동작 명세:

```
build():
  status = await getOnboardingStatusUseCase()
  if status.isCompleted → state = alreadyCompleted()
  else → state = inProgress(currentStep: 0)

nextStep():
  inProgress(step: 0) → inProgress(step: 1)
  inProgress(step: 1) → inProgress(step: 2)
  inProgress(step: 2) → notificationStep()

skipAll():
  어느 단계에서든 → notificationStep() (알림은 항상 제공)

completeWithNotification(bool optIn):
  await completeOnboardingUseCase(notificationOptedIn: optIn)
  if optIn → 알림 권한 요청 (permission_handler)
  analyticsService.capture('onboarding_completed', {notification_enabled: optIn})
  state = completed()
```

### 1-4. GoRouter redirect 설계

```dart
// app_router.dart 수정 사항

// 신규 라우트 추가
GoRoute(
  path: '/onboarding',
  builder: (context, state) => const OnboardingScreen(),
),

// redirect 로직 추가
redirect: (BuildContext context, GoRouterState state) {
  final isOnboardingRoute = state.matchedLocation == '/onboarding';

  // 온보딩 완료 여부는 SharedPreferences에서 동기적으로 읽음
  // OnboardingStatusProvider (Provider<bool>)를 통해 접근
  final isCompleted = ProviderScope.containerOf(context)
      .read(onboardingCompletedProvider);

  if (!isCompleted && !isOnboardingRoute) {
    return '/onboarding';
  }
  if (isCompleted && isOnboardingRoute) {
    return '/tasks';
  }
  return null;
},
```

**onboardingCompletedProvider** (동기 Provider):

```dart
// 앱 시작 시 SharedPreferences에서 읽어 캐시
final onboardingCompletedProvider = Provider<bool>((ref) {
  // main.dart에서 override로 주입
  return false; // 기본값
});
```

> main.dart에서 앱 시작 전 SharedPreferences 읽어 ProviderScope override로 주입.

### 1-5. 알림 권한 처리

```dart
// permission_handler 패키지 사용
// pubspec.yaml에 permission_handler: ^11.x.x 추가 필요

Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.request();
  // 거부되어도 앱 정상 동작 (opt-in이므로)
}
```

### 1-6. LocalDataSource 설계

```dart
// lib/features/onboarding/data/datasources/onboarding_local_datasource.dart

abstract interface class OnboardingLocalDataSource {
  Future<bool> isCompleted();
  Future<void> markCompleted({required bool notificationOptedIn, required int version});
  Future<bool> isNotificationOptedIn();
  Future<void> reset();
}
```

SharedPreferences 키:
- `onboarding_v1_completed`: bool
- `onboarding_v1_notification_opted_in`: bool

### 1-7. 에러 케이스

| 상황 | 처리 |
|------|------|
| SharedPreferences 읽기 실패 | catch → 온보딩 미완료로 처리 (안전한 기본값) |
| 알림 권한 요청 중 앱 백그라운드 | permission_handler가 처리 |
| 온보딩 중 앱 강제 종료 | 재시작 시 currentStep=0부터 (inProgress 상태는 메모리, 재진입 시 처음부터) |
| onboarding_completed=true인데 /onboarding 직접 접근 | redirect → /tasks |

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task02-onboarding.md`:

```
Project: OwnUrTime Flutter
Context: Phase 2 Task 02 — 온보딩 신규 피처 전체 구현.
폴더: lib/features/onboarding/ 신규 생성.

## 구현 원칙
- ADHD UX: 강요 없음, 어느 단계에서도 스킵 가능
- 텍스트 하드코딩 금지 — 모든 문자열 ARB 키 사용
<!-- [FIX] 의존성 추가 전 사용자 승인 필요 — 구현 시작 전 확인 -->
- `permission_handler: ^11.x.x` pubspec.yaml 추가 (사용자 승인 후 추가)

## 항목 1: 폴더 구조 생성 + 도메인 레이어
도메인 엔티티/인터페이스/UseCase는 설계 명세 코드 그대로 작성.
생성 파일:
- lib/features/onboarding/domain/entities/onboarding_status.dart
- lib/features/onboarding/domain/repositories/onboarding_repository.dart
- lib/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart
- lib/features/onboarding/domain/usecases/complete_onboarding_usecase.dart

## 항목 2: 데이터 레이어
파일 1: lib/features/onboarding/data/datasources/onboarding_local_datasource.dart
인터페이스(설계 명세 코드) + SharedPreferencesOnboardingDataSource 구현체:
```dart
class SharedPreferencesOnboardingDataSource implements OnboardingLocalDataSource {
  static const _completedKey = 'onboarding_v1_completed';
  static const _notificationKey = 'onboarding_v1_notification_opted_in';

  @override
  Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  @override
  Future<void> markCompleted({required bool notificationOptedIn, required int version}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
    await prefs.setBool(_notificationKey, notificationOptedIn);
  }

  @override
  Future<bool> isNotificationOptedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationKey) ?? false;
  }

  @override
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
    await prefs.remove(_notificationKey);
  }
}
```

파일 2: lib/features/onboarding/data/repositories/onboarding_repository_impl.dart
```dart
class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._dataSource);
  final OnboardingLocalDataSource _dataSource;

  @override
  Future<OnboardingStatus> getStatus() async {
    final isCompleted = await _dataSource.isCompleted();
    final notificationOptedIn = await _dataSource.isNotificationOptedIn();
    return OnboardingStatus(
      isCompleted: isCompleted,
      notificationOptedIn: notificationOptedIn,
    );
  }

  @override
  Future<void> markCompleted({required bool notificationOptedIn}) =>
      _dataSource.markCompleted(notificationOptedIn: notificationOptedIn, version: 1);

  @override
  Future<void> resetForDebug() => _dataSource.reset();
}
```

파일 3: lib/features/onboarding/data/providers/onboarding_providers.dart
Riverpod providers: onboardingRepositoryProvider, getOnboardingStatusUseCaseProvider, completeOnboardingUseCaseProvider

## 항목 3: OnboardingNotifier (설계 명세 동작 그대로 구현)
파일: lib/features/onboarding/presentation/providers/onboarding_provider.dart
- OnboardingUiState sealed class (설계 명세 코드)
- OnboardingNotifier: build, nextStep, skipAll, completeWithNotification
- completeWithNotification에서 permission_handler로 알림 권한 요청

## 항목 4: onboardingCompletedProvider (동기, main.dart 연동)
파일: lib/features/onboarding/presentation/providers/onboarding_provider.dart 하단에 추가
```dart
// main.dart에서 override로 주입
final onboardingCompletedProvider = Provider<bool>((_) => false);
```

파일: lib/main.dart 수정
앱 시작 시 SharedPreferences 읽어 ProviderScope에 override 주입:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... 기존 Supabase init

  final prefs = await SharedPreferences.getInstance();
  final isOnboardingCompleted = prefs.getBool('onboarding_v1_completed') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        onboardingCompletedProvider.overrideWithValue(isOnboardingCompleted),
      ],
      child: const MyApp(),
    ),
  );
}
```

## 항목 5: GoRouter 수정
파일: lib/core/router/app_router.dart
- /onboarding 라우트 추가
- redirect 로직 추가 (설계 명세 코드 그대로)

## 항목 6: OnboardingScreen (PageView 3단계 + 알림 단계)
파일: lib/features/onboarding/presentation/screens/onboarding_screen.dart

구조:
```
Scaffold
└── Stack
    ├── PageView (3단계 슬라이드, controller)
    │   ├── OnboardingPage(step: 0) — 착수
    │   ├── OnboardingPage(step: 1) — 유지
    │   └── OnboardingPage(step: 2) — 복귀
    ├── OnboardingIndicator (하단 도트)
    └── NotificationStepOverlay (state가 notificationStep일 때 표시)
```

화면 전환:
- "다음" 버튼 탭 → notifier.nextStep()
- PageView.animateToPage(currentStep)
- 마지막 슬라이드("시작하기") → notifier.nextStep() → notificationStep
- state가 completed → GoRouter.go('/tasks')

## 항목 7: OnboardingPage 위젯
파일: lib/features/onboarding/presentation/widgets/onboarding_page.dart

```dart
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.step});
  final int step; // 0, 1, 2

  // step에 따른 콘텐츠 매핑 (l10n 사용)
  // step 0: onboardingStep1Title, onboardingStep1Body, 일러스트 asset
  // step 1: onboardingStep2Title, onboardingStep2Body
  // step 2: onboardingStep3Title, onboardingStep3Body
}
```

레이아웃:
- 상단 1/2: 일러스트 영역 (assets/images/onboarding_{step+1}.png — placeholder 사용)
- 하단 1/2: 제목(TextStyle.headlineSmall) + 본문(TextStyle.bodyMedium)
- 여백: 좌우 24px, 텍스트 center 정렬
- 배경: AppTheme.backgroundColor

"스킵" 버튼: 우상단 TextButton (항상 표시)
탭 시 notifier.skipAll()

## 항목 8: OnboardingIndicator 위젯
파일: lib/features/onboarding/presentation/widgets/onboarding_indicator.dart
- 3개 도트, currentStep에 따라 active 도트 색상 변경
- 애니메이션: AnimatedContainer (width: active=24, inactive=8)

## 항목 9: NotificationStepOverlay 위젯
파일: lib/features/onboarding/presentation/widgets/onboarding_notification_prompt.dart

구조:
```
AnimatedOpacity (state가 notificationStep일 때 opacity=1.0)
└── Container (반투명 배경)
    └── Column
        ├── 아이콘 (bell icon)
        ├── 제목: onboardingNotificationTitle
        ├── 본문: onboardingNotificationBody
        ├── ElevatedButton("켜기") → notifier.completeWithNotification(true)
        └── TextButton("나중에") → notifier.completeWithNotification(false)
```

"켜기"와 "나중에" 버튼 동일한 크기로 배치 (선택 압박 없음)

## 항목 10: pubspec.yaml 수정
permission_handler: ^11.3.0 추가 (알림 권한 요청용)

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과
```

### 2-2. 구현 파일 목록

| 파일 | 담당 |
|------|------|
| `lib/features/onboarding/domain/entities/onboarding_status.dart` | Codex |
| `lib/features/onboarding/domain/repositories/onboarding_repository.dart` | Codex |
| `lib/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart` | Codex |
| `lib/features/onboarding/domain/usecases/complete_onboarding_usecase.dart` | Codex |
| `lib/features/onboarding/data/datasources/onboarding_local_datasource.dart` | Codex |
| `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart` | Codex |
| `lib/features/onboarding/data/providers/onboarding_providers.dart` | Codex |
| `lib/features/onboarding/presentation/providers/onboarding_provider.dart` | Codex |
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | Codex |
| `lib/features/onboarding/presentation/widgets/onboarding_page.dart` | Codex |
| `lib/features/onboarding/presentation/widgets/onboarding_indicator.dart` | Codex |
| `lib/features/onboarding/presentation/widgets/onboarding_notification_prompt.dart` | Codex |
| `lib/core/router/app_router.dart` | Codex (redirect + /onboarding 추가) |
| `lib/main.dart` | Codex (ProviderScope override 추가) |
| `pubspec.yaml` | Codex (permission_handler 추가) |

---

## 3. 테스트 명세

### `test/features/onboarding/domain/get_onboarding_status_usecase_test.dart`

```
TC-01: 첫 실행 — isCompleted=false
  setup: FakeOnboardingDataSource.isCompleted() → false
  기대: usecase() returns OnboardingStatus(isCompleted: false)

TC-02: 완료 상태 — isCompleted=true
  setup: FakeOnboardingDataSource.isCompleted() → true
  기대: usecase() returns OnboardingStatus(isCompleted: true)
```

### `test/features/onboarding/presentation/onboarding_notifier_test.dart`

```
TC-03: build — 첫 실행 → inProgress(currentStep: 0)
  setup: FakeRepo.getStatus() → OnboardingStatus(isCompleted: false)
  기대: state == OnboardingUiState.inProgress(currentStep: 0)

TC-04: build — 기존 완료 → alreadyCompleted
  setup: FakeRepo.getStatus() → OnboardingStatus(isCompleted: true)
  기대: state == OnboardingUiState.alreadyCompleted()

TC-05: nextStep 연속 호출 → 슬라이드 진행
  초기: inProgress(0)
  nextStep() → inProgress(1)
  nextStep() → inProgress(2)
  nextStep() → notificationStep()

TC-06: skipAll → notificationStep
  초기: inProgress(1)
  skipAll() → state == notificationStep()

TC-07: completeWithNotification(true) → completed + markCompleted 호출됨
  기대: FakeRepo.markCompleted(notificationOptedIn: true) 호출됨
  기대: state == completed()

TC-08: completeWithNotification(false) → completed + markCompleted(false) 호출됨
```

### `test/features/onboarding/presentation/onboarding_screen_test.dart`

```
TC-09: 화면 렌더링 — Step 1 텍스트 표시
  기대: onboardingStep1Title 텍스트 존재

TC-10: "스킵" 버튼 탭 → notificationStep 상태
  기대: NotificationStepOverlay 표시됨

TC-11: "나중에" 탭 → completed → GoRouter.go('/tasks') 호출됨
```

### `test/features/onboarding/data/onboarding_repository_impl_test.dart`

```
TC-12: getStatus — DataSource 호출 후 OnboardingStatus 반환
TC-13: markCompleted — DataSource.markCompleted 호출됨 (version=1)
TC-14: resetForDebug — DataSource.reset 호출됨
```

---

## 4. l10n 추가 (Codex)

`lib/l10n/app_ko.arb`:
```json
"onboardingStep1Title": "시작하기가 제일 힘들죠",
"onboardingStep1Body": "ADHD를 가진 많은 분들이 시작에 20-40분을 써요.\nOwnUrTime은 '딱 2분만'으로 착수 장벽을 낮춰요.",
"onboardingStep2Title": "집중이 흐트러져도 괜찮아요",
"onboardingStep2Body": "이탈은 실패가 아니에요.\n'집중이 흐트러졌어요' 버튼으로 솔직하게 기록하고,\n앱이 맥락을 기억해 줄게요.",
"onboardingStep3Title": "돌아오는 것이 진짜 실력이에요",
"onboardingStep3Body": "중단 후 복귀가 신경전형인보다 2배 걸려요.\nOwnUrTime은 당신의 작업을 기억하고,\n1탭으로 다시 연결해 줘요.",
"onboardingNext": "다음",
"onboardingStart": "시작하기",
"onboardingSkip": "스킵",
"onboardingNotificationTitle": "약 복용 알림을 켤까요?",
"onboardingNotificationBody": "매일 같은 시간에 조용하게 알려드려요.\n언제든 설정에서 끌 수 있어요.",
"onboardingNotificationEnable": "켜기",
"onboardingNotificationLater": "나중에"
```

`lib/l10n/app_en.arb`:
```json
"onboardingStep1Title": "Starting is the hardest part",
"onboardingStep1Body": "Many people with ADHD spend 20-40 minutes just trying to start.\nOwnUrTime makes it easy with a 2-minute micro-start.",
"onboardingStep2Title": "It's okay to get distracted",
"onboardingStep2Body": "Getting distracted isn't failure.\nTap 'I got distracted' and we'll remember your context for you.",
"onboardingStep3Title": "Coming back is the real skill",
"onboardingStep3Body": "Recovery after interruption takes twice as long for ADHD brains.\nOwnUrTime remembers your work and reconnects you in 1 tap.",
"onboardingNext": "Next",
"onboardingStart": "Get Started",
"onboardingSkip": "Skip",
"onboardingNotificationTitle": "Want a medication reminder?",
"onboardingNotificationBody": "A gentle nudge at the same time each day.\nYou can turn it off anytime in Settings.",
"onboardingNotificationEnable": "Turn On",
"onboardingNotificationLater": "Not Now"
```

---

## 5. Done When

- [ ] 앱 삭제 후 재설치 → /onboarding 화면 표시됨
- [ ] 온보딩 완료 후 앱 재시작 → /tasks 직접 진입 (온보딩 skip)
- [ ] 온보딩 중 임의 단계에서 "스킵" → 알림 단계로 이동
- [ ] "나중에" 탭 → /tasks 진입, 알림 권한 다이얼로그 없음
- [ ] "켜기" 탭 → iOS 알림 권한 다이얼로그 표시
- [ ] PostHog 대시보드: `onboarding_completed` 이벤트 수신 확인
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` TC-01~TC-14 전체 통과
