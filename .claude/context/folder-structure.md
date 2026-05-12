# Folder Structure — OwnUrTime
> Feature-first. All Supabase calls isolated to data/datasources/.

## Full Tree
```
own_ur_time/
├── lib/
│   ├── core/
│   │   ├── supabase/
│   │   │   └── supabase_config.dart         ← URL, anonKey (dart-define)
│   │   ├── router/
│   │   │   └── app_router.dart              ← GoRouter
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   ├── l10n/
│   │   │   ├── app_en.arb
│   │   │   ├── app_ko.arb                   ← Phase 1: Korean only
│   │   │   └── l10n.dart                   ← generated
│   │   └── providers/
│   │       └── supabase_provider.dart       ← Provider<SupabaseClient>
│   │
│   ├── features/
│   │   ├── task/                            ← task CRUD + 2-min initiation
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── task_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── task_model.dart      ← freezed + json_serializable
│   │   │   │   └── repositories/
│   │   │   │       └── task_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── task.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── task_repository.dart ← abstract interface
│   │   │   │   └── usecases/
│   │   │   │       ├── get_tasks_usecase.dart
│   │   │   │       ├── create_task_usecase.dart
│   │   │   │       └── decompose_task_usecase.dart  ← AI decomposition
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── task_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── task_list_screen.dart
│   │   │       │   └── task_start_screen.dart  ← 2-min initiation UI
│   │   │       └── widgets/
│   │   │           ├── task_card.dart
│   │   │           └── micro_start_button.dart
│   │   │
│   │   ├── session/                         ← flexible session timer
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   │       └── session.dart         ← duration, status, distractionCount
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── timer_provider.dart  ← AsyncNotifier<TimerState>
│   │   │       └── screens/
│   │   │           └── session_screen.dart
│   │   │
│   │   ├── recovery/                        ← distraction logging + re-entry
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   │       └── distraction.dart     ← type: urgent/impulsive/rest
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── recovery_screen.dart
│   │   │       └── widgets/
│   │   │           └── context_restore_card.dart  ← external working memory UI
│   │   │
│   │   ├── mood/                            ← mood check (5-level emoji)
│   │   │   └── presentation/
│   │   │       └── widgets/
│   │   │           └── mood_check_widget.dart
│   │   │
│   │   ├── auth/                            ← auth (guest mode first)
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── login_screen.dart
│   │   │       └── providers/
│   │   │           └── auth_provider.dart
│   │   │
│   │   └── stats/                           ← Phase 2: auto tracking
│   │
│   └── main.dart
│
├── test/
│   ├── features/
│   │   ├── task/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── session/
│   └── core/
│
├── supabase/
│   ├── migrations/                          ← SQL migration files
│   └── functions/                           ← Edge Functions (AI calls)
│       └── decompose-task/
│           └── index.ts                     ← Gemini Flash 2.0 call
│
├── .env                                     ← never commit
├── pubspec.yaml
├── CLAUDE.md
└── AGENTS.md
```

---

## Core Entities (Phase 1)

### Task
```dart
@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String userId,
    required String title,
    String? description,
    List<String>? decomposedSteps,    // AI decomposition result
    required TaskStatus status,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _Task;
}

enum TaskStatus { pending, inProgress, completed, abandoned }
```

### Session
```dart
@freezed
class Session with _$Session {
  const factory Session({
    required String id,
    required String userId,
    required String taskId,
    required Duration targetDuration,  // 10/15/25 min selection
    required SessionStatus status,
    @Default(0) int distractionCount,
    @Default(0) int resetCount,        // max 3 resets per session
    required DateTime startedAt,
    DateTime? completedAt,
  }) = _Session;
}

enum SessionStatus { active, paused, completed, abandoned }
```

### Distraction
```dart
@freezed
class Distraction with _$Distraction {
  const factory Distraction({
    required String id,
    required String sessionId,
    required DistractionType type,
    required DateTime occurredAt,
    DateTime? returnedAt,   // null = not yet recovered
  }) = _Distraction;
}

enum DistractionType { urgent, impulsive, rest }
```

---

## Supabase Schema (Phase 1)
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  display_name TEXT,
  mood_check_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  title TEXT NOT NULL,
  decomposed_steps JSONB,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  task_id UUID REFERENCES tasks(id),
  target_duration_minutes INTEGER NOT NULL,
  status TEXT DEFAULT 'active',
  distraction_count INTEGER DEFAULT 0,
  reset_count INTEGER DEFAULT 0,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- RLS required on all tables
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
```
