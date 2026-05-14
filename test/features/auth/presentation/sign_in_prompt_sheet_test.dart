import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/auth/domain/entities/auth_state.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';
import 'package:ownurtime/features/auth/presentation/widgets/sign_in_prompt_sheet.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async =>
      const AuthState.guest(sessionCompletionCount: 0);
}

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier()),
      signInPromptProvider.overrideWith(() => SignInPromptNotifier()),
    ],
    child: const MaterialApp(
      locale: Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SignInPromptSheet()),
    ),
  );
}

void main() {
  testWidgets('SignInPromptSheet 렌더링 시 Apple 로그인 버튼이 보인다', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Apple로 로그인'), findsOneWidget);
  });

  testWidgets('나중에 버튼 탭 시 signInPromptNotifier 상태가 true가 된다', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FakeAuthNotifier()),
        signInPromptProvider.overrideWith(() => SignInPromptNotifier()),
      ],
    );
    // Keep signInPromptProvider alive: it's auto-dispose and only ref.read
    // in the widget, so without a listener it would dispose after the tap.
    final sub = container.listen<bool>(signInPromptProvider, (prev, next) {});

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SignInPromptSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('나중에'));
    await tester.pumpAndSettle();

    expect(container.read(signInPromptProvider), isTrue);

    sub.close();
    container.dispose();
  });
}
