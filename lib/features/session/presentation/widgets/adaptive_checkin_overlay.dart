import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/session/presentation/providers/timer_provider.dart';

class AdaptiveCheckinOverlay extends ConsumerStatefulWidget {
  const AdaptiveCheckinOverlay({super.key});

  @override
  ConsumerState<AdaptiveCheckinOverlay> createState() =>
      _AdaptiveCheckinOverlayState();
}

class _AdaptiveCheckinOverlayState
    extends ConsumerState<AdaptiveCheckinOverlay> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(const Duration(seconds: 10), () {
      ref.read(timerProvider.notifier).dismissAdaptiveCheckIn(focused: true);
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.sessionAdaptiveCheckinQuestion),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(timerProvider.notifier)
                          .dismissAdaptiveCheckIn(focused: true);
                    },
                    child: Text(l10n.sessionAdaptiveYes),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(timerProvider.notifier)
                          .dismissAdaptiveCheckIn(focused: false);
                    },
                    child: Text(l10n.sessionAdaptiveDistracted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
