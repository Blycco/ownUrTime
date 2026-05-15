import 'package:ownurtime/features/session/data/datasources/session_local_datasource.dart';
import 'package:ownurtime/features/session/domain/entities/session.dart';
import 'package:ownurtime/features/session/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._dataSource);

  final SessionLocalDataSource _dataSource;

  @override
  Future<Session> startSession({
    required String userId,
    String? taskId,
    required int targetDurationMinutes,
    required bool manualWorkMode,
  }) {
    return _dataSource.startSession(
      userId: userId,
      taskId: taskId,
      targetDurationMinutes: targetDurationMinutes,
      manualWorkMode: manualWorkMode,
    );
  }

  @override
  Future<Session> completeSession(String sessionId) {
    return _dataSource.completeSession(sessionId);
  }

  @override
  Future<Session> abandonSession(String sessionId) {
    return _dataSource.abandonSession(sessionId);
  }

  @override
  Future<Session> updateSession(Session session) {
    return _dataSource.updateSession(session);
  }

  @override
  Future<List<Session>> getSessions(String userId) {
    return _dataSource.getSessions(userId);
  }

  @override
  Future<void> migrateToUser({
    required List<Session> sessions,
    required String newUserId,
  }) async {
    for (final session in sessions) {
      await _dataSource.updateSession(session.copyWith(userId: newUserId));
    }
  }
}
