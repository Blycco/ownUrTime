# Task 00: 앱스토어 블로커 해소 — Phase 2

> **선제 조건**: 없음 (Phase 2 최우선)
> **Claude Code 담당**: PrivacyInfo 내용 설계, deleteAccount 인터페이스/UseCase 설계, CI 설정 설계
> **Codex 담당**: 파일 생성, SQL 작성, CI yml 수정, 설정 화면 UI 구현, 테스트 작성
> **PRD ref**: ios-compliance.md, dart-security.md
> **읽기**: `.claude/context/ios-compliance.md`, `.claude/context/dart-patterns.md`
> **Block**: 이 태스크 완료 전 TestFlight 제출 불가

---

## 1. 설계 명세 (Claude Code)

### 1-1. PrivacyInfo.xcprivacy 내용

`ios/Runner/PrivacyInfo.xcprivacy` 및 `macos/Runner/PrivacyInfo.xcprivacy` 동일 내용:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- 추적 없음 -->
  <key>NSPrivacyTracking</key>
  <false/>

  <!-- 사용하는 Required Reason API -->
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <!-- flutter_secure_storage → Keychain (File timestamp) -->
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>C617.1</string>
      </array>
    </dict>
    <dict>
      <!-- shared_preferences → NSUserDefaults -->
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>CA92.1</string>
      </array>
    </dict>
  </array>

  <!-- 수집하는 데이터 타입 -->
  <key>NSPrivacyCollectedDataTypes</key>
  <array>
    <dict>
      <!-- Apple Sign In 이메일 (선택, 사용자 제공) -->
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeEmailAddress</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <true/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
      </array>
    </dict>
    <dict>
      <!-- tasks, sessions (사용자 생성 콘텐츠) -->
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeOtherUserContent</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <true/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
      </array>
    </dict>
    <dict>
      <!-- PostHog 이벤트 (제품 상호작용) -->
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeProductInteraction</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <false/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
      </array>
    </dict>
  </array>
</dict>
</plist>
```

**Xcode 추가 방법** (수동, Codex 불가):
1. Xcode → Runner target 우클릭 → Add Files to "Runner"
2. `ios/Runner/PrivacyInfo.xcprivacy` 선택 → Target Membership: Runner 체크
3. macos 동일 반복

### 1-2. deleteAccount 인터페이스 설계

**AuthRepository 인터페이스 확장** (`lib/features/auth/domain/repositories/auth_repository.dart`):

```dart
abstract interface class AuthRepository {
  // 기존 메서드 유지
  Future<AppUser> signInWithApple();
  Future<void> signOut();
  AppUser? getPersistedUser();

  // 신규 추가
  /// 계정 및 모든 사용자 데이터를 영구 삭제한다.
  /// 1. Supabase: 모든 관련 테이블 데이터 삭제 (RLS CASCADE)
  /// 2. Supabase Auth: 사용자 계정 삭제
  /// 3. 로컬: SecureStorage 초기화
  /// Throws [DeleteAccountException] on failure.
  Future<void> deleteAccount(String userId);
}
```

**DeleteAccountUseCase** (`lib/features/auth/domain/usecases/delete_account_usecase.dart`):

```dart
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call(String userId) => _repository.deleteAccount(userId);
}
```

**DeleteAccountException** (`lib/features/auth/domain/exceptions/auth_exceptions.dart` 기존 파일에 추가):

```dart
class DeleteAccountException implements Exception {
  const DeleteAccountException(this.message);
  final String message;

  @override
  String toString() => 'DeleteAccountException: $message';
}
```

### 1-3. Supabase 계정 삭제 설계

`supabase/migrations/20260518000000_add_cascade_delete.sql`:

```sql
-- user_profiles: user_id 삭제 시 CASCADE
ALTER TABLE user_profiles
  DROP CONSTRAINT user_profiles_id_fkey,
  ADD CONSTRAINT user_profiles_id_fkey
    FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- tasks: user_id 삭제 시 CASCADE
ALTER TABLE tasks
  DROP CONSTRAINT tasks_user_id_fkey,
  ADD CONSTRAINT tasks_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- sessions: user_id 삭제 시 CASCADE
ALTER TABLE sessions
  DROP CONSTRAINT sessions_user_id_fkey,
  ADD CONSTRAINT sessions_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- distractions: session_id → sessions CASCADE (이미 있으면 skip)
-- mood_checks: user_id CASCADE
ALTER TABLE mood_checks
  DROP CONSTRAINT IF EXISTS mood_checks_user_id_fkey,
  ADD CONSTRAINT mood_checks_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
```

**Supabase Edge Function** `supabase/functions/delete-account/index.ts`:

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) return new Response('Unauthorized', { status: 401 })

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // JWT에서 user_id 추출
  const token = authHeader.replace('Bearer ', '')
  const { data: { user }, error: authError } = await supabase.auth.getUser(token)
  if (authError || !user) return new Response('Unauthorized', { status: 401 })

  // auth.users 삭제 → CASCADE로 모든 테이블 자동 삭제
  const { error } = await supabase.auth.admin.deleteUser(user.id)
  if (error) return new Response(error.message, { status: 500 })

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### 1-4. 에러 케이스

| 상황 | 에러 | 처리 |
|------|------|------|
| Edge Function 호출 실패 (네트워크) | `DeleteAccountException('network_error')` | 다이얼로그: "네트워크 오류. 다시 시도해주세요." |
| 인증 토큰 만료 | `DeleteAccountException('auth_expired')` | 재로그인 유도 |
| 서버 오류 (500) | `DeleteAccountException('server_error')` | 다이얼로그 + 고객 지원 링크 |
| 이미 삭제된 계정 | Supabase 404 | 로컬 초기화 후 게스트 모드로 전환 |

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task00-appstore-blockers.md`에 저장 후 실행:

```
Project: OwnUrTime Flutter (lib/, test/, supabase/)
Context: Phase 2 Task 00 — 앱스토어 블로커 해소

아래 항목을 순서대로 구현해줘. 각 항목 완료 후 flutter analyze 실행.

## 항목 1: PrivacyInfo.xcprivacy 파일 생성
- `ios/Runner/PrivacyInfo.xcprivacy` 생성 (내용은 task 파일의 설계 명세 그대로)
- `macos/Runner/PrivacyInfo.xcprivacy` 생성 (동일 내용)
- 주의: Xcode 프로젝트 파일 추가는 수동 작업 필요 (문서에 안내 문구 작성)

## 항목 2: 계정 삭제 Supabase 마이그레이션
- `supabase/migrations/20260518000000_add_cascade_delete.sql` 작성
- 내용: 설계 명세 1-3 SQL 그대로

## 항목 3: Edge Function 생성
- `supabase/functions/delete-account/index.ts` 생성
- 내용: 설계 명세 1-3 TypeScript 그대로

## 항목 4: DeleteAccountUseCase 구현
파일: `lib/features/auth/domain/usecases/delete_account_usecase.dart`
- 설계 명세 1-2의 코드 그대로 작성

## 항목 5: SupabaseAuthDataSource.deleteAccount() 구현
파일: `lib/features/auth/data/datasources/auth_remote_datasource.dart`
기존 클래스에 추가:
```dart
@override
Future<void> deleteAccount(String userId) async {
  try {
    final session = _client.auth.currentSession;
    if (session == null) throw const DeleteAccountException('auth_expired');
    await _client.functions.invoke(
      'delete-account',
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );
    // 로컬 SecureStorage 초기화
    await _secureStorage.deleteAll();
  } on FunctionException catch (e) {
    throw DeleteAccountException(e.details?.toString() ?? 'server_error');
  } catch (_) {
    throw const DeleteAccountException('network_error');
  }
}
```

## 항목 6: AuthRepositoryImpl.deleteAccount() 구현
파일: `lib/features/auth/data/repositories/auth_repository_impl.dart`
기존 클래스에 추가:
```dart
@override
Future<void> deleteAccount(String userId) =>
    _remoteDataSource.deleteAccount(userId);
```

## 항목 7: AuthNotifier.deleteAccount() 추가
파일: `lib/features/auth/presentation/providers/auth_provider.dart`
기존 AuthNotifier에 추가:
```dart
Future<void> deleteAccount() async {
  final userId = state.whenOrNull(authenticated: (user) => user.id);
  if (userId == null) return;
  // [FIX] usecase 성공 후 상태 전환 — 먼저 전환하면 실패 시 불일치
  await _deleteAccountUseCase(userId);
  state = const AuthState.guest();
}
```

## 항목 8: 계정 삭제 확인 다이얼로그 위젯
파일: `lib/features/settings/presentation/widgets/delete_account_dialog.dart`
- showDialog로 호출하는 stateless 위젯
- 제목: "계정을 삭제할까요?"
- 내용: "모든 작업 기록과 데이터가 영구 삭제됩니다. 이 작업은 되돌릴 수 없어요."
- 버튼: "취소" (secondary) / "삭제" (destructive red)
- "삭제" 탭 → loading indicator → deleteAccount() 호출 → 완료 시 GoRouter.go('/tasks')

## 항목 9: 설정 화면에 계정 삭제 메뉴 추가
파일: `lib/features/settings/presentation/screens/settings_screen.dart` (없으면 신규 생성)
- ListTile: "계정 삭제", 빨간 색상, 탭 시 DeleteAccountDialog 표시
- GoRouter: `/settings` 라우트 추가 (app_router.dart)
- TaskListScreen AppBar에 설정 아이콘 추가

## 항목 10: Privacy Policy 화면
파일: `lib/features/settings/presentation/screens/privacy_policy_screen.dart`
- Scaffold + SingleChildScrollView + 텍스트 (한국어 개인정보처리방침 placeholder)
- 상단 AppBar: "개인정보처리방침"
- GoRouter: `/privacy-policy` 라우트 추가
- SettingsScreen에서 진입 가능

## 항목 11: CI flutter pub audit 추가
파일: `.github/workflows/quality-gates.yml`
기존 flutter test 단계 뒤에 추가:
```yaml
- name: Security audit
  run: flutter pub audit
  # HIGH/CRITICAL 발견 시 CI 자동 실패
```

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과
- PrivacyInfo.xcprivacy 두 파일 존재 확인
- Edge Function 파일 존재 확인
```

### 2-2. 구현 파일 목록

| 파일 | 담당 | 비고 |
|------|------|------|
| `ios/Runner/PrivacyInfo.xcprivacy` | Codex | 설계 명세 그대로 |
| `macos/Runner/PrivacyInfo.xcprivacy` | Codex | 동일 |
| `supabase/migrations/20260518000000_add_cascade_delete.sql` | Codex | |
| `supabase/functions/delete-account/index.ts` | Codex | |
| `lib/features/auth/domain/usecases/delete_account_usecase.dart` | Codex | |
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | Codex | 기존 파일 확장 |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Codex | 기존 파일 확장 |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Codex | 기존 파일 확장 |
| `lib/features/settings/presentation/widgets/delete_account_dialog.dart` | Codex | |
| `lib/features/settings/presentation/screens/settings_screen.dart` | Codex | |
| `lib/features/settings/presentation/screens/privacy_policy_screen.dart` | Codex | |
| `lib/core/router/app_router.dart` | Codex | /settings, /privacy-policy 추가 |
| `.github/workflows/quality-gates.yml` | Codex | pub audit 추가 |

---

## 3. 테스트 명세

### 테스트 파일: `test/features/auth/domain/delete_account_usecase_test.dart`

```
TC-01: deleteAccount 성공
  입력: userId = 'user-123', FakeAuthRepo.deleteAccount → completes normally
  기대: usecase.call('user-123') completes without exception

TC-02: deleteAccount 네트워크 오류
  입력: FakeAuthRepo.deleteAccount → throws DeleteAccountException('network_error')
  기대: usecase.call() rethrows DeleteAccountException

TC-03: 게스트 상태에서 deleteAccount 호출
  입력: AuthNotifier.state = AuthState.guest(), deleteAccount() 호출
  기대: 예외 없이 종료 (no-op), state 변경 없음
```

### 테스트 파일: `test/features/auth/presentation/delete_account_dialog_test.dart`

```
TC-04: 다이얼로그 렌더링
  기대: "계정을 삭제할까요?" 텍스트 존재, "취소" 버튼 존재, "삭제" 버튼 존재

TC-05: 취소 버튼 탭
  기대: 다이얼로그 닫힘, deleteAccount() 미호출

TC-06: 삭제 버튼 탭 → 성공
  FakeAuthNotifier: deleteAccount() → completes
  기대: 로딩 → /tasks 라우트 이동
```

---

## 4. l10n 추가 (Codex)

`lib/l10n/app_ko.arb` 및 `lib/l10n/app_en.arb`에 추가:

```json
// ko
"settingsTitle": "설정",
"settingsDeleteAccount": "계정 삭제",
"settingsPrivacyPolicy": "개인정보처리방침",
"deleteAccountDialogTitle": "계정을 삭제할까요?",
"deleteAccountDialogBody": "모든 작업 기록과 데이터가 영구 삭제됩니다. 이 작업은 되돌릴 수 없어요.",
"deleteAccountDialogCancel": "취소",
"deleteAccountDialogConfirm": "삭제",
"deleteAccountSuccess": "계정이 삭제되었어요.",
"deleteAccountErrorNetwork": "네트워크 오류가 발생했어요. 다시 시도해주세요.",
"deleteAccountErrorServer": "서버 오류가 발생했어요. 잠시 후 다시 시도해주세요."

// en
"settingsTitle": "Settings",
"settingsDeleteAccount": "Delete Account",
"settingsPrivacyPolicy": "Privacy Policy",
"deleteAccountDialogTitle": "Delete your account?",
"deleteAccountDialogBody": "All your tasks and data will be permanently deleted. This cannot be undone.",
"deleteAccountDialogCancel": "Cancel",
"deleteAccountDialogConfirm": "Delete",
"deleteAccountSuccess": "Your account has been deleted.",
"deleteAccountErrorNetwork": "Network error. Please try again.",
"deleteAccountErrorServer": "Server error. Please try again later."
```

---

## 5. Done When

- [ ] `ios/Runner/PrivacyInfo.xcprivacy` 파일 존재
- [ ] `macos/Runner/PrivacyInfo.xcprivacy` 파일 존재
- [ ] Xcode에서 PrivacyInfo.xcprivacy가 Runner target에 포함됨 (수동 확인)
- [ ] `supabase db reset` 통과 (CASCADE 마이그레이션 적용)
- [ ] 실기기 또는 Supabase 대시보드: 계정 삭제 후 auth.users 레코드 없음 확인
- [ ] 삭제 후 앱 재시작 → 게스트 모드로 진입
- [ ] `flutter pub audit` 0 HIGH/CRITICAL (CI 통과)
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` 전체 통과
- [ ] App Store Connect Privacy Policy URL 필드 등록 (수동, 출시 전)
