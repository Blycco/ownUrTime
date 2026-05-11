# iOS App Store Compliance — OwnUrTime
> Read when: preparing for App Store submission, adding new data collection, or handling user accounts.
> Required before first App Store submission — several items are hard blockers.

## PrivacyInfo.xcprivacy (REQUIRED since May 2024)
File location: `ios/Runner/PrivacyInfo.xcprivacy`
Missing = App Store rejection with: **"ITMS-91053: Missing API declaration"**

Minimum declaration for OwnUrTime dependencies:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <!-- flutter_secure_storage → Keychain -->
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>C617.1</string></array>
    </dict>
    <!-- SharedPreferences / NSUserDefaults -->
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>CA92.1</string></array>
    </dict>
  </array>
  <key>NSPrivacyCollectedDataTypes</key>
  <array>
    <!-- Apple Sign In email -->
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeEmailAddress</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <true/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array><string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string></array>
    </dict>
    <!-- Task titles, session records -->
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeOtherUserContent</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <true/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array><string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string></array>
    </dict>
    <!-- PostHog KPI events -->
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeProductInteraction</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <false/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array><string>NSPrivacyCollectedDataTypePurposeAnalytics</string></array>
    </dict>
  </array>
  <key>NSPrivacyTracking</key>
  <false/>
</dict>
</plist>
```

When adding a new package, check its repo for required `PrivacyInfo.xcprivacy` additions.
Reference: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files

## 개인정보처리방침 (PIPA — 한국 개인정보보호법)

**App Store Connect 제출 전 필수:**
- 개인정보처리방침 URL (한국어) → App Store Connect → App Information → Privacy Policy URL
- 앱 설정 화면 내 링크 (탭 가능한 URL)

**처리방침에 명시해야 할 항목:**

| 항목 | OwnUrTime 내용 |
|------|---------------|
| 수집 항목 | 이메일(Apple Sign In 선택 시), 태스크 제목, 세션 기록, 기분 체크(1-5) |
| 수집 목적 | 서비스 제공, 데이터 동기화, 서비스 개선(익명 분석) |
| 보유 기간 | 회원 탈퇴 시 즉시 삭제 (또는 법정 보유 기간) |
| 제3자 제공 | PostHog Inc.(미국/EU, 익명 분석), Supabase Inc.(미국, 데이터 저장) |
| 개인정보 보호책임자 | 이름 + 이메일 (본인 이름 사용 가능, solo dev) |
| 이용자 권리 | 조회·삭제 요청 가능 (앱 내 계정 삭제 기능 필수) |

**앱 내 계정 삭제 기능 (App Store 필수, 2023년~):**
App Store는 계정 생성 앱에 **앱 내 계정 삭제** 기능을 의무화함.
```dart
// AccountDeletionUseCase — 구현 필요 (Phase 1 auth task에 추가)
Future<void> deleteAccount(String userId) async {
  await _taskRepository.deleteAllForUser(userId);
  await _sessionRepository.deleteAllForUser(userId);
  await _supabase.auth.admin.deleteUser(userId); // Edge Function으로 처리
  await _secureStorage.deleteAll();
}
```

## PostHog 데이터 위치 설정
기본값(US 서버)은 PIPA상 개인정보처리방침에 미국 이전 명시 + 동의 필요.
EU 서버 사용 시 간소화 가능:

```dart
// main.dart — EU 서버로 설정
await Posthog().setup(
  'https://eu.posthog.com',  // US: 'https://app.posthog.com'
  const PosthogConfig(apiKey: String.fromEnvironment('POSTHOG_API_KEY')),
);
```

## App Store Connect 제출 체크리스트
- [ ] `ios/Runner/PrivacyInfo.xcprivacy` 파일 존재 및 내용 정확
- [ ] 개인정보처리방침 URL 입력 (한국어 버전)
- [ ] App Privacy 섹션 입력 (수집 데이터 유형 선택 — Data Linked to You)
- [ ] 연령 등급 완료 (ADHD 생산성 앱 → 4+)
- [ ] 암호화 사용 신고: 예 (표준 암호화 — flutter_secure_storage AES)
  - "Does your app use encryption?" → Yes, but only standard encryption algorithms
- [ ] 앱 내 계정 삭제 기능 구현 및 심사 메모에 위치 명시
- [ ] Apple Sign In 버튼 디자인 가이드라인 준수 (검정/흰색 버튼, 최소 크기)

## 암호화 신고 (EAR — Export Administration Regulations)
flutter_secure_storage 사용 시 매년 BIS에 신고 필요.
- 해당: ECCN 5D992 (표준 암호화, 대부분의 앱)
- 신고: App Store Connect → App Information → Encryption → 예, 면제 대상
- 문서 보관: 신고 내용 스크린샷 보관 (감사 대비)
