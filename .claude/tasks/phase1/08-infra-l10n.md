# Infrastructure: i18n + iCloud Backup — Phase 1

> Agent: Claude Code (architecture decisions) | Codex (ARB strings + iCloud impl)
> PRD ref: Section 15 (i18n structure from Phase 1), Section 16-2 (iCloud strategy)
> RULE 06: No hardcoded Korean strings. RULE 13: i18n structure now, translations Phase 4.
> Issue: #16 | Branch: feat/infra-l10n

## i18n Setup

- [x] Add flutter_localizations to pubspec.yaml (already in flutter SDK, just enable delegates)
- [x] Add intl package to pubspec.yaml
- [x] Create lib/core/l10n/l10n.dart (AppLocalizationsX extension, non-null getter)
- [x] Configure flutter > generate: true in pubspec.yaml
- [x] l10n.yaml at project root (arb-dir, template-arb-file, output-localization-file)

## ARB Files

- [x] lib/core/l10n/app_ko.arb — all Phase 1 Korean strings
- [x] lib/core/l10n/app_en.arb — same keys, English values
- [x] `flutter gen-l10n` — success, AppLocalizations generated

## Replace Hardcoded Strings

- [x] Audit all Phase 1 screens for hardcoded Korean strings
- [x] Replace each with `l10n.{key}` references
- [x] Zero hardcoded Korean strings remaining in lib/

## iCloud Drive Backup

- [x] Add icloud_storage: ^2.0.2, path_provider: ^2.1.4 to pubspec.yaml
- [x] ios/Runner/Runner.entitlements — iCloud container + CloudDocuments
- [x] macos/Runner/DebugProfile.entitlements + Release.entitlements — same + network.client
- [x] lib/core/backup/icloud_backup_service.dart — ICloudBackupService interface + ICloudBackupServiceImpl
- [x] lib/core/backup/backup_providers.dart — @riverpod iCloudBackupServiceProvider
- [x] lib/features/task/data/datasources/in_memory_task_datasource.dart — hydrate()
- [x] lib/features/session/data/datasources/in_memory_session_datasource.dart — hydrate()
- [x] lib/features/session/data/providers/session_providers.dart — inMemorySessionDataSourceProvider (concrete)
- [x] lib/features/task/data/providers/task_data_providers.dart — inMemoryTaskDataSourceProvider (concrete)
- [x] lib/core/backup/backup_restoration_provider.dart — backupRestorationProvider (boot restore) + BackupTriggerNotifier
- [x] lib/main.dart — ProviderContainer + await backupRestorationProvider.future + UncontrolledProviderScope
- [x] lib/features/session/presentation/screens/session_screen.dart — unawaited trigger on TimerCompleted
- [x] test/core/backup/icloud_backup_service_test.dart — 4 tests passing

## Verify

- [x] flutter analyze — 0 issues
- [x] flutter test — 56/56 passed
- [x] Secret scan — 0 results
- [x] flutter-reviewer — HIGH issues fixed (ref.watch→ref.read, catch Error, keepAlive on trigger)
- [ ] ⚠️ Xcode manual setup: Runner target → Signing & Capabilities → + iCloud → Documents (required for real device)
- [ ] iCloud backup file appears in Files app → iCloud Drive after session completes (real device test)
