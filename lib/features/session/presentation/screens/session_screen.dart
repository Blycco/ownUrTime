import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/auth/domain/entities/auth_state.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';
import 'package:ownurtime/features/auth/presentation/widgets/sign_in_prompt_sheet.dart';
import 'package:ownurtime/features/mood/presentation/providers/mood_check_provider.dart';
import 'package:ownurtime/features/mood/presentation/widgets/mood_check_widget.dart';
import 'package:ownurtime/features/session/domain/entities/timer_state.dart';
import 'package:ownurtime/features/session/presentation/providers/timer_provider.dart';
import 'package:ownurtime/features/session/presentation/widgets/adaptive_checkin_overlay.dart';
import 'package:ownurtime/features/session/presentation/widgets/duration_selector.dart';
import 'package:ownurtime/features/session/presentation/widgets/timer_display.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key, this.taskId, this.taskTitle});

  final String? taskId;
  final String? taskTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.listen<AsyncValue<AuthState>>(authProvider, (prev, next) {
      final prevCount = prev?.value?.sessionCompletionCount ?? 0;
      final nextCount = next.value?.sessionCompletionCount ?? 0;
      final dismissed = ref.read(signInPromptProvider);
      if (nextCount >= 3 && prevCount < 3 && !dismissed && context.mounted) {
        showModalBottomSheet<void>(
          context: context,
          builder: (_) => const SignInPromptSheet(),
        );
      }
    });
    final timerState = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    Future<void> handleDistraction() async {
      final distraction = await notifier.declareDistraction();
      if (!context.mounted || distraction == null) return;
      final paused = ref.read(timerProvider);
      if (paused is! TimerPaused) return;

      final total = notifier.targetDuration ?? paused.remaining;
      final elapsed = total - paused.remaining;
      await context.push(
        '/recovery',
        extra: <String, Object?>{
          'distraction': distraction,
          'taskTitle': taskTitle ?? '',
          'currentStep': null,
          'elapsedTime': elapsed,
        },
      );
    }

    final moodState = ref.watch(moodCheckProvider);
    final moodNotifier = ref.read(moodCheckProvider.notifier);

    Widget body;
    if (timerState is TimerCompleted) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.sessionCompletedTitle),
            const SizedBox(height: 16),
            MoodCheckWidget(
              onMoodSelected: (level) =>
                  unawaited(moodNotifier.checkMood(level)),
              onSkip: moodNotifier.skip,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(MaterialLocalizations.of(context).backButtonTooltip),
            ),
          ],
        ),
      );
    } else if (timerState is TimerRunning || timerState is TimerPaused) {
      final remaining = timerState is TimerRunning
          ? timerState.remaining
          : (timerState as TimerPaused).remaining;
      final total = Duration(
        minutes: notifier.targetDuration?.inMinutes ?? remaining.inMinutes,
      );
      final resetCount = timerState is TimerRunning ? timerState.resetCount : 0;
      final canReset = resetCount < 3;

      body = Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: TimerDisplay(remaining: remaining, total: total),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: handleDistraction,
              child: Text(l10n.sessionDistractedButton),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: canReset && timerState is TimerRunning
                      ? notifier.reset
                      : null,
                  child: Text(l10n.sessionResetButton),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: timerState is TimerRunning
                      ? notifier.extend
                      : null,
                  child: Text(l10n.sessionExtendButton),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: timerState is TimerRunning
                  ? notifier.pause
                  : notifier.resume,
              child: Text(
                timerState is TimerRunning
                    ? l10n.sessionPauseButton
                    : l10n.sessionResumeButton,
              ),
            ),
          ),
        ],
      );
    } else {
      final suggestedMinutes = switch (moodState) {
        MoodCheckDone(:final suggestedMinutes) => suggestedMinutes,
        _ => null,
      };
      body = Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (moodState is MoodCheckPending)
              MoodCheckWidget(
                onMoodSelected: (level) =>
                    unawaited(moodNotifier.checkMood(level)),
                onSkip: moodNotifier.skip,
              )
            else
              DurationSelector(
                suggestedMinutes: suggestedMinutes,
                onSelect: (duration) {
                  ref
                      .read(timerProvider.notifier)
                      .start(duration, taskId: taskId);
                },
              ),
          ],
        ),
      );
    }

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyP, meta: true, shift: true):
            ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              unawaited(handleDistraction());
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(),
            body: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: body,
                  ),
                ),
                if (timerState is TimerRunning &&
                    timerState.adaptiveCheckInVisible)
                  const Positioned.fill(child: AdaptiveCheckinOverlay()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
