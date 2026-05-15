import 'package:ownurtime/core/analytics/analytics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_providers.g.dart';

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) => PostHogAnalyticsService();
