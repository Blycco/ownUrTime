import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/core/providers/supabase_provider.dart';
import 'package:ownurtime/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ownurtime/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ownurtime/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ownurtime/features/auth/domain/repositories/auth_repository.dart';
import 'package:ownurtime/features/auth/domain/usecases/migrate_local_data_usecase.dart';
import 'package:ownurtime/features/session/data/providers/session_providers.dart';
import 'package:ownurtime/features/task/data/providers/task_data_providers.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (Ref ref) => SupabaseAuthDataSource(ref.watch(supabaseClientProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (Ref ref) => SecureStorageAuthDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  ),
);

final migrateLocalDataUseCaseProvider = Provider<MigrateLocalDataUseCase>(
  (Ref ref) => MigrateLocalDataUseCase(
    taskRepository: ref.watch(taskRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
  ),
);
