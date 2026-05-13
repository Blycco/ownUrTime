import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';

class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);
  final TaskRepository _repository;

  Future<Task> call(String userId, String title) =>
      _repository.createTask(userId, title);
}
