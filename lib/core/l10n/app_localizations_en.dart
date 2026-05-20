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

  @override
  String get recoveryTypeUrgent => 'Urgent';

  @override
  String get recoveryTypeImpulsive => 'It just happened';

  @override
  String get recoveryTypeRest => 'Need a break';

  @override
  String get recoveryUrgentMessage => 'Something came up';

  @override
  String get recoveryUrgentCta => 'Handle it and come back';

  @override
  String get recoveryImpulsiveMessage => 'It happens';

  @override
  String get recoveryImpulsiveCta => 'Your task is waiting';

  @override
  String get recoveryRestMessage => 'Good call';

  @override
  String get recoveryRestCta => 'Start when you are ready';

  @override
  String get recoveryResumeButton => 'Resume';

  @override
  String get recoveryRestResumeButton => 'Let us start';

  @override
  String get recoveryContextTitle => 'Where you left off';

  @override
  String get recoveryContextTaskLabel => 'Task:';

  @override
  String get recoveryContextStepLabel => 'Step in progress:';

  @override
  String recoveryContextElapsedLabel(int minutes) {
    return '$minutes min into session';
  }

  @override
  String get moodSkipButton => 'Skip';

  @override
  String get authSignInWithApple => 'Sign in with Apple';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authPromptTitle => 'Save your progress and continue on any device';

  @override
  String get authMaybeLater => 'Maybe later';

  @override
  String get authSignInError => 'Sign in failed. Please try again.';

  @override
  String get rewardGreatJob => 'Great work!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get deleteAccountDialogTitle => 'Delete your account?';

  @override
  String get deleteAccountDialogBody =>
      'All your tasks and data will be permanently deleted. This cannot be undone.';

  @override
  String get deleteAccountDialogCancel => 'Cancel';

  @override
  String get deleteAccountDialogConfirm => 'Delete';

  @override
  String get deleteAccountSuccess => 'Your account has been deleted.';

  @override
  String get deleteAccountErrorNetwork => 'Network error. Please try again.';

  @override
  String get deleteAccountErrorServer =>
      'Server error. Please try again later.';

  @override
  String get settingsAppBarAction => 'Settings';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyBody =>
      'Privacy Policy\n\nThis app collects optional email address information through Apple Sign In. Collected information is used only for app functionality.\n\nUsers can permanently delete all data at any time by deleting their account.\n\nContact: support@ownurtime.app';
}
