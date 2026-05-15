import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ownurtime/core/analytics/analytics_providers.dart';
import 'package:ownurtime/core/analytics/analytics_service.dart';

part 'day2_return_provider.g.dart';

const String _kDay2FiredKey = 'ownurtime_day2_return_fired';

@Riverpod(keepAlive: true)
Future<void> day2ReturnCheck(Ref ref) async {
  const storage = FlutterSecureStorage();

  final firstDateStr = await storage.read(key: kFirstSessionDateStorageKey);
  if (firstDateStr == null) return;

  final alreadyFired = await storage.read(key: _kDay2FiredKey);
  if (alreadyFired == 'true') return;

  final firstDate = DateTime.tryParse(firstDateStr);
  if (firstDate == null) return;

  final daysSince = DateTime.now().difference(firstDate).inDays;
  // inDays truncates fractional days — fires on day 2+ (>= 24 hours elapsed)
  if (daysSince < 1) return;

  await ref
      .read(analyticsServiceProvider)
      .track(
        'day_2_return',
        properties: {'days_since_first_session': daysSince},
      );

  await storage.write(key: _kDay2FiredKey, value: 'true');
}
