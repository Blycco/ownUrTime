import 'package:ownurtime/features/mood/domain/entities/mood_check.dart';

abstract interface class MoodRepository {
  Future<MoodCheck> saveMoodCheck(
    String userId,
    int level, {
    String? sessionId,
  });

  Future<List<MoodCheck>> getTodayMoodChecks(String userId);
}
