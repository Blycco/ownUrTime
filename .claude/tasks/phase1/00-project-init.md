# Project Initialization — Phase 1
> Agent: Claude Code (decisions) | Codex (boilerplate)
> Dependency: Must complete before all other phase1 tasks.

## Flutter Project
- [ ] `flutter create --org com.ownurtime --project-name own_ur_time --platforms ios,macos .`
- [ ] Remove generated test/widget_test.dart (replace with real tests later)
- [ ] Add `.env` to `.gitignore`; create `.env.example` with required var names

## pubspec.yaml — Dependencies
- [ ] flutter_riverpod + riverpod_annotation
- [ ] supabase_flutter
- [ ] go_router
- [ ] freezed_annotation + json_annotation
- [ ] flutter_localizations + intl
- [ ] flutter_secure_storage
- [ ] posthog_flutter
- [ ] talker ^4.x
- [ ] talker_riverpod_logger ^4.x

## pubspec.yaml — Dev Dependencies
- [ ] build_runner
- [ ] riverpod_generator
- [ ] freezed
- [ ] json_serializable
- [ ] mockito + build_runner
- [ ] lints (or flutter_lints)
- [ ] talker_flutter ^4.x (in-app log viewer — debug/profile only; never in release)

## analysis_options.yaml
- [ ] Include lints/recommended.yaml
- [ ] Enable strict-casts, strict-inference, strict-raw-types
- [ ] Add avoid_dynamic_calls, prefer_const_constructors rules

## Core Directory Structure
- [ ] Create lib/core/supabase/supabase_config.dart (dart-define constants)
- [ ] Create lib/core/router/app_router.dart (GoRouter, placeholder routes)
- [ ] Create lib/core/theme/app_theme.dart + app_colors.dart (minimal Phase 1 palette)
- [ ] Create lib/core/l10n/ directory (empty ARBs — populated in task 08)
- [ ] Create lib/core/providers/supabase_provider.dart (Provider<SupabaseClient>)
- [ ] Create lib/core/logging/log_context_provider.dart (logUserIdProvider, logSessionIdProvider)
- [ ] Create lib/core/logging/logger_service.dart (LoggerService + loggerServiceProvider)

## main.dart
- [ ] Supabase.initialize() with dart-define URL + anonKey
- [ ] ProviderScope wrapping MaterialApp
- [ ] GoRouter as router
- [ ] l10n delegates + Korean locale

## Verify
- [ ] `flutter pub get` — no errors
- [ ] `flutter analyze` — zero warnings
- [ ] `flutter run` on iOS Simulator — blank app launches without crash
