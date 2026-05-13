import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    @JsonKey(name: 'decomposed_steps') List<String>? decomposedSteps,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _TaskModel;

  const TaskModel._();

  factory TaskModel.fromJson(Map<String, Object?> json) =>
      _$TaskModelFromJson(json);

  Task toEntity() {
    final TaskStatus mappedStatus = switch (status) {
      'in_progress' => TaskStatus.inProgress,
      'completed' => TaskStatus.completed,
      'abandoned' => TaskStatus.abandoned,
      _ => TaskStatus.pending,
    };

    return Task(
      id: id,
      userId: userId,
      title: title,
      decomposedSteps: decomposedSteps,
      status: mappedStatus,
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  factory TaskModel.fromEntity(Task task) {
    final String mappedStatus = switch (task.status) {
      TaskStatus.inProgress => 'in_progress',
      TaskStatus.completed => 'completed',
      TaskStatus.abandoned => 'abandoned',
      TaskStatus.pending => 'pending',
    };

    return TaskModel(
      id: task.id,
      userId: task.userId,
      title: task.title,
      decomposedSteps: task.decomposedSteps,
      status: mappedStatus,
      createdAt: task.createdAt,
      startedAt: task.startedAt,
      completedAt: task.completedAt,
    );
  }
}
