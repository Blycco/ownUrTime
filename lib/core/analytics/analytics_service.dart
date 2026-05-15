import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

const String kFirstSessionDateStorageKey = 'ownurtime_first_session_date';

abstract interface class AnalyticsService {
  Future<void> init(String apiKey);

  Future<void> track(
    String event, {
    Map<String, Object?> properties = const {},
  });

  Future<void> identify(String userId);

  Future<void> recordFirstSessionDate();
}

class PostHogAnalyticsService implements AnalyticsService {
  @override
  Future<void> init(String apiKey) async {
    if (apiKey.isEmpty) return;
    try {
      final config = PostHogConfig(apiKey)
        ..host = 'https://eu.posthog.com'
        ..debug = !const bool.fromEnvironment('dart.vm.product');
      await Posthog().setup(config);
    } on Exception catch (_) {}
  }

  @override
  Future<void> track(
    String event, {
    Map<String, Object?> properties = const {},
  }) async {
    try {
      final nonNullProps = <String, Object>{
        for (final e in properties.entries)
          if (e.value case final Object v) e.key: v,
      };
      await Posthog().capture(
        eventName: event,
        properties: nonNullProps.isEmpty ? null : nonNullProps,
      );
    } on Exception catch (_) {
      // non-critical — analytics failure silently ignored
    }
  }

  @override
  Future<void> identify(String userId) async {
    try {
      await Posthog().identify(userId: userId);
    } on Exception catch (_) {}
  }

  @override
  Future<void> recordFirstSessionDate() async {
    try {
      const storage = FlutterSecureStorage();
      final existing = await storage.read(key: kFirstSessionDateStorageKey);
      if (existing == null) {
        await storage.write(
          key: kFirstSessionDateStorageKey,
          value: DateTime.now().toIso8601String(),
        );
      }
    } on Exception catch (_) {}
  }
}
