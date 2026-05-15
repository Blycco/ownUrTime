import 'package:ownurtime/features/task/domain/entities/task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> getTasks(String userId);
  Future<Task> createTask(String userId, String title);
  Future<void> updateTask(Task task);
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  );
  Future<void> migrateToUser({
    required List<Task> tasks,
    required String newUserId,
  });
}
