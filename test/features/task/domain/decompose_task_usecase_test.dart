import 'package:flutter_test/flutter_test.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/exceptions/task_exceptions.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';
import 'package:ownurtime/features/task/domain/usecases/decompose_task_usecase.dart';

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({this.shouldThrow = false});

  final bool shouldThrow;

  @override
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  ) async {
    if (shouldThrow) {
      throw const DailyLimitException('daily_limit_reached');
    }

    return (steps: <String>['a', 'b', 'c'], remainingToday: 4);
  }

  @override
  Future<Task> createTask(String userId, String title) {
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasks(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(Task task) {
    throw UnimplementedError();
  }
}

void main() {
  group('DecomposeTaskUseCase', () {
    test('returns steps and remainingToday when under limit', () async {
      final DecomposeTaskUseCase useCase = DecomposeTaskUseCase(
        FakeTaskRepository(),
      );

      final (:steps, :remainingToday) = await useCase('t1', '큰 일');

      expect(steps, <String>['a', 'b', 'c']);
      expect(remainingToday, 4);
    });

    test('propagates exception when repository throws', () async {
      final DecomposeTaskUseCase useCase = DecomposeTaskUseCase(
        FakeTaskRepository(shouldThrow: true),
      );

      await expectLater(
        () => useCase('t1', '큰 일'),
        throwsA(
          isA<DailyLimitException>().having(
            (DailyLimitException e) => e.code,
            'code',
            'daily_limit_reached',
          ),
        ),
      );
    });
  });
}
