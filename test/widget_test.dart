import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ownurtime/main.dart';

void main() {
  testWidgets('Bootstrap screen renders via GoRouter', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OwnUrTimeApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('OwnUrTime'), findsOneWidget);
  });
}
