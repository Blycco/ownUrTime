import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/presentation/providers/task_provider.dart';
import 'package:ownurtime/features/task/presentation/screens/task_list_screen.dart';
import 'package:ownurtime/features/task/presentation/widgets/task_card.dart';

class FakeTaskListNotifier extends TaskListNotifier {
  FakeTaskListNotifier(this._tasks);

  final List<Task> _tasks;

  @override
  Future<List<Task>> build() async => _tasks;
}

Task _task(String id, String title) => Task(
  id: id,
  userId: 'guest',
  title: title,
  status: TaskStatus.pending,
  createdAt: DateTime(2026, 1, 1),
);

Widget _buildApp(List<Task> tasks) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const TaskListScreen()),
    ],
  );

  return ProviderScope(
    overrides: [
      taskListProvider.overrideWith(() => FakeTaskListNotifier(tasks)),
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
  group('TaskListScreen', () {
    testWidgets('태스크가 없을 때 empty 안내 문구를 표시한다', (tester) async {
      await tester.pumpWidget(_buildApp([]));
      await tester.pumpAndSettle();

      final hasPrimaryText = find.text('오늘 첫 작업을 시작해봐요').evaluate().isNotEmpty;
      final hasSecondaryText = find.text('2분이면 충분해요').evaluate().isNotEmpty;

      expect(hasPrimaryText || hasSecondaryText, isTrue);
    });

    testWidgets('시작하기 FAB를 항상 표시하고, 태스크가 있으면 TaskCard 목록을 표시한다', (
      tester,
    ) async {
      final tasks = [_task('t1', '첫 작업'), _task('t2', '두 번째 작업')];

      await tester.pumpWidget(_buildApp(tasks));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FloatingActionButton, '시작하기'), findsOneWidget);
      expect(find.byType(TaskCard), findsNWidgets(tasks.length));
    });
  });
}
