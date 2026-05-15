# Analytics: PostHog Setup + KPI Events — Phase 1

> Agent: Codex (implementation) | Claude Code (event taxonomy)
> PRD ref: Section 12 (KPIs)
> Analytics calls in repository/datasource layer only — not in UI widgets.

## Setup

- [x] posthog_flutter already in pubspec.yaml (added in task 00)
- [x] Initialize in main.dart — `analyticsServiceProvider.init(apiKey)` via EU endpoint
- [x] lib/core/analytics/analytics_service.dart — thin wrapper around PostHog
  - Single class; all event calls go through here
  - No direct PostHog references outside this file

## 5 KPI Events (wire in repository/use case layer)

### 1. initiation_conversion

```dart
// Fired when: user taps 2-min start button
analyticsService.track('initiation_conversion', properties: {
  'has_task_title': task.title.isNotEmpty,
  'has_decomposed_steps': task.decomposedSteps != null,
  'session_of_day': sessionOfDayCount,
});
```

- Wire in: CreateTaskUseCase or StartSessionUseCase

### 2. session_completed

```dart
// Fired when: session timer reaches 0 (not abandoned)
analyticsService.track('session_completed', properties: {
  'duration_minutes': session.targetDurationMinutes,
  'distraction_count': session.distractionCount,
  'reset_count': session.resetCount,
  'mood_level': moodLevel, // from today's mood check
});
```

- Wire in: CompleteSessionUseCase

### 3. session_distracted

```dart
// Fired when: user taps "Distracted" button
analyticsService.track('session_distracted', properties: {
  'distraction_type': distractionType.name, // urgent/impulsive/rest
  'minutes_into_session': elapsedMinutes,
  'session_target_minutes': session.targetDurationMinutes,
});
```

- Wire in: LogDistractionUseCase

### 4. recovery_returned

```dart
// Fired when: user taps "Resume" on context restore card
analyticsService.track('recovery_returned', properties: {
  'distraction_type': distraction.type.name,
  'recovery_seconds': secondsBetweenDistractionAndReturn,
});
```

- Wire in: RecoverSessionUseCase (when markReturned() called)

### 5. day_2_return

```dart
// Fired when: app opened on day after first session
analyticsService.track('day_2_return', properties: {
  'days_since_first_session': daysSinceFirstSession,
  'total_sessions_completed': totalSessionsCompleted,
});
```

- Wire in: app lifecycle (on resume, check if day-2 condition met)
- Store first_session_date in flutter_secure_storage

## Implementation Steps

- [x] lib/core/analytics/analytics_service.dart
- [x] Wire event 1 (initiation_conversion) — TimerNotifier.start()
- [x] Wire event 2 (session_completed) — TimerNotifier._complete()
- [x] Wire event 3 (session_distracted) — TimerNotifier.declareDistraction()
- [x] Wire event 4 (recovery_returned) — TimerNotifier.resumeFromDistraction()
- [x] Wire event 5 (day_2_return) — day2ReturnCheckProvider (app startup)

## Tests (Codex)

- [x] test/core/analytics/analytics_service_test.dart (5 tests — FakeAnalyticsService 패턴)
- [ ] Add analytics assertions to existing usecase tests (Phase 2 스코프로 이동)

## Verify

- [x] flutter analyze — zero warnings
- [x] flutter test — 61 passed
- [x] flutter-reviewer — HIGH 이슈 수정 완료, 재검토 진행 중
- [ ] Run app in dev → complete a session → PostHog dashboard shows session_completed event
- [ ] All 5 events visible in PostHog dev project within 30s of action
