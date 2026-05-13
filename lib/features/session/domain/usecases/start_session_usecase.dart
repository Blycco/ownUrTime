import 'package:ownurtime/features/session/domain/entities/session.dart';
import 'package:ownurtime/features/session/domain/repositories/session_repository.dart';

class StartSessionUseCase {
  const StartSessionUseCase(this._repository);
  final SessionRepository _repository;

  Future<Session> call({
    required String userId,
    String? taskId,
    required int targetDurationMinutes,
    required bool manualWorkMode,
  }) => _repository.startSession(
    userId: userId,
    taskId: taskId,
    targetDurationMinutes: targetDurationMinutes,
    manualWorkMode: manualWorkMode,
  );
}
