import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_check.freezed.dart';

@freezed
abstract class MoodCheck with _$MoodCheck {
  const MoodCheck._();

  const factory MoodCheck({
    required String id,
    required String userId,
    String? sessionId,
    required int moodLevel,
    required DateTime checkedAt,
  }) = _MoodCheck;

  @override
  String toString() =>
      'MoodCheck(id: $id, userId: $userId, sessionId: $sessionId, moodLevel: [redacted], checkedAt: $checkedAt)';
}
