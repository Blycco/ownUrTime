import 'package:ownurtime/features/session/domain/entities/session.dart';

class SessionModel {
  const SessionModel({
    required this.id,
    required this.userId,
    this.taskId,
    required this.targetDurationMinutes,
    required this.status,
    required this.distractionCount,
    required this.resetCount,
    required this.manualWorkMode,
    required this.startedAt,
    this.completedAt,
  });

  final String id;
  final String userId;
  final String? taskId;
  final int targetDurationMinutes;
  final SessionStatus status;
  final int distractionCount;
  final int resetCount;
  final bool manualWorkMode;
  final DateTime startedAt;
  final DateTime? completedAt;

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      taskId: json['task_id'] as String?,
      targetDurationMinutes: json['target_duration_minutes'] as int,
      status: _statusFromJson(json['status'] as String),
      distractionCount: json['distraction_count'] as int,
      resetCount: json['reset_count'] as int,
      manualWorkMode: json['manual_work_mode'] as bool,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  factory SessionModel.fromEntity(Session session) {
    return SessionModel(
      id: session.id,
      userId: session.userId,
      taskId: session.taskId,
      targetDurationMinutes: session.targetDurationMinutes,
      status: session.status,
      distractionCount: session.distractionCount,
      resetCount: session.resetCount,
      manualWorkMode: session.manualWorkMode,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_id': taskId,
      'target_duration_minutes': targetDurationMinutes,
      'status': _statusToJson(status),
      'distraction_count': distractionCount,
      'reset_count': resetCount,
      'manual_work_mode': manualWorkMode,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Session toEntity() {
    return Session(
      id: id,
      userId: userId,
      taskId: taskId,
      targetDurationMinutes: targetDurationMinutes,
      status: status,
      distractionCount: distractionCount,
      resetCount: resetCount,
      manualWorkMode: manualWorkMode,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  static SessionStatus _statusFromJson(String raw) {
    switch (raw) {
      case 'active':
        return SessionStatus.active;
      case 'completed':
        return SessionStatus.completed;
      case 'abandoned':
        return SessionStatus.abandoned;
      default:
        throw ArgumentError.value(raw, 'status', 'Unknown session status');
    }
  }

  static String _statusToJson(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return 'active';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.abandoned:
        return 'abandoned';
    }
  }
}
