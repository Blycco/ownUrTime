import 'package:ownurtime/features/mood/data/models/mood_check_model.dart';

abstract interface class MoodDataSource {
  Future<MoodCheckModel> saveMoodCheck(
    String userId,
    int level, {
    String? sessionId,
  });

  Future<List<MoodCheckModel>> getTodayMoodChecks(String userId);
}
