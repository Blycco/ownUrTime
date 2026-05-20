# Task 06: Apple Sign In 완성 + PostHog identify — Phase 2

> **선제 조건**: Task 01 완료 (Supabase 연결)
> **Claude Code 담당**: Auth 플로우 완성 설계, PostHog identify 연동 포인트, LoginScreen GoRouter 설계
> **Codex 담당**: 모든 코드 작성 (identify 연결, /login 라우트, QA-01/QA-04 해소, 테스트 전부)
> **PRD ref**: Section 7 (Onboarding), ios-compliance.md
> **Phase 1 미결 항목**: QA-01 (TaskListNotifier userId 불일치), QA-04 (LoginScreen 라우트 없음), identify 미연결

---

## 1. 설계 명세 (Claude Code)

### 1-1. 완성해야 하는 Auth 플로우

```
게스트 모드 시작
    │
    │ 세션 3회 완료
    ▼
SignInPromptSheet (BottomSheet)
    │ "계정 만들기" 탭
    ▼
LoginScreen (/login)
    │ "Sign in with Apple" 탭
    ▼
Supabase Apple OAuth (redirectTo: com.ownurtime.app://login-callback)
    │ 성공
    ▼
authProvider.state = authenticated(AppUser)
    │
    ├─→ analyticsService.identify(userId, email)
    ├─→ MigrateLocalDataUseCase(localTasks, localSessions)
    └─→ GoRouter.go('/tasks')
         │
         └─→ TaskListNotifier ref.watch(authProvider) 반응 → tasks 재로드
```

### 1-2. PostHog identify 연동 + CompleteSignInBootstrapUseCase

<!-- [HIGH-4 FIX] signInWithApple() 오케스트레이션 분리 — UseCase로 추출 -->
<!-- AuthNotifier는 Auth만 담당; Analytics/Migration/RC는 UseCase에서 처리 -->

**CompleteSignInBootstrapUseCase** (신규):
`lib/features/auth/domain/usecases/complete_sign_in_bootstrap_usecase.dart`

```dart
/// 로그인 성공 직후 실행되는 부트스트랩 시퀀스.
/// 각 단계는 독립적으로 실패 가능 — 이전 단계 실패가 다음을 막지 않음.
/// 반환: 각 단계의 성공/실패 결과
class CompleteSignInBootstrapUseCase {
  const CompleteSignInBootstrapUseCase(
    this._analytics, this._migration, this._sessionRepo);
  final AnalyticsService _analytics;
  final MigrationRepository _migration;
  final SessionRepository _sessionRepo;

  Future<BootstrapResult> call(AppUser user) async {
    var analyticsOk = false;
    var migrationOk = false;

    // Step 1: PostHog alias → identify (순서 엄수)
    try {
      await _analytics.alias(user.id);          // 익명→인증 이벤트 병합
      await _analytics.identify(user.id, email: user.email);
      final total = await _sessionRepo.getCompletedCount(user.id);
      await _analytics.setUserProperty('total_sessions_completed', total);
      analyticsOk = true;
    } catch (_) {
      // silently skip — analytics는 핵심 기능 아님
    }

    // Step 2: 로컬 데이터 마이그레이션
    try {
      await _migration.migrateLocalData(user.id);
      migrationOk = true;
    } catch (_) {
      // retry queue는 Task 01 스펙대로 SharedPreferences에 저장
    }

    return BootstrapResult(analyticsOk: analyticsOk, migrationOk: migrationOk);
  }
}

@freezed
class BootstrapResult with _$BootstrapResult {
  const factory BootstrapResult({
    required bool analyticsOk,
    required bool migrationOk,
  }) = _BootstrapResult;
}
```

`AuthNotifier.signInWithApple()` — UseCase 위임:

```dart
Future<void> signInWithApple() async {
  try {
    final user = await _signInWithAppleUseCase();
    state = AuthState.authenticated(user);
    // 오케스트레이션은 UseCase에 위임 (순서: alias → identify → migrate)
    await ref.read(completeSignInBootstrapUseCaseProvider).call(user);
  } on AuthException catch (e) {
    rethrow;
  }
}
```

**AnalyticsService.identify() 인터페이스 확장** (`lib/core/analytics/analytics_service.dart`):

```dart
abstract interface class AnalyticsService {
  // 기존
  Future<void> init();
  Future<void> capture(String event, [Map<String, dynamic>? properties]);

  // 신규 추가
  /// [HIGH-1 FIX] 익명→인증 이벤트 병합: identify() 전에 반드시 호출
  /// PostHog: alias(userId) → 기존 익명 distinctId와 userId를 동일 사용자로 병합
  /// 미호출 시 로그인 전 이벤트(코호트 분석 핵심)가 별도 익명 사용자로 집계됨
  Future<void> alias(String userId);

  /// 로그인 후 사용자 ID 연결. 이후 이벤트에 user_id 속성 자동 포함.
  /// 호출 순서: alias(userId) → identify(userId, email: email)
  Future<void> identify(String userId, {String? email});

  /// 로그아웃 시 PostHog 세션 초기화.
  Future<void> reset();

  /// 사용자 속성 설정 (코호트 분析용).
  // [FIX] dynamic 금지 (RULE 05) → Object 사용
  Future<void> setUserProperty(String key, Object value);
}
```

### 1-3. GoRouter /login 라우트 설계

```dart
// app_router.dart 추가
GoRoute(
  path: '/login',
  builder: (context, state) => const LoginScreen(),
),

// redirect 수정: 로그인 완료 후 /tasks로
// LoginScreen에서 직접 GoRouter.go('/tasks') 처리
```

**SignInPromptSheet → LoginScreen 연결**:

```dart
// sign_in_prompt_sheet.dart
// "계정 만들기" 버튼 탭
onTap: () {
  Navigator.of(context).pop(); // sheet 닫기
  GoRouter.of(context).push('/login');
}
```

### 1-4. QA-01 해소: TaskListNotifier userId 연동

**문제**: Apple Sign In 후 TaskListNotifier가 이전 'guest' userId로 tasks를 보여줌.

**해결**: TaskListNotifier에서 authProvider watch 추가.

```dart
// lib/features/task/presentation/providers/task_provider.dart

@riverpod
class TaskListNotifier extends _$TaskListNotifier {
  @override
  Future<List<Task>> build() async {
    // authProvider watch → sign-in 시 자동 재빌드
    final userId = ref.watch(authProvider).currentUserId;
    final repo = ref.watch(taskRepositoryProvider);
    return repo.getTasks(userId);
  }
}
```

### 1-5. total_sessions_completed 집계

`day_2_return` 이벤트에 실제 카운트 주입:

```dart
// lib/features/session/presentation/providers/timer_provider.dart
// _complete() 메서드에서 day_2_return 이벤트 수정

final sessionCount = await ref.read(userSessionCountProvider.future);
analyticsService.capture('day_2_return', {
  'total_sessions_completed': sessionCount,
});
```

**userSessionCountProvider**:

```dart
@riverpod
Future<int> userSessionCount(Ref ref) async {
  final userId = ref.read(authProvider).currentUserId;
  if (userId == 'guest') return 0;
  final repo = ref.read(sessionRepositoryProvider);
  return repo.getCompletedCount(userId); // SessionRepository에 추가
}
```

**SessionRepository 인터페이스 추가**:

```dart
abstract interface class SessionRepository {
  // 기존 메서드 유지...

  // 신규 추가
  Future<int> getCompletedCount(String userId);
}
```

### 1-6. 에러 케이스

| 상황 | 처리 |
|------|------|
| Apple Sign In 취소 (사용자) | 에러 없이 LoginScreen 유지 (백버튼 동작) |
| Apple Sign In 실패 (네트워크) | SnackBar "연결을 확인해주세요" |
| identify 실패 (PostHog) | silently skip (세션에 user_id 없어도 됨) |
| 마이그레이션 실패 | 로그인은 유지, 마이그레이션 재시도 큐에 등록 — 구현 스펙: SharedPreferences에 `pending_migration_user_id` 저장 → 다음 앱 실행 시 MigrateLocalDataUseCase 재호출 (최대 3회 재시도, 이후 포기 + 로컬 데이터 유지) |
| 5분 타임아웃 초과 (Phase 1 기존 코드) | LoginScreen에서 에러 메시지 |

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task06-auth-complete.md`:

```
Project: OwnUrTime Flutter
Context: Phase 2 Task 06 — Apple Sign In 완성 + PostHog identify.
기존 lib/features/auth/ 수정.

## 항목 1: AnalyticsService 인터페이스 확장
파일: lib/core/analytics/analytics_service.dart
설계 명세 1-2의 신규 메서드 추가:
- identify(userId, {email})
- reset()
- setUserProperty(key, value)

## 항목 2: PostHogAnalyticsService 구현체 확장
파일: lib/core/analytics/posthog_analytics_service.dart
```dart
@override
Future<void> identify(String userId, {String? email}) async {
  if (!_initialized) return;
  await Posthog().identify(
    userId: userId,
    userProperties: email != null ? {'email': email} : null,
  );
}

@override
Future<void> reset() async {
  if (!_initialized) return;
  await Posthog().reset();
}

@override
Future<void> setUserProperty(String key, dynamic value) async {
  if (!_initialized) return;
  await Posthog().identify(
    userId: Posthog().getDistinctId() ?? '',
    userProperties: {key: value},
  );
}
```

## 항목 3: AuthNotifier.signInWithApple() 수정
파일: lib/features/auth/presentation/providers/auth_provider.dart
설계 명세 1-2 코드 적용:
- 성공 후 identify() 호출
- setUserProperty('total_sessions_completed', count) 호출

AuthNotifier.signOut() 수정:
- signOut 후 analyticsService.reset() 호출

## 항목 4: TaskListNotifier authProvider watch 추가
파일: lib/features/task/presentation/providers/task_provider.dart
설계 명세 1-4 코드 적용 (QA-01 해소)

## 항목 5: SessionRepository.getCompletedCount 추가
파일: lib/features/session/domain/repositories/session_repository.dart
인터페이스에 getCompletedCount(String userId) → Future<int> 추가

파일: lib/features/session/data/repositories/session_repository_impl.dart
구현: Supabase `.from('sessions').select('id').eq('user_id', userId).eq('status', 'completed')` COUNT

## 항목 6: userSessionCountProvider + day_2_return 수정
파일: lib/features/session/presentation/providers/timer_provider.dart
설계 명세 1-5 코드 적용 (day_2_return에 실제 카운트 주입)

## 항목 7: GoRouter /login 라우트 추가
파일: lib/core/router/app_router.dart
- /login GoRoute 추가
- redirect: 인증 상태에서 /login 접근 → /tasks로 redirect

## 항목 8: SignInPromptSheet → /login 연결
파일: lib/features/auth/presentation/widgets/sign_in_prompt_sheet.dart
"계정 만들기" 버튼: sheet 닫고 GoRouter.push('/login')

## 항목 9: LoginScreen 수정
파일: lib/features/auth/presentation/screens/login_screen.dart
- 로그인 성공 → GoRouter.go('/tasks')
- 로딩 상태: CircularProgressIndicator (버튼 비활성)
- 에러 상태: SnackBar 표시
- "계속 게스트로" 버튼: GoRouter.go('/tasks')

## 항목 10: QA-04 해소 — LoginScreen 라우트 확인
LoginScreen이 /login 라우트에 연결됨 확인
(Phase 1에서 dead code였던 login_screen.dart 활성화)

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과
```

### 2-2. 구현 파일 목록

| 파일 | 담당 | 비고 |
|------|------|------|
| `lib/core/analytics/analytics_service.dart` | Codex | 인터페이스 확장 |
| `lib/core/analytics/posthog_analytics_service.dart` | Codex | identify/reset/setUserProperty 추가 |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Codex | identify 연결 |
| `lib/features/task/presentation/providers/task_provider.dart` | Codex | authProvider watch (QA-01) |
| `lib/features/session/domain/repositories/session_repository.dart` | Codex | getCompletedCount 추가 |
| `lib/features/session/data/repositories/session_repository_impl.dart` | Codex | getCompletedCount 구현 |
| `lib/features/session/presentation/providers/timer_provider.dart` | Codex | day_2_return 수정 |
| `lib/core/router/app_router.dart` | Codex | /login 추가 |
| `lib/features/auth/presentation/widgets/sign_in_prompt_sheet.dart` | Codex | /login 연결 |
| `lib/features/auth/presentation/screens/login_screen.dart` | Codex | 로그인 성공 redirect |

---

## 3. 테스트 명세

### `test/features/auth/presentation/auth_notifier_test.dart` (신규 케이스 추가)

```
TC-01: signInWithApple 성공 → identify 호출됨
  setup: FakeAuthRepo.signInWithApple() → AppUser(id: 'u1', email: 'a@b.com')
  기대: FakeAnalyticsService.identify('u1', email: 'a@b.com') 호출됨

TC-02: signInWithApple 성공 → state = authenticated(user)
  기대: state == AuthState.authenticated(AppUser(id: 'u1'))

TC-03: signOut → analyticsService.reset() 호출됨
  기대: FakeAnalyticsService.reset() 호출됨

TC-04: signInWithApple 실패 → state 변경 없음 (guest 유지)
  setup: FakeAuthRepo.signInWithApple() → throws AuthException
  기대: state == AuthState.guest()
```

### `test/features/task/presentation/task_list_notifier_test.dart` (QA-01 확인)

```
TC-05: 게스트 → 로그인 → tasks 재로드됨 (authProvider 변경 반응)
  setup:
    1. authProvider.state = guest → taskListNotifier.build() 호출 (userId='guest')
    2. authProvider.state = authenticated(user) → 자동 재빌드
  기대: getTasks('user-id') 호출됨 (getTasks('guest') 이후)
```

### `test/features/session/data/session_repository_impl_test.dart`

```
TC-06: getCompletedCount — 완료된 세션 3개
  setup: FakeDataSource 완료 3, 미완료 2
  기대: getCompletedCount() == 3
```

---

## 4. l10n 추가 (Codex)

`app_ko.arb`:
```json
"loginSignInWithApple": "Apple로 로그인",
"loginContinueAsGuest": "게스트로 계속하기",
"loginSigningIn": "로그인 중...",
"loginErrorNetwork": "연결을 확인해주세요.",
"loginErrorUnknown": "로그인에 실패했어요. 다시 시도해주세요."
```

`app_en.arb`:
```json
"loginSignInWithApple": "Sign in with Apple",
"loginContinueAsGuest": "Continue as Guest",
"loginSigningIn": "Signing in...",
"loginErrorNetwork": "Please check your connection.",
"loginErrorUnknown": "Sign in failed. Please try again."
```

---

## 5. Done When

- [ ] Apple Sign In 성공 → PostHog 대시보드 `identify` 이벤트 + user_id 확인
- [ ] 로그인 후 TaskListScreen에서 tasks 정상 표시 (QA-01 해소)
- [ ] SignInPromptSheet "계정 만들기" → /login 화면 이동
- [ ] LoginScreen 접근 경로: /login GoRoute 정상 동작
- [ ] 로그아웃 → PostHog reset (다음 이벤트에 user_id 없음 확인)
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` TC-01~TC-06 전체 통과

---

## 수동 설정 가이드 (Claude Code가 문서화, Codex 불가)

`docs/guides/xcode-apple-signin.md` 작성:
1. Xcode → Runner target → Signing & Capabilities → `+` → Sign In with Apple 추가
2. `ios/Runner/Runner.entitlements`에 `com.apple.developer.applesignin` 자동 추가 확인
3. Supabase Dashboard → Authentication → Providers → Apple → Bundle ID: `com.ownurtime.ownurtime` 등록
4. Apple Developer → Certificates, Identifiers & Profiles → Keys → Key ID + Team ID Supabase에 입력
