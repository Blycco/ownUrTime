import 'package:ownurtime/features/mood/data/datasources/mood_datasource.dart';
import 'package:ownurtime/features/mood/domain/entities/mood_check.dart';
import 'package:ownurtime/features/mood/domain/repositories/mood_repository.dart';

class MoodRepositoryImpl implements MoodRepository {
  const MoodRepositoryImpl(this._dataSource);

  final MoodDataSource _dataSource;

  @override
  Future<MoodCheck> saveMoodCheck(
    String userId,
    int level, {
    String? sessionId,
  }) async {
    final model = await _dataSource.saveMoodCheck(
      userId,
      level,
      sessionId: sessionId,
    );
    return model.toEntity();
  }

  @override
  Future<List<MoodCheck>> getTodayMoodChecks(String userId) async {
    final models = await _dataSource.getTodayMoodChecks(userId);
    return models.map((model) => model.toEntity()).toList();
  }
}
