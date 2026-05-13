import 'package:flutter/material.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({required this.task, this.onTap, super.key});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCompleted = task.status == TaskStatus.completed;
    final stepCount = task.decomposedSteps?.length ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(
          task.title.isEmpty ? l10n.taskCardNoTitle : task.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: stepCount > 0
            ? Text(l10n.taskCardStepCount(stepCount))
            : null,
        trailing: _StatusIcon(status: task.status),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      TaskStatus.completed => const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
      TaskStatus.inProgress => const Icon(
        Icons.play_circle,
        color: Colors.blue,
      ),
      TaskStatus.abandoned => const SizedBox.shrink(),
      TaskStatus.pending => const Icon(
        Icons.radio_button_unchecked,
        color: Colors.grey,
      ),
    };
  }
}
