import 'package:ownurtime/features/session/domain/repositories/session_repository.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';

class MigrateLocalDataUseCase {
  const MigrateLocalDataUseCase({
    required TaskRepository taskRepository,
    required SessionRepository sessionRepository,
  }) : _taskRepository = taskRepository,
       _sessionRepository = sessionRepository;

  final TaskRepository _taskRepository;
  final SessionRepository _sessionRepository;

  // 실패 시 로컬 데이터 유지 (멱등 재시도 가능).
  // Phase 2: remote Supabase batch insert + local clear로 교체.
  Future<void> call({
    required String guestUserId,
    required String authenticatedUserId,
  }) async {
    final tasks = await _taskRepository.getTasks(guestUserId);
    await _taskRepository.migrateToUser(
      tasks: tasks,
      newUserId: authenticatedUserId,
    );

    final sessions = await _sessionRepository.getSessions(guestUserId);
    await _sessionRepository.migrateToUser(
      sessions: sessions,
      newUserId: authenticatedUserId,
    );
  }
}
