import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';

class GetTasksUseCase {
  const GetTasksUseCase(this._repository);
  final TaskRepository _repository;

  Future<List<Task>> call(String userId) => _repository.getTasks(userId);
}
