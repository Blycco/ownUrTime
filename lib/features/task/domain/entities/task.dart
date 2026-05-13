import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

enum TaskStatus { pending, inProgress, completed, abandoned }

@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String userId,
    required String title,
    List<String>? decomposedSteps,
    required TaskStatus status,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _Task;
}
