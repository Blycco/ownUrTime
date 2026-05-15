import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';

class CompletionRewardWidget extends StatefulWidget {
  const CompletionRewardWidget({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<CompletionRewardWidget> createState() => _CompletionRewardWidgetState();
}

class _CompletionRewardWidgetState extends State<CompletionRewardWidget> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    _dismissTimer = Timer(const Duration(seconds: 2), widget.onDismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
          color: const Color(0x99000000),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                      Icons.check_circle_outline,
                      size: 96,
                      color: Colors.white,
                    )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 200))
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.2, 1.2),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutBack,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 16),
                Text(
                      l10n.rewardGreatJob,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                    .animate(delay: const Duration(milliseconds: 300))
                    .fadeIn(duration: const Duration(milliseconds: 350)),
              ],
            ),
          ),
        )
        .animate(delay: const Duration(milliseconds: 1600))
        .fadeOut(duration: const Duration(milliseconds: 400));
  }
}
