import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/main.dart';

void main() {
  testWidgets('App renders task list screen on launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: _LocalizedApp()));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp();

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('ko'),
      delegates: AppLocalizations.localizationsDelegates,
      child: const OwnUrTimeApp(),
    );
  }
}
