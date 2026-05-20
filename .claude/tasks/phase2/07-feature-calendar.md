# Task 07: Apple Calendar 연동 — Phase 2

> **선제 조건**: Task 01 완료
> **Claude Code 담당**: Platform channel 인터페이스 설계, CalendarEvent 엔티티, 권한 처리 흐름 설계
> **Codex 담당**: 모든 코드 작성 (Swift bridge, Flutter datasource, Repository, 배너 위젯, 테스트 전부)
> **PRD ref**: Phase 2 기능 목록, adhd-domain.md
> **플랫폼**: iOS + macOS (EventKit). Android는 Phase 4+.
> **권한 원칙**: 사용 시점 opt-in, 거부 시 조용히 처리 (앱 정상 동작)

---

## 1. 설계 명세 (Claude Code)

### 1-1. CalendarEvent 엔티티

```dart
// lib/features/calendar/domain/entities/calendar_event.dart
@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required bool isAllDay,
    String? location,
    String? notes,
  }) = _CalendarEvent;

  /// 세션 길이 제안용 — 이벤트 남은 시간 (분)
  int get remainingMinutes {
    final now = DateTime.now();
    if (endTime.isBefore(now)) return 0;
    final remaining = endTime.difference(now).inMinutes;
    return remaining.clamp(0, 120); // 최대 120분
  }
}
```

### 1-2. CalendarRepository 인터페이스

```dart
// lib/features/calendar/domain/repositories/calendar_repository.dart
abstract interface class CalendarRepository {
  /// 오늘 남은 이벤트 목록 (현재 시각 이후 이벤트만).
  Future<List<CalendarEvent>> getTodayUpcomingEvents();

  /// 캘린더 접근 권한 상태 확인.
  Future<CalendarPermissionStatus> getPermissionStatus();

  /// 권한 요청. 이미 결정된 경우 현재 상태 반환.
  Future<CalendarPermissionStatus> requestPermission();
}

enum CalendarPermissionStatus {
  notDetermined, // 아직 요청 안 함
  authorized,    // 허용됨
  denied,        // 거부됨
  restricted,    // 제한됨 (parental control 등)
}
```

**UseCase**:

```dart
// lib/features/calendar/domain/usecases/get_today_events_usecase.dart
class GetTodayEventsUseCase {
  const GetTodayEventsUseCase(this._repository);
  final CalendarRepository _repository;

  /// 권한 없으면 빈 리스트 반환 (에러 없이).
  Future<List<CalendarEvent>> call() async {
    final status = await _repository.getPermissionStatus();
    if (status != CalendarPermissionStatus.authorized) return [];
    return _repository.getTodayUpcomingEvents();
  }
}

// lib/features/calendar/domain/usecases/request_calendar_permission_usecase.dart
class RequestCalendarPermissionUseCase {
  const RequestCalendarPermissionUseCase(this._repository);
  final CalendarRepository _repository;

  Future<CalendarPermissionStatus> call() =>
      _repository.requestPermission();
}
```

### 1-3. Platform Channel 인터페이스 설계

**채널명**: `com.ownurtime.app/calendar`

**Flutter → Native 메서드**:

| 메서드 | 설명 | 반환 |
|--------|------|------|
| `getPermissionStatus` | 권한 상태 확인 | String: `'authorized'|'denied'|'notDetermined'|'restricted'` |
| `requestPermission` | 권한 요청 | String: 위와 동일 |
| `getTodayEvents` | 오늘 이벤트 목록 | List<Map>: 이벤트 JSON 배열 |

**이벤트 JSON 구조**:
```json
{
  "id": "abc123",
  "title": "팀 미팅",
  "startTime": "2026-05-18T10:00:00+09:00",
  "endTime": "2026-05-18T11:00:00+09:00",
  "isAllDay": false,
  "location": "회의실 A",
  "notes": null
}
```

### 1-4. Swift 구현 설계 (`ios/Runner/CalendarPlugin.swift`)

```swift
import Flutter
import EventKit

class CalendarPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.ownurtime.app/calendar",
      binaryMessenger: registrar.messenger()
    )
    let instance = CalendarPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private let store = EKEventStore()

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPermissionStatus":
      result(authorizationStatusString())
    case "requestPermission":
      store.requestAccess(to: .event) { [weak self] granted, _ in
        DispatchQueue.main.async {
          result(self?.authorizationStatusString() ?? "denied")
        }
      }
    case "getTodayEvents":
      result(todayEvents())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func authorizationStatusString() -> String {
    switch EKEventStore.authorizationStatus(for: .event) {
    case .authorized: return "authorized"
    case .denied: return "denied"
    case .restricted: return "restricted"
    default: return "notDetermined"
    }
  }

  private func todayEvents() -> [[String: Any?]] {
    let calendar = Calendar.current
    let start = calendar.startOfDay(for: Date())
    let end = calendar.date(byAdding: .day, value: 1, to: start)!
    let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
    let events = store.events(matching: predicate)
    return events
      // [FIX] Repository 계약은 "현재 시각 이후" — 시작 시각 기준으로 필터 (1시간 관대 제거)
    .filter { $0.startDate.timeIntervalSinceNow > 0 } // 현재 시각 이후 시작 이벤트만
      .map { event in
        [
          "id": event.eventIdentifier,
          "title": event.title ?? "(제목 없음)",
          "startTime": ISO8601DateFormatter().string(from: event.startDate),
          "endTime": ISO8601DateFormatter().string(from: event.endDate),
          "isAllDay": event.isAllDay,
          "location": event.location,
          "notes": event.notes,
        ]
      }
  }
}
```

**AppDelegate.swift에 플러그인 등록** (기존 파일 수정):
```swift
GeneratedPluginRegistrant.register(with: self)
CalendarPlugin.register(with: registrar(forPlugin: "CalendarPlugin"))
```

### 1-5. CalendarNotifier 상태

```dart
@freezed
sealed class CalendarUiState with _$CalendarUiState {
  const factory CalendarUiState.initial() = _Initial;
  const factory CalendarUiState.noPermission() = _NoPermission;
  const factory CalendarUiState.noEvents() = _NoEvents;
  const factory CalendarUiState.hasEvents(List<CalendarEvent> events) = _HasEvents;
  const factory CalendarUiState.error(String message) = _Error;
}
```

**동작**:
```
build() →
  getPermissionStatus() == authorized → getTodayUpcomingEvents()
    → empty → noEvents()
    → has events → hasEvents(events)
  != authorized → noPermission()

requestPermission() →
  requestPermission() == authorized → getTodayUpcomingEvents() → 상태 업데이트
  != authorized → noPermission() (앱 계속 동작)
```

### 1-6. TodayEventsBanner 위젯 표시 조건

- `CalendarUiState.hasEvents` 일 때만 TaskListScreen 상단에 표시
- `noPermission` / `noEvents` / `error`: 배너 미표시 (TaskListScreen 정상 동작)

### 1-7. 에러 케이스

| 상황 | 처리 |
|------|------|
| 권한 거부 | 배너 미표시, 앱 정상 동작 |
| EventKit 예외 | error 상태 → 배너 미표시 (로그만) |
| 이벤트 없음 | noEvents → 배너 미표시 |
| macOS: 다른 권한 API | macOS도 EKEventStore 사용 (동일 Swift 코드) |
| Simulator: 캘린더 없음 | empty list 반환 |

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task07-calendar.md`:

```
Project: OwnUrTime Flutter
Context: Phase 2 Task 07 — Apple Calendar 연동.
신규 피처: lib/features/calendar/ 생성.

## 주의사항
- iOS/macOS 플랫폼 전용 (Android는 빈 구현)
- 권한 거부 시 앱 정상 동작 — 에러 없이 noPermission 상태만

## 항목 1: Swift 파일 생성
파일 1: ios/Runner/CalendarPlugin.swift (설계 명세 코드 그대로)
파일 2: ios/Runner/AppDelegate.swift 수정 — CalendarPlugin 등록 추가

macOS:
파일 3: macos/Runner/CalendarPlugin.swift (iOS와 동일 코드)
파일 4: macos/Runner/AppDelegate.swift 수정

Info.plist 권한 추가:
ios/Runner/Info.plist:
```xml
<key>NSCalendarsUsageDescription</key>
<string>오늘 일정을 확인해 집중 시간을 계획해요.</string>
```
macos/Runner/Info.plist 동일 추가.

## 항목 2: 도메인 레이어
설계 명세 코드 그대로:
- lib/features/calendar/domain/entities/calendar_event.dart
- lib/features/calendar/domain/repositories/calendar_repository.dart
- lib/features/calendar/domain/usecases/get_today_events_usecase.dart
- lib/features/calendar/domain/usecases/request_calendar_permission_usecase.dart

## 항목 3: EventKitCalendarDataSource (Flutter MethodChannel)
파일: lib/features/calendar/data/datasources/eventkit_calendar_datasource.dart
```dart
class EventKitCalendarDataSource {
  static const _channel = MethodChannel('com.ownurtime.app/calendar');

  Future<CalendarPermissionStatus> getPermissionStatus() async {
    final result = await _channel.invokeMethod<String>('getPermissionStatus');
    return _parseStatus(result ?? 'denied');
  }

  Future<CalendarPermissionStatus> requestPermission() async {
    final result = await _channel.invokeMethod<String>('requestPermission');
    return _parseStatus(result ?? 'denied');
  }

  Future<List<Map<String, dynamic>>> getTodayEvents() async {
    final result = await _channel.invokeListMethod<Map>('getTodayEvents');
    return (result ?? []).cast<Map<String, dynamic>>();
  }

  CalendarPermissionStatus _parseStatus(String status) => switch (status) {
    'authorized' => CalendarPermissionStatus.authorized,
    'denied' => CalendarPermissionStatus.denied,
    'restricted' => CalendarPermissionStatus.restricted,
    _ => CalendarPermissionStatus.notDetermined,
  };
}
```

## 항목 4: CalendarRepositoryImpl
파일: lib/features/calendar/data/repositories/calendar_repository_impl.dart
- 각 메서드: datasource 위임 + CalendarEvent entity 매핑
- isAllDay, location, notes null 처리

## 항목 5: CalendarNotifier
파일: lib/features/calendar/presentation/providers/calendar_provider.dart
설계 명세 동작 그대로:
- build() → 권한 확인 → 이벤트 조회
- requestPermission() 메서드

## 항목 6: TodayEventsBanner 위젯
파일: lib/features/calendar/presentation/widgets/today_events_banner.dart

레이아웃:
```
CalendarUiState.hasEvents(events) 일 때만 표시:
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  decoration: BoxDecoration(color: AppTheme.surfaceColor),
  child: Row(
    ├── Icon(calendar_today, size: 16)
    ├── SizedBox(width: 8)
    ├── Expanded(
    │     child: Text(
    │       events.length == 1
    │         ? events.first.title
    │         : "${events.length}개의 일정이 있어요"
    │     )
    │   )
    └── TextButton("시작하기", onPressed: onStartSession)
  )
)
```

탭("시작하기"):
- events.first.remainingMinutes를 TaskStartScreen에 suggestedMinutes로 전달
- GoRouter.push('/tasks/start', extra: {'suggestedMinutes': events.first.remainingMinutes})

<!-- [FIX] UX 일관성: noPermission 시 배너 미표시 + 설정 화면으로 연결하는 버튼만 표시 -->
<!-- 앱 내에서 permission 재요청은 iOS/macOS 정책상 첫 요청 후 시스템 대화상자만 뜸 -->
noPermission 상태: 배너 미표시 + "일정 연동하기" 텍스트버튼 표시 (작은 크기)
"일정 연동하기" 탭 → requestPermission() → 거부됐으면 openAppSettings() 호출 (앱 설정 이동)

## 항목 7: TaskListScreen에 TodayEventsBanner 통합
파일: lib/features/task/presentation/screens/task_list_screen.dart
<!-- [PRD FIX] Calendar 연동은 Paid 기능 (business.md) — PremiumGateWidget으로 래핑 -->
기존 AppBar 아래에 TodayEventsBanner 추가 (Column 최상단), PremiumGateWidget으로 래핑:
```dart
PremiumGateWidget(
  feature: 'calendarIntegration',
  lockedChild: _CalendarProCta(), // "Pro에서 캘린더 연동" 소형 텍스트버튼 → /paywall
  child: TodayEventsBanner(...),
)
```
isPremium=false: 배너 미표시, 작은 CTA만 표시 (강요 금지 — 1줄 이하로 최소화)
<!-- [HIGH-8 FIX] 착수 순간에 Pro 게이팅 = 차단감 → 즉시 대안 제공 필수 -->
<!-- CTA 하단에 small 텍스트로 폴백 행동 표시: "지금은 일정 없이 바로 2분 시작" → /tasks/start -->
_CalendarProCta 위젯 구성:
- 1줄: "Pro에서 캘린더 연동하기" 텍스트버튼 → /paywall
- 바로 아래: "바로 2분 시작하기" 텍스트 (소형, secondary 색상) → /tasks/start
- 두 버튼 모두 1탭 진입 (ADHD UX: 착수 장벽 최소화)

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과 (MethodChannel mock 사용)
```

### 2-2. 구현 파일 목록

| 파일 | 담당 |
|------|------|
| `ios/Runner/CalendarPlugin.swift` | Codex |
| `ios/Runner/AppDelegate.swift` | Codex (플러그인 등록) |
| `ios/Runner/Info.plist` | Codex (NSCalendarsUsageDescription 추가) |
| `macos/Runner/CalendarPlugin.swift` | Codex |
| `macos/Runner/AppDelegate.swift` | Codex |
| `macos/Runner/Info.plist` | Codex |
| `lib/features/calendar/domain/entities/calendar_event.dart` | Codex |
| `lib/features/calendar/domain/repositories/calendar_repository.dart` | Codex |
| `lib/features/calendar/domain/usecases/get_today_events_usecase.dart` | Codex |
| `lib/features/calendar/domain/usecases/request_calendar_permission_usecase.dart` | Codex |
| `lib/features/calendar/data/datasources/eventkit_calendar_datasource.dart` | Codex |
| `lib/features/calendar/data/repositories/calendar_repository_impl.dart` | Codex |
| `lib/features/calendar/data/providers/calendar_providers.dart` | Codex |
| `lib/features/calendar/presentation/providers/calendar_provider.dart` | Codex |
| `lib/features/calendar/presentation/widgets/today_events_banner.dart` | Codex |
| `lib/features/task/presentation/screens/task_list_screen.dart` | Codex (배너 추가) |

---

## 3. 테스트 명세

### `test/features/calendar/domain/get_today_events_usecase_test.dart`

```
TC-01: 권한 authorized → getTodayUpcomingEvents 호출됨
  setup: FakeCalendarRepo.getPermissionStatus() → authorized
         FakeCalendarRepo.getTodayUpcomingEvents() → [event1]
  기대: usecase() → [event1]

TC-02: 권한 denied → 빈 리스트 반환 (에러 없음)
  setup: getPermissionStatus() → denied
  기대: usecase() → []
  기대: getTodayUpcomingEvents() 미호출

TC-03: 권한 notDetermined → 빈 리스트 반환
  기대: usecase() → []
```

### `test/features/calendar/presentation/calendar_notifier_test.dart`

```
TC-04: build — 권한 authorized + 이벤트 있음 → hasEvents
  기대: CalendarUiState.hasEvents([event1])

TC-05: build — 권한 denied → noPermission
  기대: CalendarUiState.noPermission()

TC-06: build — 권한 authorized + 이벤트 없음 → noEvents
  기대: CalendarUiState.noEvents()

TC-07: requestPermission — 승인 → hasEvents로 전환
  초기: noPermission
  requestPermission() 호출, FakeRepo → authorized + [event1]
  기대: CalendarUiState.hasEvents([event1])

TC-08: requestPermission — 거부 → noPermission 유지
  기대: CalendarUiState.noPermission()
```

### `test/features/calendar/data/eventkit_calendar_datasource_test.dart`

```
TC-09: MethodChannel mock — getTodayEvents 성공
  setup: TestDefaultBinaryMessengerBinding mock → [{id: 'e1', ...}]
  기대: List<Map> 길이 1
```

---

## 4. l10n 추가 (Codex)

`app_ko.arb`:
```json
"calendarBannerSingleEvent": "{title}",
"@calendarBannerSingleEvent": {"placeholders": {"title": {"type": "String"}}},
"calendarBannerMultipleEvents": "{count}개의 일정이 있어요",
"@calendarBannerMultipleEvents": {"placeholders": {"count": {"type": "int"}}},
"calendarBannerStartButton": "시작하기",
"calendarConnectButton": "일정 연동하기",
"calendarPermissionTitle": "캘린더 접근 권한",
"calendarPermissionBody": "오늘 일정을 확인해 집중 시간을 계획할 수 있어요."
```

`app_en.arb`:
```json
"calendarBannerSingleEvent": "{title}",
"@calendarBannerSingleEvent": {"placeholders": {"title": {"type": "String"}}},
"calendarBannerMultipleEvents": "{count} events today",
"@calendarBannerMultipleEvents": {"placeholders": {"count": {"type": "int"}}},
"calendarBannerStartButton": "Start",
"calendarConnectButton": "Connect Calendar",
"calendarPermissionTitle": "Calendar Access",
"calendarPermissionBody": "See today's events to plan your focus time."
```

---

## 5. Done When

- [ ] 실기기: Calendar 권한 요청 다이얼로그 표시됨
- [ ] 권한 허용 후: 오늘 이벤트 배너 표시됨 (이벤트 있을 때만)
- [ ] 권한 거부: 배너 미표시, 앱 정상 동작
- [ ] 배너 "시작하기" → TaskStartScreen에 suggestedMinutes 전달됨
- [ ] Simulator: 빈 이벤트 → noEvents 상태 (에러 없음)
- [ ] isPremium=false → 배너 미표시, 소형 CTA만 표시됨 (강요 없음)
- [ ] isPremium=true → 배너 정상 표시됨
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` TC-01~TC-09 전체 통과
