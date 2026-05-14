enum DistractionType { urgent, impulsive, rest }

class Distraction {
  const Distraction({
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

  Distraction copyWith({
    String? id,
    String? sessionId,
    String? userId,
    DistractionType? type,
    DateTime? occurredAt,
    DateTime? returnedAt,
  }) {
    return Distraction(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      returnedAt: returnedAt ?? this.returnedAt,
    );
  }
}
