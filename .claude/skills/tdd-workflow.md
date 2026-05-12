---
name: tdd-workflow
description: Use when writing new features or fixing bugs. Enforces Red-Green-Refactor TDD with 80%+ coverage. Git checkpoint after each phase.
origin: ECC (adapted for Flutter/Dart)
---

# TDD Workflow — Flutter/Dart

## When to Activate
- Starting any new feature
- Fixing a bug
- Refactoring existing code

## Core Principles
1. **Tests BEFORE code** — write a failing test first, always
2. **80%+ coverage** — unit tests (domain/) + widget tests (presentation/)
3. **Git checkpoints** — one commit per RED, one per GREEN

## Red-Green-Refactor Cycle

### 🔴 RED — Write a Failing Test
```bash
# Write the test first
# Run to confirm it FAILS (not just errors — a real assertion failure)
flutter test test/features/{feature}/domain/{test_file}.dart
# → Expected: FAIL
```
Commit:
```
Test: add failing test for {behavior}
```

### 🟢 GREEN — Minimal Implementation
```bash
# Write the minimum code to make the test pass
flutter test test/features/{feature}/domain/{test_file}.dart
# → Expected: PASS
flutter analyze   # → zero warnings
```
Commit:
```
Feat: minimal impl to pass {behavior} test
```

### 🔵 REFACTOR — Clean Up
```bash
# Improve code quality without breaking tests
flutter test      # must still pass
flutter analyze   # must still be zero warnings
dart format .
```
Commit only if significant changes were made:
```
Refactor: clean up {what was improved}
```

## Flutter-Specific Patterns

### Unit Test First (UseCase / Repository)
```dart
// 1. Write test
test('decomposes task into 3 steps', () async {
  final useCase = DecomposeTaskUseCase(FakeTaskRepository());
  final steps = await useCase('Write report');
  expect(steps, hasLength(3));
});

// 2. Run → should fail
// 3. Implement DecomposeTaskUseCase.call()
// 4. Run → should pass
```

### Widget Test First (Screen / Widget)
```dart
// 1. Write widget test
testWidgets('shows micro start button on task screen', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [taskListProvider.overrideWith((_) async => [])],
      child: const MaterialApp(home: TaskListScreen()),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(MicroStartButton), findsOneWidget);
});

// 2. Run → fail
// 3. Build TaskListScreen with MicroStartButton
// 4. Run → pass
```

### AsyncNotifier State Test First
```dart
// 1. Write state transition test
test('timer transitions to running state on start', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await container.read(timerProvider.notifier).start(const Duration(minutes: 10));

  container.read(timerProvider).whenData(
    (state) => expect(state, isA<_Running>()),
  );
});

// 2. Run → fail
// 3. Implement TimerNotifier.start()
// 4. Run → pass
```

## Coverage Check
```bash
flutter test --coverage
# View report (requires lcov):
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```
Target: **80%+ line coverage** for `lib/features/{feature}/domain/` and `lib/features/{feature}/data/`

## Definition of Done (per TDD cycle)
- [ ] Failing test written and committed (RED)
- [ ] Test passes with minimal implementation (GREEN)
- [ ] `flutter analyze` → zero warnings
- [ ] Code cleaned up (REFACTOR)
- [ ] Coverage ≥ 80% for changed files
