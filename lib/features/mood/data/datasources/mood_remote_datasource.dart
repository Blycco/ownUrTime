import 'package:ownurtime/features/mood/data/models/mood_check_model.dart';

class InMemoryMoodDataSource {
  final List<MoodCheckModel> _store = <MoodCheckModel>[];

  Future<MoodCheckModel> saveMoodCheck(
    String userId,
    int level, {
    String? sessionId,
  }) async {
    final now = DateTime.now();
    final model = MoodCheckModel(
      id: now.microsecondsSinceEpoch.toString(),
      userId: userId,
      sessionId: sessionId,
      moodLevel: level,
      checkedAt: now,
    );
    _store.add(model);
    return model;
  }

  Future<List<MoodCheckModel>> getTodayMoodChecks(String userId) async {
    final now = DateTime.now();
    return _store.where((MoodCheckModel model) {
      final checkedAt = model.checkedAt;
      return model.userId == userId &&
          checkedAt.year == now.year &&
          checkedAt.month == now.month &&
          checkedAt.day == now.day;
    }).toList();
  }
}
