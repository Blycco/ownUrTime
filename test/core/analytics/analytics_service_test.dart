import 'package:flutter_test/flutter_test.dart';
import 'package:ownurtime/core/analytics/analytics_service.dart';

class FakeAnalyticsService implements AnalyticsService {
  final List<({String event, Map<String, Object?> properties})> calls = [];
  final List<String> identifyCalls = [];
  bool recordedFirstSessionDate = false;
  bool shouldThrow = false;

  @override
  Future<void> init(String apiKey) async {}

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
    identifyCalls.add(userId);
  }

  @override
  Future<void> recordFirstSessionDate() async {
    if (shouldThrow) throw Exception('PostHog unavailable');
    recordedFirstSessionDate = true;
  }
}

class AlwaysThrowsAnalyticsService implements AnalyticsService {
  @override
  Future<void> init(String apiKey) async {
    throw Exception('PostHog unavailable');
  }

  @override
  Future<void> track(
    String event, {
    Map<String, Object?> properties = const {},
  }) async {
    throw Exception('PostHog unavailable');
  }

  @override
  Future<void> identify(String userId) async {
    throw Exception('PostHog unavailable');
  }

  @override
  Future<void> recordFirstSessionDate() async {
    throw Exception('PostHog unavailable');
  }
}

Future<void> safelyTrack(
  AnalyticsService service,
  String event, {
  Map<String, Object?> properties = const {},
}) async {
  try {
    await service.track(event, properties: properties);
  } on Exception catch (_) {
    // non-critical — analytics failure silently ignored
  }
}

void main() {
  group('AnalyticsService', () {
    test('track silently skips when PostHog throws', () async {
      final service = AlwaysThrowsAnalyticsService();

      await expectLater(safelyTrack(service, 'session_started'), completes);
    });

    test('FakeAnalyticsService records track calls', () async {
      final service = FakeAnalyticsService();

      await service.track('task_started');

      expect(service.calls.length, 1);
    });

    test(
      'FakeAnalyticsService records correct event name and properties',
      () async {
        final service = FakeAnalyticsService();
        const properties = {'source': 'home', 'duration': 120};

        await service.track('timer_completed', properties: properties);

        expect(service.calls.single.event, 'timer_completed');
        expect(service.calls.single.properties, properties);
      },
    );

    test('identify records userId correctly', () async {
      final service = FakeAnalyticsService();

      await service.identify('user-123');

      expect(service.identifyCalls.single, 'user-123');
    });

    test('recordFirstSessionDate marks date as recorded', () async {
      final service = FakeAnalyticsService();

      await service.recordFirstSessionDate();

      expect(service.recordedFirstSessionDate, isTrue);
    });
  });
}
