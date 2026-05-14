import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';

class DistractionModel {
  const DistractionModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.type,
    required this.occurredAt,
    this.returnedAt,
  });

  final String id;
  final String sessionId;
  final String userId;
  final DistractionType type;
  final DateTime occurredAt;
  final DateTime? returnedAt;

  factory DistractionModel.fromEntity(Distraction entity) {
    return DistractionModel(
      id: entity.id,
      sessionId: entity.sessionId,
      userId: entity.userId,
      type: entity.type,
      occurredAt: entity.occurredAt,
      returnedAt: entity.returnedAt,
    );
  }

  Distraction toEntity() {
    return Distraction(
      id: id,
      sessionId: sessionId,
      userId: userId,
      type: type,
      occurredAt: occurredAt,
      returnedAt: returnedAt,
    );
  }

  DistractionModel copyWith({DateTime? returnedAt}) {
    return DistractionModel(
      id: id,
      sessionId: sessionId,
      userId: userId,
      type: type,
      occurredAt: occurredAt,
      returnedAt: returnedAt ?? this.returnedAt,
    );
  }
}
