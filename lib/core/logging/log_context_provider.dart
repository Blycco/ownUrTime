import 'package:flutter_riverpod/flutter_riverpod.dart';

final logUserIdProvider = NotifierProvider<LogUserIdNotifier, String?>(
  LogUserIdNotifier.new,
);

final logSessionIdProvider = NotifierProvider<LogSessionIdNotifier, String?>(
  LogSessionIdNotifier.new,
);

class LogUserIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
}

class LogSessionIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
}
