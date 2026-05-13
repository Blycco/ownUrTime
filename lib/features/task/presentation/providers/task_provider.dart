import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ownurtime/features/task/data/datasources/in_memory_task_datasource.dart';
import 'package:ownurtime/features/task/data/repositories/task_repository_impl.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';
import 'package:ownurtime/features/task/domain/usecases/create_task_usecase.dart';
import 'package:ownurtime/features/task/domain/usecases/decompose_task_usecase.dart';
import 'package:ownurtime/features/task/domain/usecases/get_tasks_usecase.dart';

part 'task_provider.g.dart';

const String _guestUserId = 'guest';

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>(
  (Ref ref) => InMemoryTaskDataSource(),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (Ref ref) => TaskRepositoryImpl(ref.watch(taskLocalDataSourceProvider)),
);

@riverpod
class TaskListNotifier extends _$TaskListNotifier {
  @override
  Future<List<Task>> build() async {
    final repo = ref.watch(taskRepositoryProvider);
    return GetTasksUseCase(repo)(_guestUserId);
  }

  Future<void> createTask(String title) async {
    final repo = ref.read(taskRepositoryProvider);
    final task = await CreateTaskUseCase(repo)(_guestUserId, title);
    final current = state.asData?.value ?? [];
    state = AsyncData([...current, task]);
  }
}

@riverpod
class DecomposeTaskNotifier extends _$DecomposeTaskNotifier {
  @override
  AsyncValue<({List<String> steps, int remainingToday})?> build() =>
      const AsyncData(null);

  Future<void> decompose(String taskId, String title) async {
    state = const AsyncLoading();
    final repo = ref.read(taskRepositoryProvider);
    try {
      final result = await DecomposeTaskUseCase(repo)(taskId, title);
      state = AsyncData(result);
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void reset() => state = const AsyncData(null);
}
