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

## Privacy Policy (PIPA — Korean Personal Information Protection Act)

**Required before App Store Connect submission:**
- Privacy Policy URL (Korean) → App Store Connect → App Information → Privacy Policy URL
- In-app settings screen link (tappable URL)

**Required disclosures in the privacy policy:**

| Item | OwnUrTime content |
|------|------------------|
| Data collected | Email (if Apple Sign In used), task titles, session records, mood checks (1–5) |
| Purpose | Service provision, data sync, service improvement (anonymous analytics) |
| Retention | Deleted immediately on account deletion (or statutory retention period) |
| Third parties | PostHog Inc. (US/EU, anonymous analytics), Supabase Inc. (US, data storage) |
| Privacy officer | Name + email (solo dev may use own name) |
| User rights | Right to access/delete (in-app account deletion required) |

**In-app account deletion (App Store mandatory since 2023):**
App Store requires **in-app account deletion** for any app that creates accounts.
```dart
// AccountDeletionUseCase — implement in Phase 1 auth task
Future<void> deleteAccount(String userId) async {
  await _taskRepository.deleteAllForUser(userId);
  await _sessionRepository.deleteAllForUser(userId);
  await _supabase.auth.admin.deleteUser(userId); // handle via Edge Function
  await _secureStorage.deleteAll();
}
```

## PostHog Data Region
Default (US server) requires explicit US transfer disclosure + consent under PIPA.
Using EU server simplifies compliance:

```dart
// main.dart — set EU server
await Posthog().setup(
  'https://eu.posthog.com',  // US: 'https://app.posthog.com'
  const PosthogConfig(apiKey: String.fromEnvironment('POSTHOG_API_KEY')),
);
```

## App Store Connect Submission Checklist
- [ ] `ios/Runner/PrivacyInfo.xcprivacy` exists and content is accurate
- [ ] Privacy Policy URL entered (Korean version)
- [ ] App Privacy section filled (data type selection — Data Linked to You)
- [ ] Age rating complete (ADHD productivity app → 4+)
- [ ] Encryption declaration: Yes (standard encryption — flutter_secure_storage AES)
  - "Does your app use encryption?" → Yes, but only standard encryption algorithms
- [ ] In-app account deletion implemented; location noted in review notes
- [ ] Apple Sign In button follows design guidelines (black/white, minimum size)

## Encryption Declaration (EAR — Export Administration Regulations)
Annual BIS filing required when using flutter_secure_storage.
- Classification: ECCN 5D992 (standard encryption, most apps qualify)
- Filing: App Store Connect → App Information → Encryption → Yes, exempt
- Record-keeping: screenshot of filing for audit purposes
