# Feature: Session Timer — Phase 1
> Agent: Claude Code (timer logic + distraction modes) | Codex (UI + tests)
> PRD ref: Section 5-2 (maintenance)
> Read: .claude/context/dart-patterns.md, .claude/context/adhd-domain.md

## Domain Layer (Claude Code)
- [ ] lib/features/session/domain/entities/timer_state.dart
  - sealed class: TimerState.idle / .running(remaining, distractionCount, resetCount) / .paused(remaining) / .completed
- [ ] lib/features/session/domain/entities/session.dart
  - freezed: id, userId, taskId?, targetDurationMinutes, status (SessionStatus), distractionCount, resetCount, manualWorkMode, startedAt, completedAt?
  - enum SessionStatus { active, completed, abandoned }
- [ ] lib/features/session/domain/repositories/session_repository.dart
  - startSession, completeSession, abandonSession, updateSession
- [ ] lib/features/session/domain/usecases/start_session_usecase.dart
- [ ] lib/features/session/domain/usecases/complete_session_usecase.dart
  - Triggers Layer-1 reward event (via reward repository)

## Presentation: Timer Logic (Claude Code)
- [ ] lib/features/session/presentation/providers/timer_provider.dart
  - AsyncNotifier<TimerState>
  - start(Duration): begins countdown, persists session to Supabase
  - pause(): → TimerState.paused
  - reset(): resetCount++, max 3; if resetCount == 3 disable reset button
  - extend(): remaining += 1 minute
  - declareDistraction(): → navigates to recovery flow
  - _tick(): decrements remaining every second using Timer.periodic
  - on complete: fire completion event → Layer-1 reward
  - Adaptive check-in logic:
    - If user is new (session_count < 3 AND no prior adaptive dismissal):
      - At 5 min mark: show check-in overlay
      - Auto-dismiss after 10s
      - If user taps "Yes, focused" 3 consecutive times: set adaptive_checkin_disabled = true

## Data Layer (Codex)
- [ ] lib/features/session/data/models/session_model.dart
- [ ] lib/features/session/data/datasources/session_remote_datasource.dart
- [ ] lib/features/session/data/repositories/session_repository_impl.dart

## Presentation: UI (Codex)
- [ ] lib/features/session/presentation/screens/session_screen.dart
  - Duration selector: chips [10 min] [15 min] [25 min] [Custom]
  - Custom placed last; opens bottom sheet with number input
  - Large circular countdown display
  - "Distracted" button: always visible at bottom (user-declared default)
  - Reset button: visible, greyed out after 3 uses
  - +1 min button: always available
  - Manual-work mode toggle: shows before session starts; hides all check-ins for session
  - macOS: register Cmd+Shift+P shortcut → declareDistraction()
- [ ] lib/features/session/presentation/widgets/duration_selector.dart
- [ ] lib/features/session/presentation/widgets/timer_display.dart (circular countdown)
- [ ] lib/features/session/presentation/widgets/adaptive_checkin_overlay.dart
  - Shown at 5min mark for new users only
  - "집중 중이신가요?" → [Yes / Distracted]
  - Auto-dismisses after 10s
  - After 3 "Yes" taps: never shown again

## Tests (Codex)
- [ ] test/features/session/domain/timer_notifier_test.dart
  - Test: start → running state
  - Test: reset increments counter, blocked at 3
  - Test: extend adds 1 minute
  - Test: completes when remaining reaches 0
  - Test: adaptive check-in only for new users, disabled after 3 accepts
- [ ] test/features/session/presentation/session_screen_test.dart
  - Test: distracted button always visible
  - Test: reset button disabled after 3 uses
  - Test: custom duration option is last in list

## Done When
- [ ] flutter analyze — zero warnings in features/session/
- [ ] All tests pass
- [ ] Timer counts down, resets, extends correctly
- [ ] Distracted button always visible; never suppressed
- [ ] Manual-work mode disables adaptive check-in for that session
