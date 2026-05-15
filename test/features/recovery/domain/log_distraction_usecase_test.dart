import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';
import 'package:ownurtime/features/recovery/domain/repositories/distraction_repository.dart';
import 'package:ownurtime/features/recovery/domain/usecases/log_distraction_usecase.dart';

class _FakeDistractionRepository implements DistractionRepository {
  String? calledSessionId;
  DistractionType? calledType;

  @override
  Future<Distraction> logDistraction(
    String sessionId,
    DistractionType type, {
    required String userId,
  }) async {
    calledSessionId = sessionId;
    calledType = type;
    return Distraction(
      id: 'd1',
      sessionId: sessionId,
      userId: userId,
      type: type,
      occurredAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<void> markReturned(String distractionId) async {}
}

void main() {
  test('calls repository with sessionId and type', () async {
    final repo = _FakeDistractionRepository();
    final useCase = LogDistractionUseCase(repo);

    final result = await useCase(
      sessionId: 'session-1',
      type: DistractionType.urgent,
      userId: 'guest',
    );

    expect(repo.calledSessionId, 'session-1');
    expect(repo.calledType, DistractionType.urgent);
    expect(result.type, DistractionType.urgent);
  });
}
