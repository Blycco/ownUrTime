import 'package:flutter_test/flutter_test.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';
import 'package:ownurtime/features/task/domain/usecases/create_task_usecase.dart';

class FakeTaskRepository implements TaskRepository {
  @override
  Future<Task> createTask(String userId, String title) async {
    return Task(
      id: 'created_1',
      userId: userId,
      title: title,
      status: TaskStatus.pending,
      createdAt: DateTime(2026),
    );
  }

  @override
  Future<List<Task>> getTasks(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(Task task) {
    throw UnimplementedError();
  }

  @override
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> migrateToUser({
    required List<Task> tasks,
    required String newUserId,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('call returns Task with correct title and pending status', () async {
    final FakeTaskRepository repository = FakeTaskRepository();
    final CreateTaskUseCase useCase = CreateTaskUseCase(repository);

    final Task result = await useCase('u1', '새 작업');

    expect(result.title, '새 작업');
    expect(result.status, TaskStatus.pending);
    expect(result.userId, 'u1');
  });
}
