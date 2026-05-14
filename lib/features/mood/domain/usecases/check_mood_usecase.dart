import 'package:ownurtime/features/mood/domain/entities/mood_check.dart';
import 'package:ownurtime/features/mood/domain/repositories/mood_repository.dart';

class CheckMoodUseCase {
  const CheckMoodUseCase(this._repository);

  final MoodRepository _repository;

  Future<(MoodCheck, int suggestedMinutes)> call({
    required String userId,
    required int level,
    String? sessionId,
  }) async {
    final check = await _repository.saveMoodCheck(
      userId,
      level,
      sessionId: sessionId,
    );
    final suggested = switch (level) {
      1 || 2 => 10,
      3 => 15,
      _ => 25,
    };
    return (check, suggested);
  }
}
