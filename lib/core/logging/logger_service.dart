import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';
import 'package:ownurtime/core/logging/log_context_provider.dart';

final loggerServiceProvider = Provider<LoggerService>(
  (ref) => LoggerService(ref, appTalker),
);

// Shared Talker instance — used by both LoggerService and TalkerRiverpodObserver.
final appTalker = Talker(
  settings: TalkerSettings(
    useConsoleLogs: !const bool.fromEnvironment('dart.vm.product'),
  ),
);

class LoggerService {
  const LoggerService(this._ref, this._talker);

  final Ref _ref;
  final Talker _talker;

  String get _ctx {
    final uid = _ref.read(logUserIdProvider) ?? 'anon';
    final sid = _ref.read(logSessionIdProvider) ?? '-';
    return '[$uid:$sid]';
  }

  String _msg(
    String feature,
    String message,
    Map<String, dynamic>? extra,
  ) {
    final parts = [_ctx, '[$feature]', message];
    if (extra != null && extra.isNotEmpty) {
      parts.add(extra.entries.map((e) => '${e.key}=${e.value}').join(' '));
    }
    return parts.join(' | ');
  }

  void info(
    String feature,
    String message, {
    Map<String, dynamic>? extra,
  }) =>
      _talker.info(_msg(feature, message, extra));

  void warning(
    String feature,
    String message, {
    Map<String, dynamic>? extra,
  }) =>
      _talker.warning(_msg(feature, message, extra));

  void error(
    String feature,
    String reason,
    Object error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  ]) =>
      _talker.handle(error, stackTrace, _msg(feature, reason, extra));

  void critical(
    String feature,
    String reason,
    Object error, [
    StackTrace? stackTrace,
  ]) =>
      _talker.critical(_msg(feature, reason, null), error, stackTrace);
}
