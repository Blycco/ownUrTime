# Analytics: PostHog Setup + KPI Events — Phase 1
> Agent: Codex (implementation) | Claude Code (event taxonomy)
> PRD ref: Section 12 (KPIs)
> Analytics calls in repository/datasource layer only — not in UI widgets.

## Setup
- [ ] posthog_flutter already in pubspec.yaml (added in task 00)
- [ ] Initialize in main.dart:
  ```dart
  await Posthog().setup(
    'https://app.posthog.com',
    const PosthogConfig(apiKey: String.fromEnvironment('POSTHOG_API_KEY')),
  );
  ```
- [ ] lib/core/analytics/analytics_service.dart — thin wrapper around PostHog
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

## Implementation Steps (Codex)
- [ ] lib/core/analytics/analytics_service.dart
- [ ] Wire event 1 (initiation_conversion) in StartSessionUseCase
- [ ] Wire event 2 (session_completed) in CompleteSessionUseCase
- [ ] Wire event 3 (session_distracted) in LogDistractionUseCase
- [ ] Wire event 4 (recovery_returned) in RecoverSessionUseCase
- [ ] Wire event 5 (day_2_return) in app lifecycle observer

## Tests (Codex)
- [ ] test/core/analytics/analytics_service_test.dart
  - Test: track() calls PostHog with correct event name and properties
  - Use MockPosthog
- [ ] Add analytics assertions to existing usecase tests:
  - Test: CompleteSessionUseCase fires session_completed event
  - Test: LogDistractionUseCase fires session_distracted event

## Verify
- [ ] flutter analyze — zero warnings in core/analytics/
- [ ] Run app in dev → complete a session → PostHog dashboard shows session_completed event
- [ ] All 5 events visible in PostHog dev project within 30s of action
- [ ] No analytics calls in any presentation/ widget files
