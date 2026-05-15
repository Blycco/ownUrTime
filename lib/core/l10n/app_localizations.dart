import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'OwnUrTime'**
  String get appName;

  /// No description provided for @bootstrapReady.
  ///
  /// In ko, this message translates to:
  /// **'준비됐어요'**
  String get bootstrapReady;

  /// No description provided for @taskListTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 작업'**
  String get taskListTitle;

  /// No description provided for @taskListError.
  ///
  /// In ko, this message translates to:
  /// **'잠시 후 다시 시도해 주세요'**
  String get taskListError;

  /// No description provided for @taskListStartFab.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get taskListStartFab;

  /// No description provided for @taskListEmptyHeadline.
  ///
  /// In ko, this message translates to:
  /// **'오늘 첫 작업을 시작해봐요'**
  String get taskListEmptyHeadline;

  /// No description provided for @taskListEmptySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'2분이면 충분해요'**
  String get taskListEmptySubtitle;

  /// No description provided for @taskStartTitle.
  ///
  /// In ko, this message translates to:
  /// **'무엇을 할까요?'**
  String get taskStartTitle;

  /// No description provided for @taskStartHint.
  ///
  /// In ko, this message translates to:
  /// **'작업 이름 (선택)'**
  String get taskStartHint;

  /// No description provided for @taskStartDefaultTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 작업'**
  String get taskStartDefaultTitle;

  /// No description provided for @taskStartAiButton.
  ///
  /// In ko, this message translates to:
  /// **'AI로 단계 나누기'**
  String get taskStartAiButton;

  /// No description provided for @taskStartAiLimitReached.
  ///
  /// In ko, this message translates to:
  /// **'오늘도 열심히 했어요! 직접 3단계를 적어봐요.'**
  String get taskStartAiLimitReached;

  /// No description provided for @taskStartError.
  ///
  /// In ko, this message translates to:
  /// **'잠시 후 다시 시도해 주세요'**
  String get taskStartError;

  /// No description provided for @taskCardNoTitle.
  ///
  /// In ko, this message translates to:
  /// **'제목 없는 작업'**
  String get taskCardNoTitle;

  /// No description provided for @taskCardStepCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}단계로 나눠짐'**
  String taskCardStepCount(int count);

  /// No description provided for @microStartButtonLabel.
  ///
  /// In ko, this message translates to:
  /// **'2분만 해볼게요'**
  String get microStartButtonLabel;

  /// No description provided for @aiLimitPositive.
  ///
  /// In ko, this message translates to:
  /// **'오늘도 열심히 했어요!'**
  String get aiLimitPositive;

  /// No description provided for @aiLimitRemaining.
  ///
  /// In ko, this message translates to:
  /// **'AI 분해 {count}회 남음'**
  String aiLimitRemaining(int count);

  /// No description provided for @sessionDistractedButton.
  ///
  /// In ko, this message translates to:
  /// **'집중이 흐트러졌어요'**
  String get sessionDistractedButton;

  /// No description provided for @sessionResetButton.
  ///
  /// In ko, this message translates to:
  /// **'처음부터'**
  String get sessionResetButton;

  /// No description provided for @sessionExtendButton.
  ///
  /// In ko, this message translates to:
  /// **'+1분'**
  String get sessionExtendButton;

  /// No description provided for @sessionPauseButton.
  ///
  /// In ko, this message translates to:
  /// **'잠깐 멈추기'**
  String get sessionPauseButton;

  /// No description provided for @sessionResumeButton.
  ///
  /// In ko, this message translates to:
  /// **'다시 시작'**
  String get sessionResumeButton;

  /// No description provided for @sessionAdaptiveCheckinQuestion.
  ///
  /// In ko, this message translates to:
  /// **'집중 중이신가요?'**
  String get sessionAdaptiveCheckinQuestion;

  /// No description provided for @sessionAdaptiveYes.
  ///
  /// In ko, this message translates to:
  /// **'집중 중'**
  String get sessionAdaptiveYes;

  /// No description provided for @sessionAdaptiveDistracted.
  ///
  /// In ko, this message translates to:
  /// **'흐트러졌어요'**
  String get sessionAdaptiveDistracted;

  /// No description provided for @sessionCompletedTitle.
  ///
  /// In ko, this message translates to:
  /// **'세션 완료!'**
  String get sessionCompletedTitle;

  /// No description provided for @sessionDurationCustom.
  ///
  /// In ko, this message translates to:
  /// **'커스텀'**
  String get sessionDurationCustom;

  /// No description provided for @sessionDuration10Min.
  ///
  /// In ko, this message translates to:
  /// **'10분'**
  String get sessionDuration10Min;

  /// No description provided for @sessionDuration15Min.
  ///
  /// In ko, this message translates to:
  /// **'15분'**
  String get sessionDuration15Min;

  /// No description provided for @sessionDuration25Min.
  ///
  /// In ko, this message translates to:
  /// **'25분'**
  String get sessionDuration25Min;

  /// No description provided for @sessionManualWorkMode.
  ///
  /// In ko, this message translates to:
  /// **'수동 작업 모드'**
  String get sessionManualWorkMode;

  /// No description provided for @recoveryTypeUrgent.
  ///
  /// In ko, this message translates to:
  /// **'긴급해요'**
  String get recoveryTypeUrgent;

  /// No description provided for @recoveryTypeImpulsive.
  ///
  /// In ko, this message translates to:
  /// **'그냥 흘러간 거예요'**
  String get recoveryTypeImpulsive;

  /// No description provided for @recoveryTypeRest.
  ///
  /// In ko, this message translates to:
  /// **'쉬어야 해요'**
  String get recoveryTypeRest;

  /// No description provided for @recoveryUrgentMessage.
  ///
  /// In ko, this message translates to:
  /// **'무언가 생겼어요'**
  String get recoveryUrgentMessage;

  /// No description provided for @recoveryUrgentCta.
  ///
  /// In ko, this message translates to:
  /// **'처리하고 돌아와요'**
  String get recoveryUrgentCta;

  /// No description provided for @recoveryImpulsiveMessage.
  ///
  /// In ko, this message translates to:
  /// **'그런 일 있지'**
  String get recoveryImpulsiveMessage;

  /// No description provided for @recoveryImpulsiveCta.
  ///
  /// In ko, this message translates to:
  /// **'당신의 작업이 기다리고 있어요'**
  String get recoveryImpulsiveCta;

  /// No description provided for @recoveryRestMessage.
  ///
  /// In ko, this message translates to:
  /// **'좋은 결정이에요'**
  String get recoveryRestMessage;

  /// No description provided for @recoveryRestCta.
  ///
  /// In ko, this message translates to:
  /// **'준비되면 시작해요'**
  String get recoveryRestCta;

  /// No description provided for @recoveryResumeButton.
  ///
  /// In ko, this message translates to:
  /// **'다시 시작'**
  String get recoveryResumeButton;

  /// No description provided for @recoveryRestResumeButton.
  ///
  /// In ko, this message translates to:
  /// **'시작할게요'**
  String get recoveryRestResumeButton;

  /// No description provided for @recoveryContextTitle.
  ///
  /// In ko, this message translates to:
  /// **'하던 작업'**
  String get recoveryContextTitle;

  /// No description provided for @recoveryContextTaskLabel.
  ///
  /// In ko, this message translates to:
  /// **'작업:'**
  String get recoveryContextTaskLabel;

  /// No description provided for @recoveryContextStepLabel.
  ///
  /// In ko, this message translates to:
  /// **'진행 중이던 단계:'**
  String get recoveryContextStepLabel;

  /// No description provided for @recoveryContextElapsedLabel.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 진행 중'**
  String recoveryContextElapsedLabel(int minutes);

  /// No description provided for @moodSkipButton.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get moodSkipButton;

  /// No description provided for @authSignInWithApple.
  ///
  /// In ko, this message translates to:
  /// **'Apple로 로그인'**
  String get authSignInWithApple;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In ko, this message translates to:
  /// **'게스트로 계속'**
  String get authContinueAsGuest;

  /// No description provided for @authPromptTitle.
  ///
  /// In ko, this message translates to:
  /// **'진행 상황을 저장하고 여러 기기에서 이어가세요'**
  String get authPromptTitle;

  /// No description provided for @authMaybeLater.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get authMaybeLater;

  /// No description provided for @authSignInError.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다. 다시 시도해 주세요.'**
  String get authSignInError;

  /// No description provided for @rewardGreatJob.
  ///
  /// In ko, this message translates to:
  /// **'잘 했어요!'**
  String get rewardGreatJob;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
