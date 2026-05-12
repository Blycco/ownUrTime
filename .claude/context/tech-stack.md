# Tech Stack — OwnUrTime
> Based on PRD Section 16. Optimized for solo dev, cross-platform scale, AI-assisted development.

## Stack Overview
| Layer | Choice | Reason |
|-------|--------|--------|
| App framework | Flutter (Dart) | Single codebase for iOS/macOS/Android/Windows/Web |
| State management | Riverpod | Compile-time safety, code generation, current Flutter standard |
| Backend | Supabase | PostgreSQL + Auth + Storage + Realtime + Edge Functions; minimal solo-dev ops |
| AI (free) | Gemini Flash 2.0 | 1,500 req/day free; called via Edge Functions |
| AI (paid) | Gemini Pro / Claude API | Paid subscribers only; finalize after measuring usage |
| Auth | Supabase Auth | Apple Sign In (App Store required) + Google Sign In |
| Sync | Supabase Realtime + iCloud Drive | Realtime: all platforms; iCloud Drive: Apple offline backup |
| Analytics | PostHog | Auto-collect 5 KPI metrics from Phase 1 |
| Push | APNs (iOS/macOS) | Called from Supabase Edge Functions; FCM added Phase 3+ |

---

## Riverpod Patterns (Required)

### Provider layer flow
```
Supabase (external)
  → DataSource        (data/datasources/ — Supabase calls only here)
    → Repository Impl (data/repositories/)
      → UseCase       (domain/usecases/)
        → Notifier    (presentation/providers/)
          → UI Widget (presentation/screens/, widgets/)
```

### Provider types by use case
```dart
// Static / config value
final themeProvider = Provider<ThemeData>((ref) => AppTheme.light);

// Async data (Future)
final taskListProvider = FutureProvider<List<Task>>((ref) async {
  return ref.watch(taskRepositoryProvider).getTasks();
});

// Real-time stream
final sessionProvider = StreamProvider<Session?>((ref) {
  return ref.watch(sessionRepositoryProvider).watchCurrentSession();
});

// Mutable complex state — prefer AsyncNotifier
class TimerNotifier extends AsyncNotifier<TimerState> { ... }
final timerProvider = AsyncNotifierProvider<TimerNotifier, TimerState>(
  TimerNotifier.new,
);
```

---

## Supabase Patterns

### Client initialization (core/supabase/)
```dart
// core/supabase/supabase_config.dart
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}

// main.dart
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
);
```

### DataSource pattern (Supabase calls only here)
```dart
class TaskRemoteDataSource {
  final SupabaseClient _client;
  TaskRemoteDataSource(this._client);

  Future<List<TaskModel>> getTasks(String userId) async {
    final data = await _client
      .from('tasks')
      .select()
      .eq('user_id', userId)
      .order('created_at');
    return data.map(TaskModel.fromJson).toList();
  }
}
```

### Row Level Security (required on all tables)
- Enable RLS on every table
- Apply `auth.uid() = user_id` policy
- Service role key only in Edge Functions, never in client

---

## Flutter Project Init (run once)
```bash
flutter create \
  --org com.ownurtime \
  --project-name own_ur_time \
  --platforms ios,macos \
  .

# Core dependencies
flutter pub add \
  flutter_riverpod riverpod_annotation \
  supabase_flutter \
  go_router \
  freezed_annotation json_annotation \
  flutter_localizations intl

flutter pub add --dev \
  build_runner riverpod_generator \
  freezed json_serializable \
  flutter_test mockito
```

---

## Environment Variables (.env — never commit)
```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
GEMINI_API_KEY=AIza...     # Edge Functions only, never in Flutter client
POSTHOG_API_KEY=phc_...
```

Build with: `--dart-define-from-file=.env` or `--dart-define=KEY=VALUE`

---

## Platform Notes
- **iOS**: `EventKit` (calendar, Phase 2) requires Swift bridge
- **macOS**: Cmd+Shift+P shortcut for distraction declaration; needs entitlements
- **Android** (Phase 3+): same Flutter codebase; Google Play one-time $25
