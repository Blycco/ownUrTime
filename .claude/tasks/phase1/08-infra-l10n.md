# Infrastructure: i18n + iCloud Backup — Phase 1
> Agent: Claude Code (architecture decisions) | Codex (ARB strings + iCloud impl)
> PRD ref: Section 15 (i18n structure from Phase 1), Section 16-2 (iCloud strategy)
> RULE 06: No hardcoded Korean strings. RULE 13: i18n structure now, translations Phase 4.

## i18n Setup (Claude Code)
- [ ] Add flutter_localizations to pubspec.yaml (already in flutter SDK, just enable delegates)
- [ ] Add intl package to pubspec.yaml
- [ ] Create lib/core/l10n/l10n.dart:
  ```dart
  import 'package:flutter_gen/gen_l10n/app_localizations.dart';
  export 'package:flutter_gen/gen_l10n/app_localizations.dart';
  extension AppLocalizationsX on BuildContext {
    AppLocalizations get l10n => AppLocalizations.of(this)!;
  }
  ```
- [ ] Configure flutter > generate: true in pubspec.yaml
- [ ] Add l10n.yaml at project root:
  ```yaml
  arb-dir: lib/core/l10n
  template-arb-file: app_ko.arb
  output-localization-file: app_localizations.dart
  ```

## ARB Files (Codex)
- [ ] lib/core/l10n/app_ko.arb — all Korean strings for Phase 1 features:
  - task_list_empty_title, task_list_empty_subtitle
  - micro_start_button_label ("지금 2분만")
  - session_distracted_button ("잠깐 끊김")
  - session_reset_button, session_extend_button
  - recovery_type_urgent, recovery_type_impulsive, recovery_type_rest
  - context_restore_card_task_label, context_restore_card_step_label
  - mood_check_title, mood_check_skip
  - ai_limit_remaining ("{count}회 남음"), ai_limit_reached ("오늘 열심히 하셨네요!")
  - completion_reward_message
  - sign_in_prompt_title, sign_in_prompt_subtitle, sign_in_prompt_dismiss
  - (complete list — add as screens are built)
- [ ] lib/core/l10n/app_en.arb — same keys, English values (structure only for Phase 4)
- [ ] Run `flutter gen-l10n` — verify no generation errors

## Replace Hardcoded Strings
- [ ] Audit all Phase 1 screens for hardcoded Korean strings
- [ ] Replace each with `context.l10n.{key}` reference
- [ ] Zero hardcoded Korean strings in lib/ after this task

## iCloud Drive Backup (Claude Code architecture + Codex impl)
- [ ] Add flutter_icloud_document to pubspec.yaml (or icloud_storage)
- [ ] lib/core/backup/icloud_backup_service.dart
  - backupToICloud(userId): serializes tasks + sessions to JSON → writes to iCloud Drive
  - restoreFromICloud(): reads JSON → deserializes to local state
- [ ] Backup trigger: on session complete (after reward)
- [ ] Restore trigger: on app launch if guest mode (before any data shown)
- [ ] File names: `own_ur_time_tasks_{userId}.json`, `own_ur_time_sessions_{userId}.json`
  - Guest userId = device UUID (stored in flutter_secure_storage)
- [ ] Handle iCloud unavailable gracefully (user not signed in to iCloud → skip silently)

## Verify
- [ ] `flutter gen-l10n` — success
- [ ] `grep -r "\"지금\|\"잠깐\|\"집중\|\"오늘" lib/` — returns zero results (no hardcoded Korean)
- [ ] App displays Korean text from ARB correctly on Korean device/simulator
- [ ] iCloud backup file appears in Files app → iCloud Drive after session completes
