# Project Initialization — Phase 1
> Agent: Claude Code (decisions) | Codex (boilerplate)
> Dependency: Must complete before all other phase1 tasks.

## Flutter Project
- [x] `flutter create --org com.ownurtime --project-name own_ur_time --platforms ios,macos .`
- [x] Remove generated test/widget_test.dart (replaced with GoRouter bootstrap test)
- [x] Add `.env` to `.gitignore`; create `.env.example` with required var names

## pubspec.yaml — Dependencies
- [x] flutter_riverpod + riverpod_annotation (3.3.1 / 4.0.2)
- [x] supabase_flutter (2.12.4)
- [x] go_router (17.2.3)
- [x] freezed_annotation + json_annotation (3.1.0 / 4.11.0)
- [x] flutter_localizations + intl
- [x] flutter_secure_storage (10.2.0)
- [x] posthog_flutter (5.24.2)
- [x] talker (5.1.17)
- [x] talker_riverpod_logger (5.1.17)

## pubspec.yaml — Dev Dependencies
- [x] build_runner (2.15.0)
- [x] riverpod_generator (4.0.3)
- [x] freezed (3.2.5)
- [x] json_serializable (6.13.0)
- [x] mockito (5.6.4)
- [x] flutter_lints (6.0.0)
- [x] talker_flutter (5.1.17)

## analysis_options.yaml
- [x] Include flutter_lints/flutter.yaml
- [x] Enable strict-casts, strict-inference, strict-raw-types
- [x] Add avoid_dynamic_calls, prefer_const_constructors rules

## Core Directory Structure
- [x] Create lib/core/supabase/supabase_config.dart (dart-define constants)
- [x] Create lib/core/router/app_router.dart (GoRouter, placeholder `/` route)
- [x] Create lib/core/theme/app_theme.dart + app_colors.dart (minimal Phase 1 palette)
- [x] Create lib/core/l10n/ (app_ko.arb + app_en.arb skeleton; l10n.yaml; generated app_localizations.dart)
- [x] Create lib/core/providers/supabase_provider.dart (Provider<SupabaseClient>)
- [x] Create lib/core/logging/log_context_provider.dart (logUserIdProvider, logSessionIdProvider)
- [x] Create lib/core/logging/logger_service.dart (LoggerService + loggerServiceProvider + appTalker)

## main.dart
- [x] Supabase.initialize() with dart-define URL + anonKey (conditional — skipped when URL empty)
- [x] ProviderScope wrapping MaterialApp with TalkerRiverpodObserver
- [x] GoRouter as router (appRouter)
- [x] l10n delegates + Korean/English locales

## Verify
- [x] `flutter pub get` — no errors
- [x] `flutter analyze` — zero warnings
- [x] `flutter test` — passed (1 test)
- [x] `flutter build ios --simulator --debug` — success
- [x] `flutter build macos --debug` — success

## Notes
- StateProvider removed in Riverpod 3.x → replaced with NotifierProvider
- Supabase.initialize() is conditional on SUPABASE_URL being non-empty (Task 01에서 실제 값 주입)
- appTalker is module-level Talker shared by LoggerService and TalkerRiverpodObserver
