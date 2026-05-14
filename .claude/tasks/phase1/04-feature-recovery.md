# Feature: Recovery — Phase 1
> Agent: Claude Code (recovery paths + context card logic) | Codex (UI + tests)
> PRD ref: Section 5-3 (recovery)
> Read: .claude/context/adhd-domain.md (Recovery section), .claude/context/dart-patterns.md
> GitHub Issue: #8 | Branch: feat/feature-recovery

## Domain Layer (Claude Code)
- [x] lib/features/recovery/domain/entities/distraction.dart
  - freezed: id, sessionId, userId, type (DistractionType), occurredAt, returnedAt?
  - enum DistractionType { urgent, impulsive, rest }
- [x] lib/features/recovery/domain/repositories/distraction_repository.dart
  - logDistraction(sessionId, type) → Future<Distraction>
  - markReturned(distractionId) → Future<void>
- [x] lib/features/recovery/domain/usecases/log_distraction_usecase.dart
- [x] lib/features/recovery/domain/usecases/recover_session_usecase.dart
  - markReturned() on the distraction
  - Returns recovery context: previous task title + next decomposed step

## Recovery Paths per Distraction Type (Claude Code — UX logic)
- urgent: "Handle what came up" → "Ready to return?" CTA → context card
- impulsive: "It happens" (no guilt) → "Your task is waiting" → context card
- rest: "Good call" → estimated break timer suggestion → "Back to it" → context card

## Data Layer (Codex)
- [x] lib/features/recovery/data/models/distraction_model.dart
- [x] lib/features/recovery/data/datasources/in_memory_distraction_datasource.dart
- [x] lib/features/recovery/data/repositories/distraction_repository_impl.dart

## Presentation: Recovery Screen (Codex)
- [x] lib/features/recovery/presentation/screens/recovery_screen.dart
  - Step 1: 3 large buttons — urgent / impulsive / rest (icons + labels)
  - Step 2: distraction-type-specific message (no shame framing)
  - Step 3: context restore card
  - Step 4: "Resume" button (1 tap → back to session_screen)
  - Nav: pushed from session_screen when "Distracted" tapped

## Context Restore Card (Claude Code)
- [x] lib/features/recovery/presentation/widgets/context_restore_card.dart
  - Shows: task title (bold)
  - Shows: "You were on step:" + the decomposed step they were working on
  - If no decomposed steps: shows task title only
  - Shows: elapsed session time (e.g., "12 min into your session")
  - "Resume" button — 1 tap, prominent

## Tests (Codex)
- [x] test/features/recovery/domain/log_distraction_usecase_test.dart
  - Test: logs distraction with correct type and sessionId
- [x] test/features/recovery/domain/recover_session_usecase_test.dart
  - Test: returns task title and correct next step index
  - Test: marks distraction as returned with timestamp
- [x] test/features/recovery/presentation/recovery_screen_test.dart
  - Test: 3 distraction type buttons visible
  - Test: tapping each shows distinct message (no shame on impulsive)
  - Test: context restore card shows task title and step
  - Test: resume button navigates back

## Done When
- [x] flutter analyze — zero warnings in features/recovery/
- [x] All tests pass
- [x] Each distraction type shows distinct, positive-framed message
- [x] Context restore card shows correct task context
- [x] Resume = 1 tap from context card
