import 'package:ownurtime/features/mood/domain/entities/mood_check.dart';
import 'package:ownurtime/features/mood/domain/repositories/mood_repository.dart';

class GetTodayMoodChecksUseCase {
  const GetTodayMoodChecksUseCase(this._repository);

  final MoodRepository _repository;

  Future<List<MoodCheck>> call(String userId) {
    return _repository.getTodayMoodChecks(userId);
  }
}
