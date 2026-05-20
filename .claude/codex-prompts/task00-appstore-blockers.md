# Task 00: 앱스토어 블로커 해소 — Codex 구현 프롬프트

작업 디렉토리: /Users/verity/develop/project/ownUrTime
브랜치: feat/phase2-task00-appstore-blockers
이슈: Ref: #20

## 필수 규칙
- `package:` import만 사용 (상대 import 금지)
- bang(`!`) 연산자 금지 — null-aware 또는 pattern matching 사용
- `dart format` + `flutter analyze` zero warnings 필수
- 모든 로컬 변수 `final`
- `context.mounted` 확인 — 모든 `await` 이후 위젯에서 필수

---

## 항목 1: PrivacyInfo.xcprivacy 생성 (iOS + macOS)

### 1-a. `ios/Runner/PrivacyInfo.xcprivacy` 생성

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyTracking</key>
  <false/>

  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>C617.1</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>CA92.1</string>
      </array>
    </dict>
  </array>

  <key>NSPrivacyCollectedDataTypes</key>
  <array>
    <dict>
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

### 1-b. `macos/Runner/PrivacyInfo.xcprivacy` 생성

내용 동일 (위 XML 그대로).

> ⚠️ 주의: Xcode 프로젝트 파일(.pbxproj) 등록은 수동 작업 필요.
> 파일 생성 후 사용자에게 안내: "Xcode → Runner target → Add Files to Runner → Target Membership: Runner 체크 (iOS + macOS 각각)"

---

## 항목 2: Supabase CASCADE 삭제 마이그레이션

파일: `supabase/migrations/20260518000000_add_cascade_delete.sql` (신규)

```sql
-- user_profiles: CASCADE
ALTER TABLE user_profiles
  DROP CONSTRAINT user_profiles_id_fkey,
  ADD CONSTRAINT user_profiles_id_fkey
    FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- tasks: CASCADE
ALTER TABLE tasks
  DROP CONSTRAINT tasks_user_id_fkey,
  ADD CONSTRAINT tasks_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- sessions: CASCADE
ALTER TABLE sessions
  DROP CONSTRAINT sessions_user_id_fkey,
  ADD CONSTRAINT sessions_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- mood_checks: CASCADE
ALTER TABLE mood_checks
  DROP CONSTRAINT IF EXISTS mood_checks_user_id_fkey,
  ADD CONSTRAINT mood_checks_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
```

---

## 항목 3: Edge Function 생성

파일: `supabase/functions/delete-account/index.ts` (신규)

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

  const token = authHeader.replace('Bearer ', '')
  const { data: { user }, error: authError } = await supabase.auth.getUser(token)
  if (authError || !user) return new Response('Unauthorized', { status: 401 })

  const { error } = await supabase.auth.admin.deleteUser(user.id)
  if (error) return new Response(error.message, { status: 500 })

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

---

## 항목 4: AuthRemoteDataSource 인터페이스 + 구현 확장

파일: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

기존 `AuthRemoteDataSource` 인터페이스에 추가:
```dart
/// Edge Function 호출로 서버 데이터 삭제 후 Supabase 세션 초기화.
/// Throws [DeleteAccountException] on failure.
Future<void> deleteAccount(String userId);
```

기존 `SupabaseAuthDataSource` 클래스에 추가:
```dart
@override
Future<void> deleteAccount(String userId) async {
  try {
    final session = _client.auth.currentSession;
    if (session == null) {
      throw const DeleteAccountException('auth_expired');
    }
    await _client.functions.invoke(
      'delete-account',
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );
    await _client.auth.signOut();
  } on FunctionException catch (e) {
    throw DeleteAccountException(e.details?.toString() ?? 'server_error');
  } on DeleteAccountException {
    rethrow;
  } catch (_) {
    throw const DeleteAccountException('network_error');
  }
}
```

Import 추가:
```dart
import 'package:ownurtime/features/auth/domain/exceptions/auth_exceptions.dart';
```

---

## 항목 5: AuthLocalDataSource.clearAll() 전체 삭제로 수정

파일: `lib/features/auth/data/datasources/auth_local_datasource.dart`

기존 `clearAll()` 구현을 수정 (특정 키 삭제 → 전체 삭제):
```dart
@override
Future<void> clearAll() => _storage.deleteAll();
```

---

## 항목 6: AuthRepositoryImpl.deleteAccount() 추가

파일: `lib/features/auth/data/repositories/auth_repository_impl.dart`

기존 클래스에 추가:
```dart
@override
Future<void> deleteAccount(String userId) async {
  await _remote.deleteAccount(userId);
  await _local.clearAll();
}
```

---

## 항목 7: AuthNotifier.deleteAccount() 추가

파일: `lib/features/auth/presentation/providers/auth_provider.dart`

기존 `AuthNotifier` 클래스에 추가:
```dart
Future<void> deleteAccount() async {
  final currentState = state.value;
  if (currentState == null) return;
  final userId = currentState.whenOrNull(authenticated: (user) => user.id);
  if (userId == null) return;

  final repo = ref.read(authRepositoryProvider);
  final useCase = DeleteAccountUseCase(repo);
  await useCase(userId);
  state = const AsyncData(AuthState.guest());
}
```

Import 추가:
```dart
import 'package:ownurtime/features/auth/domain/usecases/delete_account_usecase.dart';
```

---

## 항목 8: 계정 삭제 확인 다이얼로그

파일: `lib/features/settings/presentation/widgets/delete_account_dialog.dart` (신규, 디렉토리 포함)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('계정을 삭제할까요?'),
      content: const Text(
        '모든 작업 기록과 데이터가 영구 삭제됩니다. 이 작업은 되돌릴 수 없어요.',
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _loading ? null : _onDelete,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('삭제'),
        ),
      ],
    );
  }

  Future<void> _onDelete() async {
    setState(() => _loading = true);
    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      if (!mounted) return;
      context.go('/tasks');
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류가 발생했어요. 다시 시도해주세요.')),
      );
    }
  }
}
```

---

## 항목 9: 설정 화면

파일: `lib/features/settings/presentation/screens/settings_screen.dart` (신규)

```dart
import 'package:flutter/material.dart';
import 'package:ownurtime/features/settings/presentation/widgets/delete_account_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('개인정보처리방침'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/privacy-policy'),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              '계정 삭제',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => const DeleteAccountDialog(),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 항목 10: 개인정보처리방침 화면

파일: `lib/features/settings/presentation/screens/privacy_policy_screen.dart` (신규)

```dart
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '개인정보처리방침\n\n'
          '본 앱은 Apple Sign In을 통해 이메일 주소(선택)를 수집합니다. '
          '수집된 정보는 앱 기능 제공 목적으로만 사용됩니다.\n\n'
          '사용자는 언제든지 계정 삭제를 통해 모든 데이터를 영구 삭제할 수 있습니다.\n\n'
          '문의: support@ownurtime.app',
        ),
      ),
    );
  }
}
```

---

## 항목 11: GoRouter 라우트 추가

파일: `lib/core/router/app_router.dart`

기존 라우트 목록에 `/settings`와 `/privacy-policy` 추가.
`GoRoute` 패턴은 기존 코드와 동일하게 따를 것.

---

## 항목 12: TaskListScreen AppBar 설정 아이콘 추가

`lib/features/tasks/presentation/screens/task_list_screen.dart` (또는 동등한 홈 화면)의 AppBar에:
```dart
actions: [
  IconButton(
    icon: const Icon(Icons.settings_outlined),
    onPressed: () => context.push('/settings'),
  ),
],
```

---

## 항목 13: CI flutter pub audit 추가

파일: `.github/workflows/quality-gates.yml`

기존 `Tests` 단계 뒤에 추가:
```yaml
      - name: Security audit
        if: steps.detect.outputs.has_flutter == 'true'
        run: flutter pub audit
```

---

## 항목 14: l10n 키 추가

파일: `lib/core/l10n/app_ko.arb`
파일: `lib/core/l10n/app_en.arb`

app_ko.arb에 추가:
```json
"settingsTitle": "설정",
"settingsDeleteAccount": "계정 삭제",
"settingsPrivacyPolicy": "개인정보처리방침",
"deleteAccountDialogTitle": "계정을 삭제할까요?",
"deleteAccountDialogBody": "모든 작업 기록과 데이터가 영구 삭제됩니다. 이 작업은 되돌릴 수 없어요.",
"deleteAccountDialogCancel": "취소",
"deleteAccountDialogConfirm": "삭제",
"deleteAccountSuccess": "계정이 삭제되었어요.",
"deleteAccountErrorNetwork": "네트워크 오류가 발생했어요. 다시 시도해주세요.",
"deleteAccountErrorServer": "서버 오류가 발생했어요. 잠시 후 다시 시도해주세요.",
"settingsAppBarAction": "설정"
```

app_en.arb에 추가:
```json
"settingsTitle": "Settings",
"settingsDeleteAccount": "Delete Account",
"settingsPrivacyPolicy": "Privacy Policy",
"deleteAccountDialogTitle": "Delete your account?",
"deleteAccountDialogBody": "All your tasks and data will be permanently deleted. This cannot be undone.",
"deleteAccountDialogCancel": "Cancel",
"deleteAccountDialogConfirm": "Delete",
"deleteAccountSuccess": "Your account has been deleted.",
"deleteAccountErrorNetwork": "Network error. Please try again.",
"deleteAccountErrorServer": "Server error. Please try again later.",
"settingsAppBarAction": "Settings"
```

---

## 항목 15: 테스트 작성

### 15-a. `test/features/auth/domain/delete_account_usecase_test.dart`

```
TC-01: deleteAccount 성공
  FakeAuthRepo.deleteAccount → completes normally
  기대: useCase('user-123') completes without exception

TC-02: deleteAccount 네트워크 오류
  FakeAuthRepo.deleteAccount → throws DeleteAccountException('network_error')
  기대: useCase.call() rethrows DeleteAccountException

TC-03: 게스트 상태에서 AuthNotifier.deleteAccount() 호출
  AuthNotifier.state = AsyncData(AuthState.guest())
  기대: 예외 없이 종료, state 변경 없음
```

### 15-b. `test/features/settings/presentation/delete_account_dialog_test.dart`

```
TC-04: 다이얼로그 렌더링
  기대: "계정을 삭제할까요?" 텍스트, "취소" 버튼, "삭제" 버튼 존재

TC-05: 취소 버튼 탭
  기대: 다이얼로그 닫힘, deleteAccount() 미호출

TC-06: 삭제 버튼 탭 → 성공
  FakeAuthNotifier.deleteAccount() → completes
  기대: loading 표시 → /tasks 라우트 이동
```

---

## 완료 조건

- `flutter analyze`: 0 warnings
- `flutter test`: TC-01 ~ TC-06 전체 통과
- `ios/Runner/PrivacyInfo.xcprivacy` 파일 존재
- `macos/Runner/PrivacyInfo.xcprivacy` 파일 존재
- `supabase/functions/delete-account/index.ts` 파일 존재
- `supabase/migrations/20260518000000_add_cascade_delete.sql` 파일 존재
