import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ownurtime/features/mood/data/providers/mood_providers.dart';

part 'mood_check_provider.freezed.dart';
part 'mood_check_provider.g.dart';

@freezed
sealed class MoodCheckState with _$MoodCheckState {
  const factory MoodCheckState.pending() = MoodCheckPending;
  const factory MoodCheckState.done({int? suggestedMinutes}) = MoodCheckDone;
}

@Riverpod(keepAlive: true)
class MoodCheckNotifier extends _$MoodCheckNotifier {
  @override
  MoodCheckState build() => const MoodCheckState.pending();

  Future<void> checkMood(int level) async {
    final useCase = ref.read(checkMoodUseCaseProvider);
    final (_, suggested) = await useCase(userId: 'guest', level: level);
    state = MoodCheckState.done(suggestedMinutes: suggested);
  }

  void skip() {
    state = const MoodCheckState.done();
  }
}
