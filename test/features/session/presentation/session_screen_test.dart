import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/session/presentation/screens/session_screen.dart';
import 'package:ownurtime/features/session/presentation/widgets/duration_selector.dart';

void main() {
  Future<void> pumpSessionScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SessionScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('distracted button always visible', (tester) async {
    await pumpSessionScreen(tester);
    await tester.tap(find.text('25분'));
    await tester.pump();

    expect(find.text('집중이 흐트러졌어요'), findsOneWidget);
  });

  testWidgets('reset button disabled after 3 uses', (tester) async {
    await pumpSessionScreen(tester);
    await tester.tap(find.text('25분'));
    await tester.pump();

    final resetFinder = find.widgetWithText(OutlinedButton, '처음부터');
    await tester.tap(resetFinder);
    await tester.pump();
    await tester.tap(resetFinder);
    await tester.pump();
    await tester.tap(resetFinder);
    await tester.pump();

    final button = tester.widget<OutlinedButton>(resetFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('custom duration is last chip', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: DurationSelector(onSelect: (_) {})),
      ),
    );

    final chips = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .toList();
    expect(chips.length, 4);

    final lastLabel = chips.last.label as Text;
    expect(lastLabel.data, '커스텀');
  });
}
