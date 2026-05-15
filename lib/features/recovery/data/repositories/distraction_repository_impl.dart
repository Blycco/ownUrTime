import 'package:ownurtime/features/recovery/data/datasources/in_memory_distraction_datasource.dart';
import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';
import 'package:ownurtime/features/recovery/domain/repositories/distraction_repository.dart';

class DistractionRepositoryImpl implements DistractionRepository {
  const DistractionRepositoryImpl(this._dataSource);

  final InMemoryDistractionDataSource _dataSource;

  @override
  Future<Distraction> logDistraction(
    String sessionId,
    DistractionType type, {
    required String userId,
  }) async {
    final model = await _dataSource.logDistraction(
      sessionId,
      type,
      userId: userId,
    );
    return model.toEntity();
  }

  @override
  Future<void> markReturned(String distractionId) {
    return _dataSource.markReturned(distractionId);
  }
}
