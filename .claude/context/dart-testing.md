# Dart Testing Patterns — OwnUrTime
> Source: ECC rules/dart/testing.md — adapted for Flutter + Riverpod + Supabase
> Load this before writing any test files.

## Frameworks
- `flutter_test` — widget and unit tests (built-in)
- `mockito` or `mocktail` — mock generation
- `fake_async` — control time in timer tests
- `integration_test` — on-device flows (Phase 2+)

## Test Categories & Locations
```
test/
  features/
    task/
      data/          ← TaskRemoteDataSource, TaskRepositoryImpl
      domain/        ← UseCase logic
      presentation/  ← Widget tests for TaskListScreen, MicroStartButton
    session/
      domain/        ← TimerNotifier state transitions
      presentation/  ← SessionScreen widget tests
  core/              ← router, theme utilities
```

## Unit Test — UseCase
```dart
void main() {
  late TaskRepository mockRepo;
  late DecomposeTaskUseCase useCase;

  setUp(() {
    mockRepo = MockTaskRepository();
    useCase = DecomposeTaskUseCase(mockRepo);
  });

  test('returns 3 steps for a valid task title', () async {
    when(() => mockRepo.decomposeTask('Write report'))
        .thenAnswer((_) async => ['Outline', 'Draft', 'Review']);

    final result = await useCase('Write report');

    expect(result, hasLength(3));
  });
}
```

## Riverpod Unit Test — AsyncNotifier
```dart
void main() {
  test('TimerNotifier starts and counts down', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(timerProvider.notifier).start(const Duration(minutes: 10));

    final state = container.read(timerProvider);
    expect(state, isA<AsyncData<TimerState>>());
    state.whenData((s) => expect(s, isA<_Running>()));
  });
}
```

## Widget Test with Riverpod Override
```dart
void main() {
  testWidgets('TaskListScreen shows tasks from provider', (tester) async {
    final fakeRepo = FakeTaskRepository([
      Task(id: '1', title: 'Test task', ...),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: TaskListScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Test task'), findsOneWidget);
  });
}
```

## Timer Test with fake_async
```dart
test('session completes after target duration', () {
  fakeAsync((async) {
    final notifier = TimerNotifier();
    notifier.start(const Duration(minutes: 10));

    async.elapse(const Duration(minutes: 10));

    expect(notifier.state, isA<_Completed>());
  });
});
```

## Prefer Hand-Written Fakes Over Mocks
```dart
// Prefer this
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository(this._tasks);
  final List<Task> _tasks;

  @override
  Future<List<Task>> getAll() async => _tasks;

  @override
  Stream<List<Task>> watchAll() => Stream.value(_tasks);
  // ...
}

// Over this (use mocks only for complex interaction verification)
final mockRepo = MockTaskRepository();
```

## Coverage Target
- 80%+ line coverage for business logic (domain/ + data/)
- Widget tests for all primary screens (presentation/)
- Run: `flutter test --coverage`
- View: `genhtml coverage/lcov.info -o coverage/html`

## Test Naming
```dart
// Pattern: "does X when Y"
test('returns empty list when user has no tasks', ...);
testWidgets('shows loading spinner while tasks are fetching', ...);
testWidgets('displays error message when repository throws', ...);
```
