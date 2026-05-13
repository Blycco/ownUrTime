// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => _TaskModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  decomposedSteps: (json['decomposed_steps'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
);

Map<String, dynamic> _$TaskModelToJson(_TaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'decomposed_steps': instance.decomposedSteps,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };
