# Task 07: Feature Reward — Codex Implementation Prompt

## Context

OwnUrTime Flutter app (Dart, Riverpod 3.x, Clean Architecture).
Branch: `feat/feature-reward`
Issue: #14

세션 완료 시 매번 (조건 없이) sound + animation을 발생시키는 Layer-1 Reward 기능을 구현한다.

## Package 현황

- `flutter_animate: ^4.1.1` — pubspec.yaml에 이미 추가됨 (flutter pub get 필요)
- `flutter/services.dart` — SystemSound, HapticFeedback (Flutter SDK 내장, 별도 import 불필요)
- `flutter_riverpod: ^3.3.1` + `riverpod_annotation: ^4.0.2` (기존)
- code generation: `riverpod_generator`, `build_runner` (기존)

## Architecture Rules

- `package:` import only (no relative imports)
- Riverpod only — no setState, no ChangeNotifier
- `@riverpod` annotation + code generation (`.g.dart` 파일 생성 필요)
- No hardcoded Korean strings — l10n 키 사용
- No `dynamic` types — 모든 Dart 코드에 타입 명시
- No `!` bang operator — null-safe 패턴 사용

## Files to Create

### 1. `lib/features/reward/presentation/providers/reward_provider.dart`

```dart
// Riverpod @riverpod 애노테이션으로 NotifierProvider 생성
// state: bool rewardVisible (초기값 false)
// show(): state = true
// hide(): state = false
// keepAlive: false (auto-dispose — 세션 화면 벗어나면 초기화)
```

After creating, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```
to generate `reward_provider.g.dart`.

### 2. `lib/features/reward/presentation/widgets/completion_reward_widget.dart`

Requirements:
- `ConsumerStatefulWidget` (AnimationController 생명주기 관리 필요)
- `initState`: 
  1. `HapticFeedback.heavyImpact()` 즉시 호출
  2. `SystemSound.play(SystemSoundType.alert)` 즉시 호출
  3. `Future.delayed(const Duration(seconds: 2), widget.onDismiss)` 등록
- Animation (flutter_animate 사용):
  - 체크마크 아이콘 (Icons.check_circle_outline): scale 0.5→1.2→1.0, fade in
  - `rewardGreatJob` l10n 문구: fade in (0.3s 딜레이)
  - 전체 위젯: 2초 후 fade out (dismiss 직전)
- Layout: 전체 화면 반투명 오버레이 (Color(0x99000000)), 중앙 정렬, 체크마크 + 텍스트
- `onDismiss` 콜백 파라미터 (VoidCallback): 2초 후 호출
- 내비게이션 차단 없음 (WillPopScope나 absorbing pointer 사용 금지)
- l10n: `AppLocalizations.of(context).rewardGreatJob` 사용
  - import: `package:ownurtime/core/l10n/app_localizations.dart`

```dart
class CompletionRewardWidget extends ConsumerStatefulWidget {
  const CompletionRewardWidget({super.key, required this.onDismiss});
  final VoidCallback onDismiss;
  // ...
}
```

### 3. `test/features/reward/presentation/completion_reward_widget_test.dart`

Test setup:
- `ProviderScope` 래핑
- `AppLocalizations` delegate 포함 (`MaterialApp` with `localizationsDelegates`)
- `MockOnDismiss` (mockito) or 단순 bool flag

Tests:
- `'widget appears with checkmark icon'`: 위젯 렌더링 시 `Icons.check_circle_outline` 존재 확인
- `'onDismiss called after 2 seconds'`: `pump(Duration(seconds: 2))` 후 onDismiss 콜백 호출 확인
- `'reward fires unconditionally — no conditional check'`: 어떤 상태 없이 위젯 단독 렌더링 가능 (props 외 조건 없음 확인)

### 4. `test/features/session/domain/timer_notifier_test.dart` — 기존 파일에 테스트 추가

기존 파일 경로: `test/features/session/domain/timer_notifier_test.dart`
기존 테스트를 건드리지 않고 하단에 테스트 그룹 추가:

```dart
group('completion event', () {
  test('state becomes TimerCompleted when timer reaches zero', () async {
    // 기존 "completes when remaining reaches 0" 패턴과 동일
    // TimerCompleted 상태 진입 확인
  });
});
```

## Run After Implementation

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Expected: zero analyze warnings, all tests pass (기존 48 + 신규 reward 테스트).

## Do NOT

- `session_screen.dart` 수정 금지 (Claude Code가 별도 처리)
- `timer_provider.dart` 수정 금지
- 사운드 asset 파일 추가 금지 (SystemSound 사용으로 불필요)
- 상대 경로 import 사용 금지
- Korean 문자열 하드코딩 금지
