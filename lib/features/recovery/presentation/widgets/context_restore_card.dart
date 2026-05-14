import 'package:flutter/material.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';

class ContextRestoreCard extends StatelessWidget {
  const ContextRestoreCard({
    required this.taskTitle,
    required this.currentStep,
    required this.elapsedTime,
    super.key,
  });

  final String taskTitle;
  final String? currentStep;
  final Duration elapsedTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recoveryContextTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.recoveryContextTaskLabel} $taskTitle',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (currentStep case final step? when step.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('${l10n.recoveryContextStepLabel} $step'),
            ],
            const SizedBox(height: 6),
            Text(l10n.recoveryContextElapsedLabel(elapsedTime.inMinutes)),
          ],
        ),
      ),
    );
  }
}
