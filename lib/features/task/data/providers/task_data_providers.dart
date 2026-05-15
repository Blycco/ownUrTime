import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/features/task/data/datasources/in_memory_task_datasource.dart';
import 'package:ownurtime/features/task/data/repositories/task_repository_impl.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';

final inMemoryTaskDataSourceProvider = Provider<InMemoryTaskDataSource>(
  (Ref ref) => InMemoryTaskDataSource(),
);

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>(
  (Ref ref) => ref.watch(inMemoryTaskDataSourceProvider),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (Ref ref) => TaskRepositoryImpl(ref.watch(taskLocalDataSourceProvider)),
);
