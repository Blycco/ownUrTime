# Feature: Auth (Guest Mode First) — Phase 1

> Agent: Claude Code (guest→auth flow logic) | Codex (UI + Supabase auth impl)
> PRD ref: Section 7 (onboarding — login = initiation barrier)
> RULE 12: No forced login before 3rd session

## Domain / State

- [x] lib/features/auth/presentation/providers/auth_provider.dart
  - AuthState: sealed (guest / authenticated(User))
  - sessionCompletionCount: int — incremented on each session complete
  - isGuest: bool getter
  - signInWithApple() → Supabase Apple OAuth
  - signOut()
  - Persist sessionCompletionCount locally (SharedPreferences or flutter_secure_storage)

## Guest Mode

- [x] All Phase 1 features work without login:
  - Tasks stored in local state (not Supabase)
  - Sessions tracked locally
  - No network required for core flow
- [x] Local storage: use flutter_secure_storage for task list + session history JSON
- [x] GoRouter: no routes require auth in Phase 1 — auth is always opt-in

## Auth Prompt Trigger

- [x] After 3rd session completion → show sign-in bottom sheet
  - Non-blocking: user can dismiss with "Maybe later"
  - Shows benefit: "Save your progress across devices"
  - Apple Sign In button (required by App Store policy)
  - Dismiss = never show again until next app launch (not persistent nag)

## Data Sync on Sign-In

- [x] On Apple Sign In success:
  - Migrate local tasks → Supabase tasks table (batch insert)
  - Migrate local sessions → Supabase sessions table
  - Clear local storage
  - Switch state to authenticated

## Supabase Auth Integration

- [x] Configure Apple Sign In in Supabase dashboard (done via console, document steps)
- [x] lib/features/auth/data/datasources/auth_remote_datasource.dart
  - signInWithApple() → supabase.auth.signInWithOAuth(OAuthProvider.apple)
  - signOut() → supabase.auth.signOut()
  - getUser() → supabase.auth.currentUser
- [x] Deep link handling for Apple OAuth callback (ios/Runner/Info.plist redirect URL)

## Presentation

- [x] lib/features/auth/presentation/screens/login_screen.dart
  - Apple Sign In button (Sign in with Apple styling guide compliant)
  - "Continue as guest" option
- [x] lib/features/auth/presentation/widgets/sign_in_prompt_sheet.dart
  - Bottom sheet shown after 3rd session
  - Dismissible, non-modal

## Tests

- [x] test/features/auth/domain/auth_provider_test.dart
  - Test: starts in guest state
  - Test: sessionCompletionCount increments on session complete
  - Test: sign-in prompt triggered at count == 3
  - Test: prompt is dismissible without signing in
- [x] test/features/auth/presentation/sign_in_prompt_sheet_test.dart
  - Test: Apple Sign In button visible
  - Test: "Maybe later" dismisses sheet

## Done When

- [x] flutter analyze — zero warnings in features/auth/
- [x] All tests pass
- [x] App launches directly to task list (no login screen)
- [x] All features work in guest mode
- [x] Sign-in prompt appears after exactly 3rd session (non-blocking)
- [x] Sign in syncs local data to Supabase
