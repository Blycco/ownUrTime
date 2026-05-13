import 'package:ownurtime/features/task/data/models/task_model.dart';
import 'package:ownurtime/features/task/domain/exceptions/task_exceptions.dart';

abstract interface class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<TaskModel> createTask(String userId, String title);
  Future<void> updateTask(TaskModel model);
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  );
}

class InMemoryTaskDataSource implements TaskLocalDataSource {
  final List<TaskModel> _tasks = <TaskModel>[];
  // UI-only guard; authoritative rate limit enforced in Supabase Edge Function.
  int _remainingToday = 10;

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    return _tasks.where((TaskModel task) => task.userId == userId).toList();
  }

  @override
  Future<TaskModel> createTask(String userId, String title) async {
    final TaskModel model = TaskModel(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    _tasks.add(model);
    return model;
  }

  @override
  Future<void> updateTask(TaskModel model) async {
    final int index = _tasks.indexWhere(
      (TaskModel task) => task.id == model.id,
    );
    if (index == -1) {
      _tasks.add(model);
      return;
    }

    _tasks[index] = model;
  }

  @override
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  ) async {
    if (_remainingToday <= 0) {
      throw const DailyLimitException('daily_limit_reached');
    }

    _remainingToday -= 1;
    return (
      steps: <String>['Step 1: Start', 'Step 2: Work on it', 'Step 3: Wrap up'],
      remainingToday: _remainingToday,
    );
  }
}
