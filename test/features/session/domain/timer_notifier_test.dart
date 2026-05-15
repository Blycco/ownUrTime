import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/features/session/domain/entities/timer_state.dart';
import 'package:ownurtime/features/session/presentation/providers/timer_provider.dart';

void main() {
  group('TimerNotifier', () {
    test('start → running state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(timerProvider.notifier)
          .start(const Duration(minutes: 25));
      final state = container.read(timerProvider);

      expect(state, isA<TimerRunning>());
    });

    test('reset increments counter, blocked at 3', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(timerProvider.notifier)
          .start(const Duration(minutes: 25));
      final notifier = container.read(timerProvider.notifier);

      notifier.reset();
      notifier.reset();
      notifier.reset();

      final thirdState = container.read(timerProvider) as TimerRunning;
      expect(thirdState.resetCount, 3);

      notifier.reset();
      final fourthState = container.read(timerProvider) as TimerRunning;
      expect(fourthState.resetCount, 3);
    });

    test('extend adds 1 minute', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(timerProvider.notifier)
          .start(const Duration(minutes: 25));
      final notifier = container.read(timerProvider.notifier);
      final before = container.read(timerProvider) as TimerRunning;

      notifier.extend();

      final after = container.read(timerProvider) as TimerRunning;
      expect(after.remaining.inSeconds, before.remaining.inSeconds + 60);
    });

    test('completes when remaining reaches 0', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // keepAlive: true이지만 listen으로 명시적 구독 유지
      final sub = container.listen<TimerState>(timerProvider, (prev, next) {});
      addTearDown(sub.close);

      await container
          .read(timerProvider.notifier)
          .start(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      final state = container.read(timerProvider);
      expect(state, isA<TimerCompleted>());
    });

    test('pause and resume', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(timerProvider.notifier)
          .start(const Duration(minutes: 25));
      final notifier = container.read(timerProvider.notifier);

      notifier.pause();
      final paused = container.read(timerProvider);
      expect(paused, isA<TimerPaused>());

      notifier.resume();
      final resumed = container.read(timerProvider);
      expect(resumed, isA<TimerRunning>());
    });
  });

  group('completion event', () {
    test('state becomes TimerCompleted when timer reaches zero', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sub = container.listen<TimerState>(timerProvider, (prev, next) {});
      addTearDown(sub.close);

      await container
          .read(timerProvider.notifier)
          .start(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      final state = container.read(timerProvider);
      expect(state, isA<TimerCompleted>());
    });
  });
}
