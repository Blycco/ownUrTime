# Feature: Layer-1 Immediate Reward — Phase 1

> Agent: Codex (impl + animation) | Claude Code (trigger wiring)
> PRD ref: Section 6 (reward design — Layer 1)
> Rule: reward is NEVER suppressed. Always fires on session complete.
> Issue: #14

## Core Requirement

Every session completion triggers: sound + animation.
No conditions. No opt-out. Cannot be disabled.

## Implementation

- [x] lib/features/reward/presentation/widgets/completion_reward_widget.dart
  - Overlay widget shown on session complete
  - Animation: checkmark pulse (flutter_animate: scale 0.5→1.2→1.0) + fade out at 1.6s
  - Sound: HapticFeedback.heavyImpact() + SystemSound.play(alert) — no package needed
  - Auto-dismisses after 2s via onDismiss callback
  - Must not block navigation — overlay fades, then auto-pops to task list

- [x] Trigger wiring (session_screen.dart — Claude Code):
  - ref.listen timerProvider → TimerCompleted 감지 → rewardProvider.show()
  - Stack에 Positioned.fill(CompletionRewardWidget) 추가

- [x] lib/features/reward/presentation/providers/reward_provider.dart
  - @riverpod RewardNotifier: bool state, show()/hide()

## Sound Assets

- [x] SystemSound.play(SystemSoundType.alert) 사용 — asset 불필요
- [x] flutter_animate: ^4.1.1 pubspec.yaml에 추가

## Tests

- [x] test/features/reward/presentation/completion_reward_widget_test.dart (3 tests)
  - Test: widget appears with checkmark icon
  - Test: onDismiss called after 2 seconds
  - Test: reward fires unconditionally — no conditional check
- [x] test/features/session/domain/timer_notifier_test.dart (1 test added)
  - Test: state becomes TimerCompleted when timer reaches zero

## Done When

- [x] flutter analyze — zero warnings in features/reward/
- [x] All tests pass (52/52)
- [x] Reward fires on every session completion (no exceptions)
- [x] Animation plays, sound plays, auto-dismisses in ~2s
