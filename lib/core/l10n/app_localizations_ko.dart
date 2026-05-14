// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'OwnUrTime';

  @override
  String get bootstrapReady => '준비됐어요';

  @override
  String get taskListTitle => '오늘의 작업';

  @override
  String get taskListError => '잠시 후 다시 시도해 주세요';

  @override
  String get taskListStartFab => '시작하기';

  @override
  String get taskListEmptyHeadline => '오늘 첫 작업을 시작해봐요';

  @override
  String get taskListEmptySubtitle => '2분이면 충분해요';

  @override
  String get taskStartTitle => '무엇을 할까요?';

  @override
  String get taskStartHint => '작업 이름 (선택)';

  @override
  String get taskStartDefaultTitle => '새 작업';

  @override
  String get taskStartAiButton => 'AI로 단계 나누기';

  @override
  String get taskStartAiLimitReached => '오늘도 열심히 했어요! 직접 3단계를 적어봐요.';

  @override
  String get taskStartError => '잠시 후 다시 시도해 주세요';

  @override
  String get taskCardNoTitle => '제목 없는 작업';

  @override
  String taskCardStepCount(int count) {
    return '$count단계로 나눠짐';
  }

  @override
  String get microStartButtonLabel => '2분만 해볼게요';

  @override
  String get aiLimitPositive => '오늘도 열심히 했어요!';

  @override
  String aiLimitRemaining(int count) {
    return 'AI 분해 $count회 남음';
  }

  @override
  String get sessionDistractedButton => '집중이 흐트러졌어요';

  @override
  String get sessionResetButton => '처음부터';

  @override
  String get sessionExtendButton => '+1분';

  @override
  String get sessionPauseButton => '잠깐 멈추기';

  @override
  String get sessionResumeButton => '다시 시작';

  @override
  String get sessionAdaptiveCheckinQuestion => '집중 중이신가요?';

  @override
  String get sessionAdaptiveYes => '집중 중';

  @override
  String get sessionAdaptiveDistracted => '흐트러졌어요';

  @override
  String get sessionCompletedTitle => '세션 완료!';

  @override
  String get sessionDurationCustom => '커스텀';

  @override
  String get sessionDuration10Min => '10분';

  @override
  String get sessionDuration15Min => '15분';

  @override
  String get sessionDuration25Min => '25분';

  @override
  String get sessionManualWorkMode => '수동 작업 모드';

  @override
  String get recoveryTypeUrgent => '긴급해요';

  @override
  String get recoveryTypeImpulsive => '그냥 흘러간 거예요';

  @override
  String get recoveryTypeRest => '쉬어야 해요';

  @override
  String get recoveryUrgentMessage => '무언가 생겼어요';

  @override
  String get recoveryUrgentCta => '처리하고 돌아와요';

  @override
  String get recoveryImpulsiveMessage => '그런 일 있지';

  @override
  String get recoveryImpulsiveCta => '당신의 작업이 기다리고 있어요';

  @override
  String get recoveryRestMessage => '좋은 결정이에요';

  @override
  String get recoveryRestCta => '준비되면 시작해요';

  @override
  String get recoveryResumeButton => '다시 시작';

  @override
  String get recoveryRestResumeButton => '시작할게요';

  @override
  String get recoveryContextTitle => '하던 작업';

  @override
  String get recoveryContextTaskLabel => '작업:';

  @override
  String get recoveryContextStepLabel => '진행 중이던 단계:';

  @override
  String recoveryContextElapsedLabel(int minutes) {
    return '$minutes분 진행 중';
  }
}
