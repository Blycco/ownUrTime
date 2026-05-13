# Feature: Session Timer — Phase 1
> Agent: Claude Code (timer logic + distraction modes) | Codex (UI + tests)
> PRD ref: Section 5-2 (maintenance)
> Read: .claude/context/dart-patterns.md, .claude/context/adhd-domain.md

## Domain Layer (Claude Code)
- [x] lib/features/session/domain/entities/timer_state.dart
- [x] lib/features/session/domain/entities/session.dart
- [x] lib/features/session/domain/repositories/session_repository.dart
- [x] lib/features/session/domain/usecases/start_session_usecase.dart
- [x] lib/features/session/domain/usecases/complete_session_usecase.dart

## Presentation: Timer Logic (Claude Code)
- [x] lib/features/session/presentation/providers/timer_provider.dart

## Data Layer (Codex)
- [x] lib/features/session/data/models/session_model.dart
- [x] lib/features/session/data/datasources/session_local_datasource.dart
- [x] lib/features/session/data/datasources/in_memory_session_datasource.dart
- [x] lib/features/session/data/datasources/session_remote_datasource.dart
- [x] lib/features/session/data/repositories/session_repository_impl.dart

## Presentation: UI (Codex)
- [x] lib/features/session/presentation/screens/session_screen.dart
- [x] lib/features/session/presentation/widgets/duration_selector.dart
- [x] lib/features/session/presentation/widgets/timer_display.dart
- [x] lib/features/session/presentation/widgets/adaptive_checkin_overlay.dart

## Tests (Codex)
- [x] test/features/session/domain/timer_notifier_test.dart
- [x] test/features/session/presentation/session_screen_test.dart

## Done When
- [x] flutter analyze — zero warnings in features/session/
- [x] All tests pass
- [ ] Timer counts down, resets, extends correctly (수동 확인 필요)
- [ ] Distracted button always visible; never suppressed (수동 확인 필요)
- [ ] Manual-work mode disables adaptive check-in for that session (수동 확인 필요)
