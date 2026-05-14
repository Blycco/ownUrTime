import 'package:ownurtime/features/session/data/datasources/session_local_datasource.dart';
import 'package:ownurtime/features/session/domain/entities/session.dart';

class InMemorySessionDataSource implements SessionLocalDataSource {
  final Map<String, Session> _store = {};

  @override
  Future<Session> startSession({
    required String userId,
    String? taskId,
    required int targetDurationMinutes,
    required bool manualWorkMode,
  }) async {
    final now = DateTime.now();
    final session = Session(
      id: now.microsecondsSinceEpoch.toString(),
      userId: userId,
      taskId: taskId,
      targetDurationMinutes: targetDurationMinutes,
      status: SessionStatus.active,
      distractionCount: 0,
      resetCount: 0,
      manualWorkMode: manualWorkMode,
      startedAt: now,
    );
    _store[session.id] = session;
    return session;
  }

  @override
  Future<Session> completeSession(String sessionId) async {
    final existing = _requireSession(sessionId);
    final updated = existing.copyWith(
      status: SessionStatus.completed,
      completedAt: DateTime.now(),
    );
    _store[sessionId] = updated;
    return updated;
  }

  @override
  Future<Session> abandonSession(String sessionId) async {
    final existing = _requireSession(sessionId);
    final updated = existing.copyWith(status: SessionStatus.abandoned);
    _store[sessionId] = updated;
    return updated;
  }

  @override
  Future<Session> updateSession(Session session) async {
    _store[session.id] = session;
    return session;
  }

  @override
  Future<List<Session>> getSessions(String userId) async =>
      _store.values.where((session) => session.userId == userId).toList();

  Session _requireSession(String sessionId) {
    final session = _store[sessionId];
    if (session != null) {
      return session;
    }
    throw StateError('Session not found: $sessionId');
  }
}
