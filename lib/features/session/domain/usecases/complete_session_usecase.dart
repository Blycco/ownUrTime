import 'package:ownurtime/features/session/domain/entities/session.dart';
import 'package:ownurtime/features/session/domain/repositories/session_repository.dart';

class CompleteSessionUseCase {
  const CompleteSessionUseCase(this._repository);
  final SessionRepository _repository;

  Future<Session> call(String sessionId) async {
    final session = await _repository.completeSession(sessionId);
    // Layer-1 reward stub — Phase 2에서 RewardRepository 연결
    return session;
  }
}
