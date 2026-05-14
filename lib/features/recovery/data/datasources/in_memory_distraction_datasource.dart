import 'package:ownurtime/features/recovery/data/models/distraction_model.dart';
import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';

class InMemoryDistractionDataSource {
  final List<DistractionModel> _store = <DistractionModel>[];

  Future<DistractionModel> logDistraction(
    String sessionId,
    DistractionType type,
  ) async {
    final now = DateTime.now();
    final model = DistractionModel(
      id: now.microsecondsSinceEpoch.toString(),
      sessionId: sessionId,
      userId: 'guest',
      type: type,
      occurredAt: now,
    );
    _store.add(model);
    return model;
  }

  Future<void> markReturned(String distractionId) async {
    final index = _store.indexWhere((item) => item.id == distractionId);
    if (index == -1) return;
    _store[index] = _store[index].copyWith(returnedAt: DateTime.now());
  }
}
