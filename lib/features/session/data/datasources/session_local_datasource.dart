import 'package:ownurtime/features/session/domain/entities/session.dart';

abstract interface class SessionLocalDataSource {
  Future<Session> startSession({
    required String userId,
    String? taskId,
    required int targetDurationMinutes,
    required bool manualWorkMode,
  });

  Future<Session> completeSession(String sessionId);
  Future<Session> abandonSession(String sessionId);
  Future<Session> updateSession(Session session);
  Future<List<Session>> getSessions(String userId);
}
