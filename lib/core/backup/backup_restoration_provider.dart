import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ownurtime/core/backup/backup_providers.dart';
import 'package:ownurtime/features/auth/domain/entities/auth_state.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';
import 'package:ownurtime/features/session/data/providers/session_providers.dart';
import 'package:ownurtime/features/session/domain/entities/session.dart';
import 'package:ownurtime/features/task/data/models/task_model.dart';
import 'package:ownurtime/features/task/data/providers/task_data_providers.dart';

part 'backup_restoration_provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> backupRestoration(Ref ref) async {
  // ref.read (not ref.watch) — one-shot boot restore, must not re-run on
  // auth state changes (e.g. incrementSessionCompletionCount) which would
  // silently overwrite in-memory data the user accumulated this session.
  final authState = await ref.read(authProvider.future);
  if (authState is! AuthGuest) return;

  final service = ref.read(iCloudBackupServiceProvider);
  final userId = authState.userId;

  try {
    final backup = await service.restore(userId: userId);
    if (backup == null) return;

    // Parsing uses `as` casts and DateTime.parse which throw Error/FormatException.
    // A corrupt or schema-mismatched iCloud file must not prevent the app from
    // starting — catch everything and skip hydration rather than crashing.
    final tasks = backup.tasks.map(TaskModel.fromJson).toList();
    final sessions = backup.sessions.map(_sessionFromJson).toList();

    ref.read(inMemoryTaskDataSourceProvider).hydrate(tasks);
    ref.read(inMemorySessionDataSourceProvider).hydrate(sessions);
  } catch (_) {
    // Corrupt/outdated backup — skip hydration, app starts with empty state
  }
}

@Riverpod(keepAlive: true)
class BackupTriggerNotifier extends _$BackupTriggerNotifier {
  @override
  bool build() => false;

  Future<void> trigger() async {
    try {
      final authState = ref.read(authProvider).value;
      if (authState is! AuthGuest) return;
      final userId = authState.userId;

      final tasks = await ref
          .read(taskLocalDataSourceProvider)
          .getTasks(userId);
      final sessions = await ref
          .read(sessionLocalDataSourceProvider)
          .getSessions(userId);

      await ref
          .read(iCloudBackupServiceProvider)
          .backup(
            userId: userId,
            tasks: tasks.map((t) => t.toJson()).toList(),
            sessions: sessions.map(_sessionToJson).toList(),
          );
    } catch (_) {
      // non-critical — backup failure silently ignored
    }
  }
}

Map<String, dynamic> _sessionToJson(Session session) => <String, dynamic>{
  'id': session.id,
  'user_id': session.userId,
  'task_id': session.taskId,
  'target_duration_minutes': session.targetDurationMinutes,
  'status': session.status.name,
  'distraction_count': session.distractionCount,
  'reset_count': session.resetCount,
  'manual_work_mode': session.manualWorkMode,
  'started_at': session.startedAt.toIso8601String(),
  'completed_at': session.completedAt?.toIso8601String(),
};

Session _sessionFromJson(Map<String, dynamic> json) => Session(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  taskId: json['task_id'] as String?,
  targetDurationMinutes: json['target_duration_minutes'] as int,
  status: SessionStatus.values.byName(json['status'] as String),
  distractionCount: json['distraction_count'] as int,
  resetCount: json['reset_count'] as int,
  manualWorkMode: json['manual_work_mode'] as bool,
  startedAt: DateTime.parse(json['started_at'] as String),
  completedAt: json['completed_at'] != null
      ? DateTime.parse(json['completed_at'] as String)
      : null,
);
