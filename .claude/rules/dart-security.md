---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
---

# Dart Security Rules — Auto-loaded

## Secrets
- No hardcoded credentials — use `--dart-define` for compile-time config
- Runtime secrets (tokens, keys): `flutter_secure_storage` only (Keychain on iOS, EncryptedSharedPreferences on Android)
- `.env` file never committed; listed in `.gitignore`

## Logging
**Allowed:**
- Levels: CRITICAL / ERROR / WARNING in release; + INFO / DEBUG in debug builds
- Context fields: userId (anonymous ID only), sessionId, feature name, error code
- Stack traces: always include on ERROR and CRITICAL

**Prohibited (PII & secrets):**
- Email addresses, phone numbers, names
- Task title content (use task ID only: `{'taskId': task.id}`)
- Mood check values (health-sensitive data)
- Any auth tokens, Supabase keys, Gemini API keys
- Gemini API response body (may contain user-input content)
- Device identifiers (IDFA, IDFV)

**Rules:**
- Use `LoggerService` (`lib/core/logging/`) — never call `Talker` or `print()` directly
- No log calls in `presentation/screens/` or `presentation/widgets/`
- `debugPrint()` is investigation-only (see `/debug` skill) — remove before commit
- VERBOSE logs must be removed before committing: `grep -rn "talker.verbose\|\.verbose(" lib/` → 0 results

## Supabase Specific
- Anon key is safe in client — but `service_role` key is NEVER in Flutter code
- RLS enabled on every table — `auth.uid() = user_id` policy required
- Supabase calls from datasource layer only; never from UI widgets
- `service_role` key only in Supabase Edge Functions (server-side)

## Network
- HTTPS only; no plain HTTP endpoints
- Set request timeouts on all network calls
- Validate deep links before navigation: `Uri.tryParse()` then check host

## Input Validation
- Validate and sanitize all user input before sending to Supabase
- Parameterized queries only (Supabase client handles this — never string-concat SQL)

## Storage
- Sensitive data (auth tokens, session state) in `flutter_secure_storage` only
- Never store tokens in `SharedPreferences` or local files

## Release Builds
- Obfuscate: `flutter build ipa --obfuscate --split-debug-info=./debug-info/`
- Keep `--split-debug-info` output out of version control

## Platform
- Android: minimize permissions; `android:exported="false"` on unexported components
- iOS: declare only necessary usage descriptions in `Info.plist`
- iOS: `PrivacyInfo.xcprivacy` required for App Store — see `.claude/context/ios-compliance.md`

## Edge Function Security
- Every Edge Function validates `Authorization: Bearer <JWT>` (Supabase verifies automatically via `createClient`)
- Rate limit `decompose-task`: 10 calls/day per `user_id` — enforce in function, not client
- `SUPABASE_SERVICE_ROLE_KEY` only in Supabase Edge Function env vars (set in Supabase dashboard); never in Flutter
- `GEMINI_API_KEY` only in Edge Function env vars; never in Flutter or Git

## Supply Chain
- `flutter pub audit` in every CI run — blocks merge if HIGH/CRITICAL vulnerabilities found
- Pin Flutter SDK version in CI (`flutter-version: '3.x'`) — don't use `latest`
- Review new package licenses before adding (no GPL in commercial app)

## OWASP Mobile Top 10 (enforced)
| Risk | Mitigation |
|------|-----------|
| M1: Improper credential usage | `--dart-define` + `flutter_secure_storage`; no hardcoded keys |
| M2: Inadequate supply chain | `flutter pub audit` in CI |
| M5: Insecure communication | HTTPS only; never catch `CertificateException` silently |
| M7: Insufficient binary protections | `--obfuscate --split-debug-info` on all release builds |
| M8: Security misconfiguration | RLS on all tables; `service_role` never in client |

## PIPA (Korean Personal Information Protection Act)
- Collect minimum data: email (optional, Apple Sign In only), session/task data, mood level
- Account deletion flow required: wipe all user data on `deleteAccount()` (see `ios-compliance.md`)
- PostHog: use EU server (`eu.posthog.com`) to simplify PIPA cross-border transfer compliance
- Privacy policy URL required in App Store Connect before submission
