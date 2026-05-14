import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';
import 'package:ownurtime/features/recovery/presentation/screens/recovery_screen.dart';
import 'package:ownurtime/features/session/domain/entities/timer_state.dart';
import 'package:ownurtime/features/session/presentation/providers/timer_provider.dart';

Distraction _testDistraction() => Distraction(
  id: 'd1',
  sessionId: 's1',
  userId: 'guest',
  type: DistractionType.impulsive,
  occurredAt: DateTime(2026, 1, 1),
);

Future<void> pumpRecoveryScreen(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RecoveryScreen(
          distraction: _testDistraction(),
          taskTitle: '문서 작성',
          currentStep: '개요 정리',
          elapsedTime: const Duration(minutes: 12),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows type buttons', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await pumpRecoveryScreen(tester, container: container);

    expect(find.text('긴급해요'), findsOneWidget);
    expect(find.text('그냥 흘러간 거예요'), findsOneWidget);
    expect(find.text('쉬어야 해요'), findsOneWidget);
  });

  testWidgets('tap urgent shows message and context card', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await pumpRecoveryScreen(tester, container: container);

    await tester.tap(find.text('긴급해요'));
    await tester.pumpAndSettle();

    expect(find.text('무언가 생겼어요'), findsOneWidget);
    expect(find.text('하던 작업'), findsOneWidget);
  });

  testWidgets('tap resume calls timer resume path', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(timerProvider.notifier)
        .start(const Duration(minutes: 10));
    await container.read(timerProvider.notifier).declareDistraction();

    await pumpRecoveryScreen(tester, container: container);

    await tester.tap(find.text('긴급해요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다시 시작'));
    await tester.pump();

    expect(container.read(timerProvider), isA<TimerRunning>());

    container.read(timerProvider.notifier).pause();
    await tester.pump();
  });
}
