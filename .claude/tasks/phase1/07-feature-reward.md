# Feature: Layer-1 Immediate Reward — Phase 1
> Agent: Codex (impl + animation) | Claude Code (trigger wiring)
> PRD ref: Section 6 (reward design — Layer 1)
> Rule: reward is NEVER suppressed. Always fires on session complete.

## Core Requirement
Every session completion triggers: sound + animation.
No conditions. No opt-out. Cannot be disabled.

## Implementation
- [ ] lib/features/reward/presentation/widgets/completion_reward_widget.dart
  - Overlay widget shown on session complete
  - Animation: checkmark pulse → confetti burst (or similar celebratory effect)
    - Use flutter_animate or rive (check pubspec first; add if needed)
    - Duration: ~2 seconds; auto-dismisses
  - Sound: system success sound (AudioServicesPlaySystemSound) or bundled asset
    - Use audioplayers or just_audio package
  - Must not block navigation — overlay fades, then auto-pops to task list

- [ ] Trigger wiring (in timer_provider.dart — Claude Code):
  - On TimerState transition to completed → emit reward event
  - session_screen.dart listens → shows CompletionRewardWidget as overlay

- [ ] lib/features/reward/presentation/providers/reward_provider.dart (if needed)
  - Simple StateProvider<bool> rewardVisible

## Sound Assets
- [ ] Add completion sound to assets/sounds/completion.mp3 (or use system sound)
- [ ] Declare in pubspec.yaml under flutter > assets

## Tests (Codex)
- [ ] test/features/reward/presentation/completion_reward_widget_test.dart
  - Test: widget appears when session completes
  - Test: widget auto-dismisses after animation
  - Test: reward fires for every session — not conditional
- [ ] test/features/session/domain/timer_notifier_test.dart (add to existing)
  - Test: completion event emitted when timer reaches zero

## Done When
- [ ] flutter analyze — zero warnings in features/reward/
- [ ] All tests pass
- [ ] Reward fires on every session completion (no exceptions)
- [ ] Animation plays, sound plays, auto-dismisses in ~2s
