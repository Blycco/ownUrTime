import 'package:flutter_test/flutter_test.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';
import 'package:ownurtime/features/task/domain/usecases/get_tasks_usecase.dart';

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({List<Task>? tasks}) : _tasks = tasks ?? <Task>[];

  final List<Task> _tasks;

  @override
  Future<List<Task>> getTasks(String userId) async {
    return _tasks.where((Task task) => task.userId == userId).toList();
  }

  @override
  Future<Task> createTask(String userId, String title) {
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
  group('GetTasksUseCase', () {
    test('call returns task list for user', () async {
      final FakeTaskRepository repository = FakeTaskRepository(
        tasks: <Task>[
          Task(
            id: '1',
            userId: 'u1',
            title: 'Task A',
            status: TaskStatus.pending,
            createdAt: DateTime(2026),
          ),
          Task(
            id: '2',
            userId: 'u2',
            title: 'Task B',
            status: TaskStatus.completed,
            createdAt: DateTime(2026),
          ),
        ],
      );
      final GetTasksUseCase useCase = GetTasksUseCase(repository);

      final List<Task> result = await useCase('u1');

      expect(result.length, 1);
      expect(result.first.title, 'Task A');
    });

    test('call returns empty list when user has no tasks', () async {
      final FakeTaskRepository repository = FakeTaskRepository(tasks: <Task>[]);
      final GetTasksUseCase useCase = GetTasksUseCase(repository);

      final List<Task> result = await useCase('unknown_user');

      expect(result, isEmpty);
    });
  });
}
