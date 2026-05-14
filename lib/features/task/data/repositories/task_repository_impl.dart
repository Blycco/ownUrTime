import 'package:ownurtime/features/task/data/datasources/in_memory_task_datasource.dart';
import 'package:ownurtime/features/task/data/models/task_model.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._local);

  final TaskLocalDataSource _local;

  @override
  Future<List<Task>> getTasks(String userId) async {
    final List<TaskModel> models = await _local.getTasks(userId);
    return models.map((TaskModel model) => model.toEntity()).toList();
  }

  @override
  Future<Task> createTask(String userId, String title) async {
    final TaskModel model = await _local.createTask(userId, title);
    return model.toEntity();
  }

  @override
  Future<void> updateTask(Task task) {
    final TaskModel model = TaskModel.fromEntity(task);
    return _local.updateTask(model);
  }

  @override
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  ) {
    return _local.decomposeTask(taskId, title);
  }

  @override
  Future<void> migrateToUser({
    required List<Task> tasks,
    required String newUserId,
  }) async {
    for (final task in tasks) {
      await updateTask(task.copyWith(userId: newUserId));
    }
  }
}
