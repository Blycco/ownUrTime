import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';
import 'package:ownurtime/features/recovery/domain/repositories/distraction_repository.dart';
import 'package:ownurtime/features/recovery/domain/usecases/recover_session_usecase.dart';

class _FakeDistractionRepository implements DistractionRepository {
  String? markedId;

  @override
  Future<Distraction> logDistraction(String sessionId, DistractionType type) {
    throw UnimplementedError();
  }

  @override
  Future<void> markReturned(String distractionId) async {
    markedId = distractionId;
  }
}

Distraction _buildDistraction(DistractionType type) {
  return Distraction(
    id: 'd1',
    sessionId: 's1',
    userId: 'guest',
    type: type,
    occurredAt: DateTime(2026, 1, 1),
  );
}

void main() {
  test('returns context with taskTitle and marks returned', () async {
    final repo = _FakeDistractionRepository();
    final useCase = RecoverSessionUseCase(repo);

    final result = await useCase(
      distraction: _buildDistraction(DistractionType.urgent),
      taskTitle: '보고서 작성',
      currentStep: '개요 정리',
      elapsedTime: const Duration(minutes: 3),
    );

    expect(result.taskTitle, '보고서 작성');
    expect(result.currentStep, '개요 정리');
    expect(result.elapsedTime, const Duration(minutes: 3));
    expect(repo.markedId, 'd1');
  });

  test('impulsive returns context and marks returned', () async {
    final repo = _FakeDistractionRepository();
    final useCase = RecoverSessionUseCase(repo);

    final result = await useCase(
      distraction: _buildDistraction(DistractionType.impulsive),
      taskTitle: 'Task',
      currentStep: null,
      elapsedTime: const Duration(minutes: 3),
    );

    expect(result.taskTitle, 'Task');
    expect(repo.markedId, 'd1');
  });

  test('rest returns context and marks returned', () async {
    final repo = _FakeDistractionRepository();
    final useCase = RecoverSessionUseCase(repo);

    final result = await useCase(
      distraction: _buildDistraction(DistractionType.rest),
      taskTitle: 'Task',
      currentStep: null,
      elapsedTime: const Duration(minutes: 3),
    );

    expect(result.taskTitle, 'Task');
    expect(repo.markedId, 'd1');
  });
}
