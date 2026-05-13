// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'OwnUrTime';

  @override
  String get bootstrapReady => 'Ready';

  @override
  String get taskListTitle => 'Today\'s Tasks';

  @override
  String get taskListError => 'Please try again later';

  @override
  String get taskListStartFab => 'Start';

  @override
  String get taskListEmptyHeadline => 'Start your first task today';

  @override
  String get taskListEmptySubtitle => 'Two minutes is all you need';

  @override
  String get taskStartTitle => 'What will you work on?';

  @override
  String get taskStartHint => 'Task name (optional)';

  @override
  String get taskStartDefaultTitle => 'New task';

  @override
  String get taskStartAiButton => 'Break it down with AI';

  @override
  String get taskStartAiLimitReached =>
      'You worked hard today! Try writing 3 steps yourself.';

  @override
  String get taskStartError => 'Please try again later';

  @override
  String get taskCardNoTitle => 'Untitled task';

  @override
  String taskCardStepCount(int count) {
    return '$count steps';
  }

  @override
  String get microStartButtonLabel => 'Just 2 minutes';

  @override
  String get aiLimitPositive => 'You worked hard today!';

  @override
  String aiLimitRemaining(int count) {
    return '$count AI breakdowns remaining';
  }

  @override
  String get sessionDistractedButton => 'I got distracted';

  @override
  String get sessionResetButton => 'Reset';

  @override
  String get sessionExtendButton => '+1 min';

  @override
  String get sessionPauseButton => 'Pause';

  @override
  String get sessionResumeButton => 'Resume';

  @override
  String get sessionAdaptiveCheckinQuestion => 'Are you focused?';

  @override
  String get sessionAdaptiveYes => 'Focused';

  @override
  String get sessionAdaptiveDistracted => 'Distracted';

  @override
  String get sessionCompletedTitle => 'Session Complete!';

  @override
  String get sessionDurationCustom => 'Custom';

  @override
  String get sessionDuration10Min => '10 min';

  @override
  String get sessionDuration15Min => '15 min';

  @override
  String get sessionDuration25Min => '25 min';

  @override
  String get sessionManualWorkMode => 'Manual work mode';
}
