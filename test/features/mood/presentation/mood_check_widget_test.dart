import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/mood/presentation/widgets/mood_check_widget.dart';

Future<void> pumpMoodCheckWidget(
  WidgetTester tester, {
  required void Function(int level) onMoodSelected,
  required VoidCallback onSkip,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MoodCheckWidget(onMoodSelected: onMoodSelected, onSkip: onSkip),
      ),
    ),
  );
}

void main() {
  testWidgets('shows 5 emoji buttons', (tester) async {
    await pumpMoodCheckWidget(tester, onMoodSelected: (_) {}, onSkip: () {});

    expect(find.text('😔'), findsOneWidget);
    expect(find.text('😕'), findsOneWidget);
    expect(find.text('😐'), findsOneWidget);
    expect(find.text('🙂'), findsOneWidget);
    expect(find.text('😄'), findsOneWidget);
  });

  testWidgets('tap first emoji calls onMoodSelected(1)', (tester) async {
    int? selectedLevel;

    await pumpMoodCheckWidget(
      tester,
      onMoodSelected: (level) => selectedLevel = level,
      onSkip: () {},
    );

    await tester.tap(find.text('😔'));
    await tester.pump();

    expect(selectedLevel, 1);
  });

  testWidgets('tap last emoji calls onMoodSelected(5)', (tester) async {
    int? selectedLevel;

    await pumpMoodCheckWidget(
      tester,
      onMoodSelected: (level) => selectedLevel = level,
      onSkip: () {},
    );

    await tester.tap(find.text('😄'));
    await tester.pump();

    expect(selectedLevel, 5);
  });

  testWidgets('shows skip option text button', (tester) async {
    await pumpMoodCheckWidget(tester, onMoodSelected: (_) {}, onSkip: () {});

    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('tap skip calls onSkip callback', (tester) async {
    var skipCalled = false;

    await pumpMoodCheckWidget(
      tester,
      onMoodSelected: (_) {},
      onSkip: () => skipCalled = true,
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    expect(skipCalled, isTrue);
  });
}
