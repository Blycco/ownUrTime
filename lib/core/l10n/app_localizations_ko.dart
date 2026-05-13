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
}
