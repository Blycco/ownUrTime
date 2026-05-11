# Structured Logging — OwnUrTime
> Read when: adding log calls, debugging production issues, or reviewing code that touches logging.

## Package

```yaml
dependencies:
  talker: ^4.x
  talker_riverpod_logger: ^4.x   # Riverpod provider changes auto-logged

dev_dependencies:
  talker_flutter: ^4.x            # In-app log viewer — debug/profile builds only
```

`talker_flutter` must NOT be included in release builds. Guard with:
```dart
if (kDebugMode) TalkerScreen(talker: talker);
```

---

## Log Levels

| Level | When to use | Release output |
|-------|-------------|----------------|
| `CRITICAL` | App crash, data loss risk | ✅ |
| `ERROR` | Feature failure (Supabase error, Edge Function failure, parse error) | ✅ |
| `WARNING` | Unexpected state but app continues (retry, fallback triggered) | ✅ |
| `INFO` | Key user flow events (session start/complete, auth state change) | ❌ dev only |
| `DEBUG` | State transitions, layer-to-layer data flow | ❌ dev only |
| `VERBOSE` | Temporary deep debugging — **must be removed before commit** | ❌ dev only |

---

## MDC Equivalent Pattern (Flutter has no ThreadLocal)

Dart is single-threaded with an event loop — no ThreadLocal, no native MDC.
**Equivalent**: Riverpod StateProviders updated at auth/session boundaries, read at log call time.

### Context Providers

```dart
// lib/core/logging/log_context_provider.dart
final logUserIdProvider = StateProvider<String?>((ref) => null);
final logSessionIdProvider = StateProvider<String?>((ref) => null);
```

Update at boundaries:
```dart
// AuthRepository — on sign in
ref.read(logUserIdProvider.notifier).state = user.id;

// StartSessionUseCase — on session start
ref.read(logSessionIdProvider.notifier).state = session.id;

// AuthRepository — on sign out / account delete
ref.read(logUserIdProvider.notifier).state = null;
ref.read(logSessionIdProvider.notifier).state = null;
```

### LoggerService

```dart
// lib/core/logging/logger_service.dart
import 'package:riverpod/riverpod.dart';
import 'package:talker/talker.dart';
import 'log_context_provider.dart';

final loggerServiceProvider = Provider<LoggerService>((ref) => LoggerService(ref));

class LoggerService {
  final Ref _ref;
  final Talker _talker = Talker(
    settings: TalkerSettings(
      useConsoleLogs: !const bool.fromEnvironment('dart.vm.product'),
    ),
  );

  LoggerService(this._ref);

  // MDC context — read at call time, not construction time
  String get _ctx {
    final uid = _ref.read(logUserIdProvider) ?? 'anon';
    final sid = _ref.read(logSessionIdProvider) ?? '-';
    return '[$uid:$sid]';
  }

  String _msg(String feature, String message, Map<String, dynamic>? extra) {
    final parts = [_ctx, '[$feature]', message];
    if (extra != null && extra.isNotEmpty) {
      parts.add(extra.entries.map((e) => '${e.key}=${e.value}').join(' '));
    }
    return parts.join(' | ');
  }

  void info(String feature, String message, {Map<String, dynamic>? extra}) =>
      _talker.info(_msg(feature, message, extra));

  void warning(String feature, String message, {Map<String, dynamic>? extra}) =>
      _talker.warning(_msg(feature, message, extra));

  void error(
    String feature,
    String reason,
    Object error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  ]) =>
      _talker.handle(error, stackTrace, _msg(feature, reason, extra));

  void critical(String feature, String reason, Object error, [StackTrace? stackTrace]) =>
      _talker.critical(_msg(feature, reason, null), error, stackTrace);
}
```

---

## Log Format Standard

```
[LEVEL] timestamp [userId:sessionId] [feature] | message | key=value key=value
  error: ExceptionType: message
  #0  ClassName.method (file.dart:line)
  #1  ...
```

Examples:

```
[INFO]  2026-05-11 14:32:15 [u1a2b3:s9x8y7] [session] | Session started | duration=25
[WARN]  2026-05-11 14:32:18 [u1a2b3:s9x8y7] [session] | Reset limit approaching | resets=2 max=3
[ERROR] 2026-05-11 14:32:20 [u1a2b3:s9x8y7] [task] | Failed to decompose task | taskId=abc123
  error: FunctionException: 429 Too Many Requests
  #0  DecomposeTaskUseCase.call (decompose_task_usecase.dart:34)
  #1  TaskStartNotifier.decompose (task_start_provider.dart:78)
```

---

## Where to Log (Layer Rules)

| Layer | Allowed levels | Notes |
|-------|---------------|-------|
| `data/datasources/` | ERROR | Supabase errors, network failures |
| `domain/usecases/` | WARNING, ERROR | Business rule violations |
| `presentation/providers/` | WARNING, ERROR | State transition failures |
| `presentation/screens/` | **NONE** | Never log in UI layer |
| `presentation/widgets/` | **NONE** | Never log in UI layer |
| `core/logging/` | All | LoggerService itself |

**Analytics vs Logging**: PostHog events = KPI measurement. Talker logs = debugging.
Never call `analyticsService.track()` and `logger.info()` for the same event.

---

## Supabase Error Pattern

```dart
// In DataSource — catch Supabase exceptions, log, rethrow
try {
  final data = await _client.from('tasks').select().eq('user_id', userId);
  return data.map(TaskModel.fromJson).toList();
} on PostgrestException catch (e, st) {
  _logger.error(
    'task_datasource',
    'Failed to fetch tasks',
    e,
    st,
    {'code': e.code ?? '-', 'hint': e.hint ?? '-'},
  );
  rethrow; // Repository maps to domain exception
}
```

---

## PII — Never Log

| Data | Reason |
|------|--------|
| Email address | PIPA personal information |
| Apple Sign In token | Security |
| Supabase JWT / service_role key | Security |
| Task title content | User personal data |
| Mood check value (1–5) | Health-sensitive data |
| Gemini API response body | May contain user input |
| Device identifiers (IDFA, IDFV) | PIPA |

**Task logs: ID only**
```dart
// ❌
_logger.info('task', 'Created: ${task.title}');

// ✅
_logger.info('task', 'Created', extra: {'taskId': task.id});
```

---

## Riverpod Auto-Logging (talker_riverpod_logger)

```dart
// main.dart — add to ProviderScope
ProviderScope(
  observers: [
    TalkerRiverpodObserver(
      talker: container.read(loggerServiceProvider)._talker,
      settings: const TalkerRiverpodLoggerSettings(
        enabled: !bool.fromEnvironment('dart.vm.product'), // dev only
        printProviderAdded: false,    // too noisy
        printProviderUpdated: true,   // state changes
        printProviderDisposed: false,
        printProviderFailed: true,    // provider errors
      ),
    ),
  ],
  child: MyApp(),
)
```

---

## Release Build Behavior

| Mode | Levels output | TalkerScreen |
|------|--------------|--------------|
| debug | ALL | Visible (kDebugMode guard) |
| profile | ALL | Visible |
| release | WARNING + ERROR + CRITICAL | Hidden |

The `dart.vm.product` env var is `true` in release builds automatically.
No manual flag needed — `const bool.fromEnvironment('dart.vm.product')` handles it.
