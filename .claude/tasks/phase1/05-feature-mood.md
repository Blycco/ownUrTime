# Feature: Mood Check — Phase 1
> Agent: Codex (impl + tests) | Claude Code (session length logic)
> PRD ref: Section 7 (onboarding), Section 8 (comorbidity support)

## Domain Layer
- [ ] lib/features/mood/domain/entities/mood_check.dart
  - freezed: id, userId, sessionId?, moodLevel (1–5), checkedAt
- [ ] lib/features/mood/domain/repositories/mood_repository.dart
  - saveMoodCheck(userId, level, sessionId?) → Future<MoodCheck>
  - getTodayMoodChecks(userId) → Future<List<MoodCheck>>
- [ ] lib/features/mood/domain/usecases/check_mood_usecase.dart
  - Saves mood; returns suggested session duration:
    - level 1–2 → 10 min
    - level 3 → 15 min
    - level 4–5 → 25 min

## Data Layer (Codex)
- [ ] lib/features/mood/data/models/mood_check_model.dart
- [ ] lib/features/mood/data/datasources/mood_remote_datasource.dart
- [ ] lib/features/mood/data/repositories/mood_repository_impl.dart

## Presentation (Codex)
- [ ] lib/features/mood/presentation/widgets/mood_check_widget.dart
  - 5 emoji buttons in a row: 😔 😕 😐 🙂 😄 (or similar)
  - Single tap to select; no confirm button needed
  - Appears as bottom sheet or inline card (not full screen)
  - After selection: auto-advances to session duration selector with suggestion pre-filled
  - "Skip" option available — mood check is optional
- [ ] Timing logic (in session provider or app lifecycle):
  - Show before first session of the day
  - Show after session ends (not before subsequent sessions in same day)

## Tests (Codex)
- [ ] test/features/mood/domain/check_mood_usecase_test.dart
  - Test: level 1 → suggests 10 min
  - Test: level 2 → suggests 10 min
  - Test: level 3 → suggests 15 min
  - Test: level 5 → suggests 25 min
- [ ] test/features/mood/presentation/mood_check_widget_test.dart
  - Test: 5 emoji options visible
  - Test: tapping one calls usecase with correct level
  - Test: skip option available

## Done When
- [ ] flutter analyze — zero warnings in features/mood/
- [ ] All tests pass
- [ ] Mood 1–2 pre-fills 10 min in session screen
- [ ] Appears before first daily session; after subsequent session completions
