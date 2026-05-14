import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:ownurtime/features/mood/domain/entities/mood_check.dart';
import 'package:ownurtime/features/mood/domain/repositories/mood_repository.dart';
import 'package:ownurtime/features/mood/domain/usecases/check_mood_usecase.dart';

import 'check_mood_usecase_test.mocks.dart';

@GenerateMocks([MoodRepository])
void main() {
  late MockMoodRepository repository;
  late CheckMoodUseCase useCase;

  setUp(() {
    repository = MockMoodRepository();
    useCase = CheckMoodUseCase(repository);
  });

  MoodCheck buildMoodCheck(int level) => MoodCheck(
    id: 'check-$level',
    userId: 'user-1',
    sessionId: 'session-1',
    moodLevel: level,
    checkedAt: DateTime(2026, 1, 1),
  );

  Future<(MoodCheck, int)> executeWithLevel(int level) async {
    final check = buildMoodCheck(level);
    when(
      repository.saveMoodCheck(any, any, sessionId: anyNamed('sessionId')),
    ).thenAnswer((_) async => check);

    return useCase(userId: 'user-1', level: level, sessionId: 'session-1');
  }

  test('level 1 suggests 10 minutes', () async {
    final (_, suggestedMinutes) = await executeWithLevel(1);

    expect(suggestedMinutes, 10);
  });

  test('level 2 suggests 10 minutes', () async {
    final (_, suggestedMinutes) = await executeWithLevel(2);

    expect(suggestedMinutes, 10);
  });

  test('level 3 suggests 15 minutes', () async {
    final (_, suggestedMinutes) = await executeWithLevel(3);

    expect(suggestedMinutes, 15);
  });

  test('level 4 suggests 25 minutes', () async {
    final (_, suggestedMinutes) = await executeWithLevel(4);

    expect(suggestedMinutes, 25);
  });

  test('level 5 suggests 25 minutes', () async {
    final (_, suggestedMinutes) = await executeWithLevel(5);

    expect(suggestedMinutes, 25);
  });

  test('calls saveMoodCheck with correct userId and level', () async {
    final check = buildMoodCheck(4);
    when(
      repository.saveMoodCheck(any, any, sessionId: anyNamed('sessionId')),
    ).thenAnswer((_) async => check);

    await useCase(userId: 'user-42', level: 4, sessionId: 'session-7');

    verify(
      repository.saveMoodCheck('user-42', 4, sessionId: 'session-7'),
    ).called(1);
  });

  test('returns MoodCheck with correct moodLevel', () async {
    final check = buildMoodCheck(3);
    when(
      repository.saveMoodCheck(any, any, sessionId: anyNamed('sessionId')),
    ).thenAnswer((_) async => check);

    final (result, _) = await useCase(
      userId: 'user-1',
      level: 3,
      sessionId: 'session-1',
    );

    expect(result.moodLevel, 3);
  });
}
