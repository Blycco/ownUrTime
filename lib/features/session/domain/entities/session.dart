import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

enum SessionStatus { active, completed, abandoned }

@freezed
abstract class Session with _$Session {
  const factory Session({
    required String id,
    required String userId,
    String? taskId,
    required int targetDurationMinutes,
    required SessionStatus status,
    required int distractionCount,
    required int resetCount,
    required bool manualWorkMode,
    required DateTime startedAt,
    DateTime? completedAt,
  }) = _Session;
}
