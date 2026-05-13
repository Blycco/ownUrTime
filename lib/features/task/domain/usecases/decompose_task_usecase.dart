import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';

class DecomposeTaskUseCase {
  const DecomposeTaskUseCase(this._repository);
  final TaskRepository _repository;

  Future<({List<String> steps, int remainingToday})> call(
    String taskId,
    String title,
  ) => _repository.decomposeTask(taskId, title);
}
