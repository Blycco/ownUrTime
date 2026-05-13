import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/task/presentation/widgets/micro_start_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('ko'),
  home: Scaffold(body: child),
);

void main() {
  group('MicroStartButton', () {
    testWidgets('버튼 문구를 표시한다', (tester) async {
      await tester.pumpWidget(_wrap(MicroStartButton(onPressed: () {})));
      await tester.pumpAndSettle();

      expect(find.text('2분만 해볼게요'), findsOneWidget);
    });

    testWidgets('탭 한 번에 콜백을 1회 호출하고 높이가 72다', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        _wrap(MicroStartButton(onPressed: () => tapCount++)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(tapCount, 1);

      final sizeBoxFinder = find.descendant(
        of: find.byType(MicroStartButton),
        matching: find.byType(SizedBox),
      );
      final sizeBox = tester.widget<SizedBox>(sizeBoxFinder);
      expect(sizeBox.height, 72);
    });
  });
}
