# Task 09: Analytics Service — Codex Implementation Prompt

## Context

OwnUrTime Flutter app (Dart, Riverpod 3.x, Clean Architecture).
Branch: `feat/analytics`
Issue: #18

PostHog 분석 서비스 wrapper와 provider, 그리고 테스트를 구현한다.

## Packages

- `posthog_flutter: ^5.24.2` — 이미 pubspec.yaml에 있음
- `riverpod_annotation: ^4.0.2` + `riverpod_generator` (기존)

## posthog_flutter 5.x API

```dart
import 'package:posthog_flutter/posthog_flutter.dart';

// 이벤트 캡처
await PostHog().capture(
  eventName: 'event_name',
  properties: {'key': 'value'},
);

// 유저 식별
await PostHog().identify(userId: 'user_id');
```

## Architecture Rules

- `package:` import only (no relative imports)
- No `dynamic` types — use `Map<String, Object?>` for properties
- No `!` bang operator
- `@riverpod` annotation + code generation
- catch `_` (not just Exception) to avoid uncaught Error subtypes

## Files to Create

### 1. `lib/core/analytics/analytics_service.dart`

```dart
import 'package:posthog_flutter/posthog_flutter.dart';

abstract interface class AnalyticsService {
  Future<void> track(
    String event, {
    Map<String, Object?> properties = const {},
  });

  Future<void> identify(String userId);
}

class PostHogAnalyticsService implements AnalyticsService {
  @override
  Future<void> track(
    String event, {
    Map<String, Object?> properties = const {},
  }) async {
    try {
      await PostHog().capture(eventName: event, properties: properties);
    } catch (_) {
      // non-critical — analytics failure silently ignored
    }
  }

  @override
  Future<void> identify(String userId) async {
    try {
      await PostHog().identify(userId: userId);
    } catch (_) {}
  }
}
```

### 2. `lib/core/analytics/analytics_providers.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ownurtime/core/analytics/analytics_service.dart';

part 'analytics_providers.g.dart';

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) => PostHogAnalyticsService();
```

After creating, run:
```bash
dart run build_runner build
```

### 3. `test/core/analytics/analytics_service_test.dart`

테스트에서 실제 PostHog 호출 없이 FakeAnalyticsService 사용:

```dart
class FakeAnalyticsService implements AnalyticsService {
  final List<({String event, Map<String, Object?> properties})> calls = [];
  bool shouldThrow = false;

  @override
  Future<void> track(
    String event, {
    Map<String, Object?> properties = const {},
  }) async {
    if (shouldThrow) throw Exception('PostHog unavailable');
    calls.add((event: event, properties: properties));
  }

  @override
  Future<void> identify(String userId) async {
    if (shouldThrow) throw Exception('PostHog unavailable');
  }
}
```

Tests:
- `'track silently skips when PostHog throws'`: PostHogAnalyticsService에 override된 PostHog가 throw해도 예외 전파 없음 (catch 블록 테스트) — _AlwaysThrowsAnalyticsService 사용
- `'FakeAnalyticsService records track calls'`: track() 호출 시 calls 리스트에 이벤트 기록됨
- `'FakeAnalyticsService records correct event name and properties'`: event name과 properties가 정확히 기록됨
- `'identify records userId correctly'`: identify() 호출 시 올바른 userId 전달됨

## Do NOT

- `main.dart` 수정 금지 (Claude Code가 처리)
- `timer_provider.dart` 수정 금지 (Claude Code가 처리)
- 상대 경로 import 사용 금지
- PostHog API key 하드코딩 금지

## Run After

```bash
dart run build_runner build
flutter analyze lib/core/analytics/
flutter test test/core/analytics/
```
