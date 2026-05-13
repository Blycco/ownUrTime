import 'package:ownurtime/features/task/data/models/task_model.dart';

abstract interface class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<TaskModel> createTask(String userId, String title);
  Future<void> updateTask(TaskModel model);
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  );
}

class SupabaseTaskDataSource implements TaskRemoteDataSource {
  @override
  Future<List<TaskModel>> getTasks(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<TaskModel> createTask(String userId, String title) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(TaskModel model) {
    throw UnimplementedError();
  }

  @override
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  ) {
    throw UnimplementedError();
  }
}
