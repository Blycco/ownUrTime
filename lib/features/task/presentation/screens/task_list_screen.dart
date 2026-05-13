import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart'
    show TaskStatus;
import 'package:ownurtime/features/task/presentation/providers/task_provider.dart';
import 'package:ownurtime/features/task/presentation/widgets/task_card.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskListTitle)),
      body: tasksAsync.when(
        data: (tasks) {
          final visible = tasks
              .where((t) => t.status != TaskStatus.abandoned)
              .toList();
          if (visible.isEmpty) {
            return _EmptyState(l10n: l10n);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: visible.length,
            itemBuilder: (context, index) => TaskCard(task: visible[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.taskListError)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/start'),
        icon: const Icon(Icons.add),
        label: Text(l10n.taskListStartFab),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wb_sunny_outlined, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            l10n.taskListEmptyHeadline,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taskListEmptySubtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
