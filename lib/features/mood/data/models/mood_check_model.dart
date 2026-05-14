import 'package:ownurtime/features/mood/domain/entities/mood_check.dart';

class MoodCheckModel {
  const MoodCheckModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.moodLevel,
    required this.checkedAt,
  });

  final String id;
  final String userId;
  final String? sessionId;
  final int moodLevel;
  final DateTime checkedAt;

  factory MoodCheckModel.fromJson(Map<String, dynamic> json) {
    return MoodCheckModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String?,
      moodLevel: json['moodLevel'] as int,
      checkedAt: DateTime.parse(json['checkedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'moodLevel': moodLevel,
      'checkedAt': checkedAt.toIso8601String(),
    };
  }

  MoodCheck toEntity() {
    return MoodCheck(
      id: id,
      userId: userId,
      sessionId: sessionId,
      moodLevel: moodLevel,
      checkedAt: checkedAt,
    );
  }

  factory MoodCheckModel.fromEntity(MoodCheck e) {
    return MoodCheckModel(
      id: e.id,
      userId: e.userId,
      sessionId: e.sessionId,
      moodLevel: e.moodLevel,
      checkedAt: e.checkedAt,
    );
  }
}
