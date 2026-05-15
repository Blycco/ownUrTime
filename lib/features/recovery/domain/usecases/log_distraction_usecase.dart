import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';
import 'package:ownurtime/features/recovery/domain/repositories/distraction_repository.dart';

class LogDistractionUseCase {
  const LogDistractionUseCase(this._repository);

  final DistractionRepository _repository;

  Future<Distraction> call({
    required String sessionId,
    required DistractionType type,
    required String userId,
  }) {
    return _repository.logDistraction(sessionId, type, userId: userId);
  }
}
