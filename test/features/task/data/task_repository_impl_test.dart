import 'package:flutter_test/flutter_test.dart';
import 'package:ownurtime/features/task/data/datasources/in_memory_task_datasource.dart';
import 'package:ownurtime/features/task/data/models/task_model.dart';
import 'package:ownurtime/features/task/data/repositories/task_repository_impl.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/exceptions/task_exceptions.dart';

class FakeTaskLocalDataSource implements TaskLocalDataSource {
  FakeTaskLocalDataSource({this.createdTask, List<TaskModel>? tasks})
    : _tasks = tasks ?? <TaskModel>[];

  final TaskModel? createdTask;
  final List<TaskModel> _tasks;

  @override
  Future<TaskModel> createTask(String userId, String title) async {
    return createdTask ??
        TaskModel(
          id: 'task_1',
          userId: userId,
          title: title,
          status: 'pending',
          createdAt: DateTime(2026),
        );
  }

  @override
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  ) async {
    return (steps: <String>['1', '2', '3'], remainingToday: 9);
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    return _tasks.where((TaskModel task) => task.userId == userId).toList();
  }

  @override
  Future<void> updateTask(TaskModel model) async {}
}

void main() {
  group('InMemoryTaskDataSource', () {
    test('decomposeTask decrements remainingToday', () async {
      final InMemoryTaskDataSource dataSource = InMemoryTaskDataSource();

      final ({List<String> steps, int remainingToday}) first = await dataSource
          .decomposeTask('task_1', 'title');
      ({List<String> steps, int remainingToday}) last = first;

      for (int i = 0; i < 9; i++) {
        last = await dataSource.decomposeTask('task_1', 'title');
      }

      expect(first.remainingToday, 9);
      expect(last.remainingToday, 0);
    });

    test('decomposeTask throws DailyLimitException when exhausted', () async {
      final InMemoryTaskDataSource dataSource = InMemoryTaskDataSource();

      for (int i = 0; i < 10; i++) {
        await dataSource.decomposeTask('task_1', 'title');
      }

      expect(
        () => dataSource.decomposeTask('task_1', 'title'),
        throwsA(isA<DailyLimitException>()),
      );
    });
  });

  group('TaskRepositoryImpl', () {
    test('createTask converts model to entity', () async {
      final FakeTaskLocalDataSource local = FakeTaskLocalDataSource(
        createdTask: TaskModel(
          id: 't1',
          userId: 'u1',
          title: 'Task title',
          status: 'in_progress',
          createdAt: DateTime(2026),
        ),
      );
      final TaskRepositoryImpl repository = TaskRepositoryImpl(local);

      final Task result = await repository.createTask('u1', 'Task title');

      expect(result.id, 't1');
      expect(result.status, TaskStatus.inProgress);
      expect(result.title, 'Task title');
    });

    test('getTasks returns correct entities', () async {
      final FakeTaskLocalDataSource local = FakeTaskLocalDataSource(
        tasks: <TaskModel>[
          TaskModel(
            id: 't1',
            userId: 'u1',
            title: 'A',
            status: 'completed',
            createdAt: DateTime(2026),
          ),
          TaskModel(
            id: 't2',
            userId: 'u2',
            title: 'B',
            status: 'pending',
            createdAt: DateTime(2026),
          ),
        ],
      );
      final TaskRepositoryImpl repository = TaskRepositoryImpl(local);

      final List<Task> result = await repository.getTasks('u1');

      expect(result.length, 1);
      expect(result.first.id, 't1');
      expect(result.first.status, TaskStatus.completed);
    });
  });
}
