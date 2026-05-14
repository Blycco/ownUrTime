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
}
