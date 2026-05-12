# Dart Patterns — OwnUrTime
> Source: ECC rules/dart/patterns.md (Riverpod + Repository sections only; BLoC removed)
> Load this before implementing any feature in `lib/features/`.

## Repository Pattern

```dart
// domain/repositories/task_repository.dart
abstract interface class TaskRepository {
  Future<Task?> getById(String id);
  Future<List<Task>> getAll();
  Stream<List<Task>> watchAll();         // Supabase Realtime
  Future<void> save(Task task);
  Future<void> delete(String id);
}

// data/repositories/task_repository_impl.dart
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remote);
  final TaskRemoteDataSource _remote;

  @override
  Future<List<Task>> getAll() async {
    final models = await _remote.getTasks(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<Task>> watchAll() =>
      _remote.watchTasks(userId).map((list) => list.map((m) => m.toEntity()).toList());
}
```

## Riverpod Patterns (only patterns used in this project)

```dart
// Simple provider — static value or client
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// FutureProvider — one-shot async data
@riverpod
Future<List<Task>> taskList(Ref ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getAll();
}

// StreamProvider — real-time Supabase data
@riverpod
Stream<List<Task>> taskListStream(Ref ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAll();
}

// AsyncNotifier — mutable state with async operations (preferred for complex state)
@riverpod
class TimerNotifier extends _$TimerNotifier {
  @override
  TimerState build() => const TimerState.idle();

  Future<void> start(Duration duration) async {
    state = const TimerState.running();
    // ...
  }

  void pause() => state = const TimerState.paused();
}

// ConsumerWidget — read providers in build
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListStreamProvider);
    return tasks.when(
      data: (list) => ListView(children: list.map(TaskCard.new).toList()),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => ErrorView(message: e.toString()),
    );
  }
}

// ConsumerStatefulWidget — when lifecycle methods are needed
class SessionScreen extends ConsumerStatefulWidget { ... }
```

## UseCase Pattern

```dart
// domain/usecases/decompose_task_usecase.dart
class DecomposeTaskUseCase {
  const DecomposeTaskUseCase(this._repository);
  final TaskRepository _repository;

  Future<List<String>> call(String taskTitle) =>
      _repository.decomposeTask(taskTitle);
}
```

## Immutable State with freezed

```dart
@freezed
class TimerState with _$TimerState {
  const factory TimerState.idle() = _Idle;
  const factory TimerState.running({
    required Duration remaining,
    @Default(0) int distractionCount,
  }) = _Running;
  const factory TimerState.paused({required Duration remaining}) = _Paused;
  const factory TimerState.completed() = _Completed;
}
```

## Clean Architecture Layer Rules
```
domain/    ← pure Dart only; no Flutter, no Supabase imports
data/      ← implements domain interfaces; maps DTOs ↔ entities
presentation/ ← Flutter widgets + Riverpod providers; calls use cases only
```

- Presentation → UseCase only (never repository directly)
- Data maps DTOs to domain entities at repository boundary
- Domain has zero external package dependencies

## GoRouter with Auth Guard

```dart
final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/session', builder: (_, __) => const SessionScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
  ],
  redirect: (context, state) {
    final isGuest = ref.read(authProvider).isGuest;
    final isLoginRoute = state.matchedLocation == '/login';
    // Guest allowed until 3rd session — see RULE 12
    return null;
  },
);
```
