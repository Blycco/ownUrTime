import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';

abstract interface class DistractionRepository {
  Future<Distraction> logDistraction(String sessionId, DistractionType type);
  Future<void> markReturned(String distractionId);
}
