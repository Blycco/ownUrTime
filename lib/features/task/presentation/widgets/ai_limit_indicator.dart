import 'package:flutter/material.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';

class AiLimitIndicator extends StatelessWidget {
  const AiLimitIndicator({required this.remaining, super.key});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (remaining <= 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          l10n.aiLimitPositive,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        l10n.aiLimitRemaining(remaining),
        style: TextStyle(
          color: remaining <= 2 ? Colors.amber.shade700 : Colors.grey,
          fontSize: 13,
        ),
      ),
    );
  }
}
