import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/features/recovery/data/datasources/in_memory_distraction_datasource.dart';
import 'package:ownurtime/features/recovery/data/repositories/distraction_repository_impl.dart';
import 'package:ownurtime/features/recovery/domain/repositories/distraction_repository.dart';
import 'package:ownurtime/features/recovery/domain/usecases/log_distraction_usecase.dart';
import 'package:ownurtime/features/recovery/domain/usecases/recover_session_usecase.dart';

final inMemoryDistractionDataSourceProvider =
    Provider<InMemoryDistractionDataSource>(
      (Ref ref) => InMemoryDistractionDataSource(),
    );

final distractionRepositoryProvider = Provider<DistractionRepository>(
  (Ref ref) => DistractionRepositoryImpl(
    ref.watch(inMemoryDistractionDataSourceProvider),
  ),
);

final logDistractionUseCaseProvider = Provider<LogDistractionUseCase>(
  (Ref ref) => LogDistractionUseCase(ref.watch(distractionRepositoryProvider)),
);

final recoverSessionUseCaseProvider = Provider<RecoverSessionUseCase>(
  (Ref ref) => RecoverSessionUseCase(ref.watch(distractionRepositoryProvider)),
);
