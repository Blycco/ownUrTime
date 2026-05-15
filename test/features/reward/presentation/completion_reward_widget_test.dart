import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/reward/presentation/widgets/completion_reward_widget.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('CompletionRewardWidget', () {
    testWidgets('widget appears with checkmark icon', (tester) async {
      await tester.pumpWidget(_wrap(CompletionRewardWidget(onDismiss: () {})));

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('onDismiss called after 2 seconds', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        _wrap(
          CompletionRewardWidget(
            onDismiss: () {
              dismissed = true;
            },
          ),
        ),
      );

      expect(dismissed, false);
      await tester.pump(const Duration(seconds: 2));
      expect(dismissed, true);
    });

    testWidgets('reward fires unconditionally — no conditional check', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(CompletionRewardWidget(onDismiss: () {})));

      expect(find.byType(CompletionRewardWidget), findsOneWidget);
      expect(find.text('잘 했어요!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
