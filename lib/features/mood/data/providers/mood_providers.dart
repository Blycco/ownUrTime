import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/features/mood/data/datasources/mood_datasource.dart';
import 'package:ownurtime/features/mood/data/datasources/mood_remote_datasource.dart';
import 'package:ownurtime/features/mood/data/repositories/mood_repository_impl.dart';
import 'package:ownurtime/features/mood/domain/repositories/mood_repository.dart';
import 'package:ownurtime/features/mood/domain/usecases/check_mood_usecase.dart';
import 'package:ownurtime/features/mood/domain/usecases/get_today_mood_checks_usecase.dart';

final inMemoryMoodDataSourceProvider = Provider<MoodDataSource>(
  (Ref ref) => InMemoryMoodDataSource(),
);

final moodRepositoryProvider = Provider<MoodRepository>(
  (Ref ref) => MoodRepositoryImpl(ref.watch(inMemoryMoodDataSourceProvider)),
);

final checkMoodUseCaseProvider = Provider<CheckMoodUseCase>(
  (Ref ref) => CheckMoodUseCase(ref.watch(moodRepositoryProvider)),
);

final getTodayMoodChecksUseCaseProvider = Provider<GetTodayMoodChecksUseCase>(
  (Ref ref) => GetTodayMoodChecksUseCase(ref.watch(moodRepositoryProvider)),
);
