import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';
import 'package:ownurtime/features/recovery/domain/repositories/distraction_repository.dart';

class RecoveryContext {
  const RecoveryContext({
    required this.taskTitle,
    required this.currentStep,
    required this.elapsedTime,
  });

  final String taskTitle;
  final String? currentStep;
  final Duration elapsedTime;
}

class RecoverSessionUseCase {
  const RecoverSessionUseCase(this._repository);

  final DistractionRepository _repository;

  Future<RecoveryContext> call({
    required Distraction distraction,
    required String taskTitle,
    required String? currentStep,
    required Duration elapsedTime,
  }) async {
    await _repository.markReturned(distraction.id);
    return RecoveryContext(
      taskTitle: taskTitle,
      currentStep: currentStep,
      elapsedTime: elapsedTime,
    );
  }
}
