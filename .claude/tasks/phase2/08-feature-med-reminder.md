# Task 08: 약 복용 리마인더 — Phase 2

> **선제 조건**: Task 02 완료 (온보딩 — 알림 opt-in 흐름 연동)
> **Claude Code 담당**: ReminderSetting 엔티티, 알림 아키텍처, Deep link 설계, 온보딩 연동 포인트
> **Codex 담당**: 모든 코드 작성 (LocalNotification 구현, 설정 UI, 요일 선택, 테스트 전부)
> **PRD ref**: Phase 2 기능 목록, adhd-domain.md
> **ADHD UX 원칙**: opt-in only, 알림 탭 = 즉시 세션 시작 가능, 강요 없음

---

## 1. 설계 명세 (Claude Code)

### 1-1. ReminderSetting 엔티티

```dart
// lib/features/reminder/domain/entities/reminder_setting.dart
@freezed
class ReminderSetting with _$ReminderSetting {
  const factory ReminderSetting({
    required bool isEnabled,
    /// 알림 시간 (24h 형식, 0~23)
    @Default(9) int hour,
    @Default(0) int minute,
    /// 요일 비트마스크: 월=1, 화=2, 수=4, 목=8, 금=16, 토=32, 일=64
    /// 기본값: 127 (모든 요일)
    @Default(127) int weekdayMask,
  }) = _ReminderSetting;

  const ReminderSetting._();

  bool isEnabledOnWeekday(int weekday) {
    // DateTime.weekday: 월=1 ~ 일=7
    final bit = 1 << (weekday - 1);
    return weekdayMask & bit != 0;
  }

  List<int> get enabledWeekdays {
    return List.generate(7, (i) => i + 1)
        .where((d) => isEnabledOnWeekday(d))
        .toList();
  }
}
```

### 1-2. ReminderRepository 인터페이스

```dart
// lib/features/reminder/domain/repositories/reminder_repository.dart
abstract interface class ReminderRepository {
  /// 현재 설정 반환. 설정 없으면 기본값 반환.
  Future<ReminderSetting> getSetting();

  /// 알림 설정 저장 + 시스템 알림 등록/취소.
  Future<void> saveSetting(ReminderSetting setting);

  /// 알림 전체 취소.
  Future<void> cancelAll();
}
```

**UseCases**:

```dart
// lib/features/reminder/domain/usecases/set_reminder_usecase.dart
class SetReminderUseCase {
  const SetReminderUseCase(this._repository);
  final ReminderRepository _repository;

  Future<void> call(ReminderSetting setting) =>
      _repository.saveSetting(setting);
}

// lib/features/reminder/domain/usecases/cancel_reminder_usecase.dart
// [HIGH-7 FIX] ReminderRepository.saveSetting(isEnabled: false)가 이미 cancelAll을 포함
// → saveSetting 단일 호출로 충분 (cancelAll 중복 제거)
class CancelReminderUseCase {
  const CancelReminderUseCase(this._repository);
  final ReminderRepository _repository;

  Future<void> call() => _repository.saveSetting(const ReminderSetting(isEnabled: false));
}
// ReminderRepository.saveSetting() 계약: isEnabled=false 시 cancelAll() 내부 호출 보장

// lib/features/reminder/domain/usecases/get_reminder_setting_usecase.dart
class GetReminderSettingUseCase {
  const GetReminderSettingUseCase(this._repository);
  final ReminderRepository _repository;

  Future<ReminderSetting> call() => _repository.getSetting();
}
```

### 1-3. 알림 Deep Link 설계

<!-- [HIGH-2 FIX] 딥링크 allowlist 정책 — 민감 액션(삭제/구매/인증) 차단 -->
**딥링크 중앙 정책** (`lib/core/deeplink/deeplink_policy.dart`):
```dart
// 허용된 경로만 라우팅 — 나머지는 /tasks로 fallback
const _allowedRoutes = {'/tasks/start', '/tasks', '/badges', '/reminder-settings'};
// 민감 액션 denylist — 딥링크로 절대 진입 불가
const _deniedRoutes = {'/settings/delete-account', '/paywall', '/login'};

class DeeplinkPolicy {
  static String? resolve(Uri uri) {
    if (uri.scheme != 'com.ownurtime.app') return null;
    final path = '/${uri.host}';
    if (_deniedRoutes.contains(path)) return null;
    if (_allowedRoutes.contains(path)) return path;
    return '/tasks'; // 미등록 경로 → 안전 fallback
  }
}
```
`DeeplinkHandler`는 `DeeplinkPolicy.resolve(uri)` 반환값으로만 라우팅.

알림 탭 시 `com.ownurtime.app://start-session` 딥링크 처리:

```dart
// app_router.dart에 딥링크 처리 추가
// GoRouter initialLocation / redirect에서 처리 불필요
// app_links 패키지가 이미 설치됨 (Phase 1)

// lib/core/deeplink/deeplink_handler.dart
class DeeplinkHandler {
  static void handle(Uri uri, WidgetRef ref) {
    if (uri.scheme == 'com.ownurtime.app' && uri.host == 'start-session') {
      GoRouter.of(navigatorKey.currentContext!).go('/tasks/start');
    }
  }
}
```

알림 payload: `{"action": "start_session"}`

<!-- [FIX] 딥링크 연결 구체화 — payload 수신 → GoRouter 이동까지 명시 -->
**딥링크 연결 스펙** (Codex 구현 항목에 포함):
- `FlutterLocalNotificationsDataSource.initialize()` 내에 `onDidReceiveNotificationResponse` 콜백 등록
- payload == `{"action":"start_session"}` → `DeeplinkHandler.handle(Uri.parse('com.ownurtime.app://start-session'), ref)` 호출
- `DeeplinkHandler`는 설계 명세 1-3 그대로 사용 (`GoRouter.of(navigatorKey.currentContext!).go('/tasks/start')`)
- `navigatorKey`는 `main.dart`에서 `MaterialApp.router`에 등록 필요 (기존 키 재사용 또는 신규 생성)

### 1-4. LocalNotificationService 설계

```dart
// lib/features/reminder/data/datasources/local_notification_datasource.dart

abstract interface class LocalNotificationDataSource {
  Future<void> initialize();

  /// 요일별 반복 알림 등록. 기존 알림은 취소 후 재등록.
  Future<void> scheduleWeeklyReminder({
    required int hour,
    required int minute,
    required List<int> weekdays, // 1=월 ~ 7=일
    required String title,
    required String body,
    required String payload,
  });

  Future<void> cancelAll();
}
```

**flutter_local_notifications 구현**:

```
알림 ID 규칙: 요일별 ID (월=1, 화=2, ..., 일=7)
iOS: DarwinNotificationDetails(categoryIdentifier: 'reminder')
macOS: DarwinNotificationDetails 동일
반복: Day.values[weekday-1] (요일별 개별 등록)
```

### 1-5. ReminderNotifier 상태

```dart
@freezed
sealed class ReminderUiState with _$ReminderUiState {
  const factory ReminderUiState.loading() = _Loading;
  const factory ReminderUiState.loaded(ReminderSetting setting) = _Loaded;
  const factory ReminderUiState.error(String message) = _Error;
}
```

**동작**:
```
build() → getReminderSettingUseCase() → loaded(setting)
toggleEnabled(bool) →
  setting.copyWith(isEnabled: enabled) → setReminderUseCase → loaded
updateTime(int hour, int minute) →
  setting.copyWith(hour, minute) → setReminderUseCase → loaded
toggleWeekday(int weekday) →
  새 weekdayMask 계산 → setReminderUseCase → loaded
```

### 1-6. 온보딩 연동 포인트

`OnboardingNotifier.completeWithNotification(true)` 호출 시:

```dart
// lib/features/onboarding/presentation/providers/onboarding_provider.dart
Future<void> completeWithNotification(bool optIn) async {
  await completeOnboardingUseCase(notificationOptedIn: optIn);

  if (optIn) {
    // 알림 권한 요청
    final status = await Permission.notification.request();
    if (status.isGranted) {
      // 기본 설정으로 리마인더 등록 (09:00, 매일)
      await ref.read(setReminderUseCaseProvider).call(
        const ReminderSetting(isEnabled: true),
      );
    }
  }

  state = const OnboardingUiState.completed();
}
```

### 1-7. 에러 케이스

| 상황 | 처리 |
|------|------|
| 알림 권한 거부 | `isEnabled=false` 저장, 조용히 처리 |
| 알림 등록 실패 | error 상태 + "설정에서 다시 켜주세요" 안내 |
| macOS: 알림 권한 별도 요청 | `UNUserNotificationCenter` macOS도 동일 |
| 요일 0개 선택 | 알림 자동 비활성화 |

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task08-med-reminder.md`:

```
Project: OwnUrTime Flutter
Context: Phase 2 Task 08 — 약 복용 리마인더.
신규 피처: lib/features/reminder/ 생성.
<!-- [FIX] 의존성 추가 전 사용자 승인 필요 — 구현 시작 전 확인 -->
pubspec.yaml에 `flutter_local_notifications: ^17.x.x` + `timezone: ^0.9.x` 추가 (사용자 승인 후).

## 항목 1: 도메인 레이어
설계 명세 코드 그대로:
- lib/features/reminder/domain/entities/reminder_setting.dart
- lib/features/reminder/domain/repositories/reminder_repository.dart
- lib/features/reminder/domain/usecases/set_reminder_usecase.dart
- lib/features/reminder/domain/usecases/cancel_reminder_usecase.dart
- lib/features/reminder/domain/usecases/get_reminder_setting_usecase.dart

## 항목 2: LocalNotificationDataSource 구현
파일: lib/features/reminder/data/datasources/local_notification_datasource.dart

인터페이스 + FlutterLocalNotificationsDatasource 구현체:
```dart
class FlutterLocalNotificationsDataSource implements LocalNotificationDataSource {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // 온보딩에서 별도 요청
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      iOS: iosSettings,
      macOS: iosSettings,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // payload: '{"action":"start_session"}'
        // DeeplinkHandler.handlePayload(response.payload)
      },
    );
  }

  @override
  Future<void> scheduleWeeklyReminder({
    required int hour,
    required int minute,
    required List<int> weekdays,
    required String title,
    required String body,
    required String payload,
  }) async {
    await cancelAll();

    for (final weekday in weekdays) {
      final id = weekday; // ID = 요일 번호 (1~7)
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextWeekday(weekday, hour, minute),
        NotificationDetails(
          iOS: DarwinNotificationDetails(categoryIdentifier: 'reminder'),
          macOS: DarwinNotificationDetails(categoryIdentifier: 'reminder'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    final tz = tz.local;
    var scheduled = tz.TZDateTime.now(tz.local);
    scheduled = tz.TZDateTime(tz.local, scheduled.year, scheduled.month,
        scheduled.day, hour, minute);
    // 다음 해당 요일까지 날짜 이동
    while (scheduled.weekday != weekday || scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
```

timezone 패키지 추가 필요: timezone: ^0.9.x

## 항목 3: SharedPreferences 설정 저장 DataSource
파일: lib/features/reminder/data/datasources/reminder_local_datasource.dart
- SharedPreferences 키: 'reminder_hour', 'reminder_minute', 'reminder_weekday_mask', 'reminder_enabled'
- getSetting() → ReminderSetting (없으면 기본값)
- saveSetting(ReminderSetting) → 저장

## 항목 4: ReminderRepositoryImpl
파일: lib/features/reminder/data/repositories/reminder_repository_impl.dart
- getSetting(): localDataSource.getSetting()
- saveSetting(setting):
  1. localDataSource.saveSetting(setting)
  2. setting.isEnabled && setting.enabledWeekdays.isNotEmpty
     → notificationDataSource.scheduleWeeklyReminder(...)
     else → notificationDataSource.cancelAll()
- cancelAll(): notificationDataSource.cancelAll()

알림 내용:
- title: l10n.reminderNotificationTitle
- body: l10n.reminderNotificationBody
- payload: '{"action":"start_session"}'

## 항목 5: main.dart에 LocalNotificationDataSource 초기화
파일: lib/main.dart
앱 시작 시 FlutterLocalNotificationsDataSource().initialize() 호출

## 항목 6: ReminderNotifier
파일: lib/features/reminder/presentation/providers/reminder_provider.dart
설계 명세 동작 그대로 구현.

## 항목 7: ReminderSettingsScreen
파일: lib/features/reminder/presentation/screens/reminder_settings_screen.dart

레이아웃:
```
Scaffold(appBar: "알림 설정")
└── ListView
    ├── SwitchListTile("약 복용 알림", value: isEnabled, onChanged: toggleEnabled)
    ├── (isEnabled일 때) TimePickerTile("알림 시각", hour: 9, minute: 0)
    └── (isEnabled일 때) WeekdaySelector(weekdayMask: ..., onChanged: toggleWeekday)
```

## 항목 8: TimePickerTile 위젯
파일: lib/features/reminder/presentation/widgets/time_picker_tile.dart
- ListTile: "알림 시각" + "{hour}:{minute:02d}" 텍스트
- 탭 → showTimePicker() → notifier.updateTime(hour, minute)

## 항목 9: WeekdaySelector 위젯
파일: lib/features/reminder/presentation/widgets/weekday_selector.dart
- 7개 요일 버튼 (월화수목금토일)
- 선택된 요일: primary color
- 미선택: 회색
- 탭 → notifier.toggleWeekday(weekday)

## 항목 10: OnboardingNotifier 수정
파일: lib/features/onboarding/presentation/providers/onboarding_provider.dart
설계 명세 1-6 코드 적용 (completeWithNotification에서 기본 리마인더 등록)

## 항목 11: 설정 화면 → 리마인더 설정 연결
파일: lib/features/settings/presentation/screens/settings_screen.dart
기존 설정 화면에 "알림 설정" ListTile 추가 → /reminder-settings GoRoute

## 항목 12: GoRouter /reminder-settings 추가
파일: lib/core/router/app_router.dart

## 항목 13: pubspec.yaml 수정
추가:
- flutter_local_notifications: ^17.x.x
- timezone: ^0.9.x

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과
```

### 2-2. 구현 파일 목록

| 파일 | 담당 |
|------|------|
| `lib/features/reminder/domain/entities/reminder_setting.dart` | Codex |
| `lib/features/reminder/domain/repositories/reminder_repository.dart` | Codex |
| `lib/features/reminder/domain/usecases/*.dart` (3개) | Codex |
| `lib/features/reminder/data/datasources/local_notification_datasource.dart` | Codex |
| `lib/features/reminder/data/datasources/reminder_local_datasource.dart` | Codex |
| `lib/features/reminder/data/repositories/reminder_repository_impl.dart` | Codex |
| `lib/features/reminder/data/providers/reminder_providers.dart` | Codex |
| `lib/features/reminder/presentation/providers/reminder_provider.dart` | Codex |
| `lib/features/reminder/presentation/screens/reminder_settings_screen.dart` | Codex |
| `lib/features/reminder/presentation/widgets/time_picker_tile.dart` | Codex |
| `lib/features/reminder/presentation/widgets/weekday_selector.dart` | Codex |
| `lib/features/onboarding/presentation/providers/onboarding_provider.dart` | Codex (Task 02 파일 수정) |
| `lib/features/settings/presentation/screens/settings_screen.dart` | Codex |
| `lib/core/router/app_router.dart` | Codex (/reminder-settings 추가) |
| `lib/main.dart` | Codex (알림 초기화 추가) |
| `pubspec.yaml` | Codex |

---

## 3. 테스트 명세

### `test/features/reminder/domain/set_reminder_usecase_test.dart`

```
TC-01: 알림 활성화
  setup: FakeRepo.saveSetting completes normally
  기대: setReminderUseCase(ReminderSetting(isEnabled: true)) completes

TC-02: 알림 비활성화
  기대: setReminderUseCase(ReminderSetting(isEnabled: false)) completes
```

### `test/features/reminder/domain/reminder_setting_test.dart`

```
TC-03: isEnabledOnWeekday — 모든 요일 (mask=127)
  기대: 1~7 모두 true

TC-04: isEnabledOnWeekday — 평일만 (mask=31: 월1+화2+수4+목8+금16)
  기대: 1,2,3,4,5 → true, 6,7 → false

TC-05: enabledWeekdays — mask=65 (월=1, 일=64)
  기대: [1, 7]
```

### `test/features/reminder/data/reminder_repository_impl_test.dart`

```
TC-06: saveSetting(isEnabled: true) → scheduleWeeklyReminder 호출됨
  기대: FakeNotificationDataSource.scheduleWeeklyReminder 호출됨

TC-07: saveSetting(isEnabled: false) → cancelAll 호출됨
  기대: FakeNotificationDataSource.cancelAll 호출됨

TC-08: saveSetting(isEnabled: true, weekdays: []) → cancelAll 호출됨 (요일 없음)
  기대: scheduleWeeklyReminder 미호출, cancelAll 호출됨
```

### `test/features/reminder/presentation/reminder_notifier_test.dart`

```
TC-09: build → loaded(default setting)
  setup: FakeRepo.getSetting() → ReminderSetting(isEnabled: false)
  기대: ReminderUiState.loaded(ReminderSetting(isEnabled: false))

TC-10: toggleEnabled(true) → saveSetting 호출됨
  기대: FakeRepo.saveSetting(ReminderSetting(isEnabled: true)) 호출됨

TC-11: toggleWeekday(6) — 토요일 토글
  초기: weekdayMask=127 (모든 요일)
  toggleWeekday(6) →
  기대: 새 mask = 127 - 32 = 95 (토요일 비트 제거)
```

---

## 4. l10n 추가 (Codex)

`app_ko.arb`:
```json
"reminderSettingsTitle": "알림 설정",
"reminderToggleLabel": "약 복용 알림",
"reminderTimeLabel": "알림 시각",
"reminderTimeValue": "{hour}:{minute}",
"@reminderTimeValue": {"placeholders": {"hour": {"type": "int"}, "minute": {"type": "String"}}},
"reminderWeekdayLabel": "반복 요일",
"reminderWeekdayMon": "월",
"reminderWeekdayTue": "화",
"reminderWeekdayWed": "수",
"reminderWeekdayThu": "목",
"reminderWeekdayFri": "금",
"reminderWeekdaySat": "토",
"reminderWeekdaySun": "일",
"reminderNotificationTitle": "OwnUrTime",
"reminderNotificationBody": "약 먹는 시간이에요. 오늘도 작은 시작을 해볼까요?",
"settingsReminderSettings": "알림 설정"
```

`app_en.arb`:
```json
"reminderSettingsTitle": "Reminder Settings",
"reminderToggleLabel": "Medication Reminder",
"reminderTimeLabel": "Reminder Time",
"reminderTimeValue": "{hour}:{minute}",
"@reminderTimeValue": {"placeholders": {"hour": {"type": "int"}, "minute": {"type": "String"}}},
"reminderWeekdayLabel": "Repeat Days",
"reminderWeekdayMon": "Mon",
"reminderWeekdayTue": "Tue",
"reminderWeekdayWed": "Wed",
"reminderWeekdayThu": "Thu",
"reminderWeekdayFri": "Fri",
"reminderWeekdaySat": "Sat",
"reminderWeekdaySun": "Sun",
"reminderNotificationTitle": "OwnUrTime",
"reminderNotificationBody": "Time for your medication. Ready for a small start today?",
"settingsReminderSettings": "Reminder Settings"
```

---

## 5. Done When

- [ ] 실기기: 지정 시간에 알림 수신됨
- [ ] 알림 탭 → TaskStartScreen 직접 진입
- [ ] 요일 선택 변경 → 해당 요일에만 알림 수신
- [ ] 알림 끄기 → 이후 알림 없음
- [ ] 온보딩 "켜기" → 기본 알림(09:00 매일) 자동 등록
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` TC-01~TC-11 전체 통과
