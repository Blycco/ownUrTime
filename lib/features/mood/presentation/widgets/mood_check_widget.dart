import 'package:flutter/material.dart';
import 'package:ownurtime/core/l10n/app_localizations.dart';

class MoodCheckWidget extends StatelessWidget {
  const MoodCheckWidget({
    required this.onMoodSelected,
    required this.onSkip,
    super.key,
  });

  final void Function(int level) onMoodSelected;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    const emojis = ['😔', '😕', '😐', '🙂', '😄'];
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(emojis.length, (index) {
                return GestureDetector(
                  onTap: () => onMoodSelected(index + 1),
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: 32),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onSkip, child: Text(l10n.moodSkipButton)),
          ],
        ),
      ),
    );
  }
}
