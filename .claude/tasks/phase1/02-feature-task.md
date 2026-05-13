# Feature: Task — Phase 1
> Agent: Claude Code (arch + AI limit UX) | Codex (CRUD impl + tests)
> PRD ref: Section 5-1 (initiation), Section 10 (AI features)
> Read: .claude/context/dart-patterns.md, .claude/context/folder-structure.md

## Domain Layer (Claude Code)
- [x] lib/features/task/domain/entities/task.dart
  - freezed: id, userId, title, decomposedSteps (List<String>?), status (TaskStatus), createdAt, startedAt?, completedAt?
  - enum TaskStatus { pending, inProgress, completed, abandoned }
- [x] lib/features/task/domain/repositories/task_repository.dart (abstract interface)
  - getTasks(String userId) → Future<List<Task>>
  - createTask(String userId, String title) → Future<Task>
  - updateTask(Task task) → Future<void>
  - decomposeTask(String taskId, String title) → Future<({List<String> steps, int remainingToday})>
- [x] lib/features/task/domain/usecases/get_tasks_usecase.dart
- [x] lib/features/task/domain/usecases/create_task_usecase.dart
- [x] lib/features/task/domain/usecases/decompose_task_usecase.dart
  - Calls repository.decomposeTask → returns steps + remaining count

## Data Layer (Codex)
- [x] lib/features/task/data/models/task_model.dart (freezed + json_serializable, toEntity())
- [x] lib/features/task/data/datasources/in_memory_task_datasource.dart (InMemory — Phase 1)
- [x] lib/features/task/data/datasources/task_remote_datasource.dart (stub — Supabase 연결 예정)
- [x] lib/features/task/data/repositories/task_repository_impl.dart

## Presentation Layer
- [x] lib/features/task/presentation/providers/task_provider.dart
  - taskListProvider: AsyncNotifier<List<Task>>
  - decomposeTaskProvider: AsyncNotifier for decomposition state
- [x] lib/features/task/presentation/screens/task_list_screen.dart
  - Guest-friendly: shows tasks from local state if not signed in
  - FAB or prominent button: "시작하기" (1 tap → task_start_screen)
  - No empty state shaming: encouraging message
- [x] lib/features/task/presentation/screens/task_start_screen.dart
  - Optional task title input (not required to start)
  - "2분만 해볼게요" button — prominent, 1 tap to begin
  - If title entered: show AI decompose button
  - Decomposed steps displayed under title
  - AI limit UX: counter quiet, positive framing at 0
- [x] lib/features/task/presentation/widgets/task_card.dart
- [x] lib/features/task/presentation/widgets/micro_start_button.dart
  - Large, single tap
  - No pre-conditions, no forced setup
- [x] lib/features/task/presentation/widgets/ai_limit_indicator.dart
  - Shows remaining count quietly; positive framing at 0

## Tests (Codex)
- [x] test/features/task/domain/get_tasks_usecase_test.dart
- [x] test/features/task/domain/create_task_usecase_test.dart
- [x] test/features/task/domain/decompose_task_usecase_test.dart
  - Test: returns steps when under limit
  - Test: returns error when daily_limit_reached
- [x] test/features/task/data/task_repository_impl_test.dart (FakeTaskDataSource)
- [x] test/features/task/presentation/task_list_screen_test.dart
- [x] test/features/task/presentation/micro_start_button_test.dart (1-tap, no forced input)

## Done When
- [x] flutter analyze — zero warnings in features/task/
- [x] All tests pass (12/12)
- [x] Guest user can create a task and see it without logging in
- [x] Decompose shows 3 steps; counter decrements; limit UX shows at 0 (InMemory stub: 9 remaining fixed)
