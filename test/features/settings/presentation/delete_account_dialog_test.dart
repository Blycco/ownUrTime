import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/auth/domain/entities/auth_state.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';
import 'package:ownurtime/features/settings/presentation/widgets/delete_account_dialog.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({required this.onDelete});

  final Future<void> Function() onDelete;

  @override
  Future<AuthState> build() async => const AuthState.guest();

  @override
  Future<void> deleteAccount() => onDelete();
}

Widget _buildTestApp({required Future<void> Function() onDelete}) {
  final router = GoRouter(
    initialLocation: '/dialog',
    routes: [
      GoRoute(
        path: '/dialog',
        builder: (context, state) => Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const DeleteAccountDialog(),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const Scaffold(body: Text('tasks-screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(onDelete: onDelete)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'),
    ),
  );
}

void main() {
  group('DeleteAccountDialog', () {
    testWidgets('TC-04: 다이얼로그 렌더링', (tester) async {
      await tester.pumpWidget(_buildTestApp(onDelete: () async {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('계정을 삭제할까요?'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('삭제'), findsOneWidget);
    });

    testWidgets('TC-05: 취소 버튼 탭', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildTestApp(
          onDelete: () async {
            called = true;
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(find.text('계정을 삭제할까요?'), findsNothing);
      expect(called, isFalse);
    });

    testWidgets('TC-06: 삭제 버튼 탭 → 성공', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _buildTestApp(
          onDelete: () async {
            await completer.future;
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('삭제'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('tasks-screen'), findsOneWidget);
    });
  });
}
