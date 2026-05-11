# System Architecture — OwnUrTime
> Read when: designing new features, adding cross-feature dependencies, or platform-specific code.

## System Data Flow
```
User Action (Flutter UI)
  → Riverpod Notifier        (presentation/providers/)
    → UseCase                (domain/usecases/)
      → Repository Interface (domain/repositories/)
        → Repository Impl    (data/repositories/)
          → DataSource       (data/datasources/)
            → Supabase Client (PostgreSQL / Auth / Storage / Realtime)
              → Edge Function (decompose-task, push-notification)
                → Gemini Flash 2.0 / APNs

Side channels (always through repository layer, never UI):
  → PostHog analytics  (AnalyticsService in core/analytics/)
  → iCloud Drive backup (ICloudBackupService in core/backup/ — fires on session complete)
```

## Layer Boundaries (non-negotiable)
| From | May call | Must NOT call |
|------|----------|---------------|
| UI Widget | Notifier only | UseCase, Repository, DataSource directly |
| Notifier | UseCase only | Repository, DataSource, Supabase client |
| UseCase | Repository Interface only | DataSource, Supabase client |
| DataSource | Supabase client only | UseCase, Repository, other DataSources |
| AnalyticsService | PostHog SDK only | Never from widgets — repository/usecase layer only |

**Cross-feature rule**: features never import each other's internals.
Shared data (e.g., current session in recovery feature) flows through domain entities in `lib/core/`.

## Feature-First Folder Map
```
lib/
├── core/
│   ├── analytics/      ← AnalyticsService (PostHog wrapper)
│   ├── backup/         ← ICloudBackupService
│   ├── l10n/           ← ARB files + generated AppLocalizations
│   ├── router/         ← GoRouter (app_router.dart)
│   ├── supabase/       ← SupabaseConfig (dart-define constants)
│   └── theme/          ← AppTheme, AppColors
└── features/
    └── {feature}/
        ├── data/
        │   ├── datasources/   ← Supabase calls only here
        │   ├── models/        ← freezed + json_serializable
        │   └── repositories/  ← implements domain interface
        ├── domain/
        │   ├── entities/      ← freezed, zero external dependencies
        │   ├── repositories/  ← abstract interface
        │   └── usecases/      ← single-responsibility, one public method
        └── presentation/
            ├── providers/     ← AsyncNotifier / StreamProvider
            ├── screens/       ← full-page widgets
            └── widgets/       ← reusable UI components
```

## State Management Philosophy
| State type | Provider type | Example |
|------------|---------------|---------|
| Server data (async, mutable) | `AsyncNotifier` | task list, session state |
| Real-time stream | `StreamProvider` | live session updates |
| Derived / computed | `Provider` | filtered task count |
| Static config | `Provider` | theme, router, SupabaseClient |

- No global mutable singletons — everything injected via Riverpod `ref`
- `ref.watch` in build, `ref.read` in callbacks only

## Multi-Platform Strategy
| Platform | Status | Notes |
|----------|--------|-------|
| iOS | Phase 1 | Primary target |
| macOS | Phase 1 | Same codebase; adds Cmd+Shift+P shortcut |
| iPad | Phase 2 | Same codebase; adaptive layout |
| Android | Phase 3 | Same codebase; FCM replaces APNs |
| Windows/Web | Phase 4+ | Same codebase; iCloud backup not available |

Platform-specific guards:
```dart
if (Platform.isMacOS) { /* macOS keyboard shortcut */ }
if (Platform.isIOS || Platform.isMacOS) { /* Apple-only: iCloud, EventKit */ }
```

Swift bridges: only for `EventKit` (Phase 2 calendar) — isolate in `ios/Classes/EventKitBridge.swift`.
Never add Swift for anything achievable in Dart.

## Supabase Edge Functions
| Function | Trigger | Purpose |
|----------|---------|---------|
| `decompose-task` | Flutter HTTP call | Gemini Flash 2.0 → 3 sub-steps; rate-limited 10/day |
| `send-push` | Supabase DB webhook | APNs notification for medication reminder (Phase 2) |

Edge Functions are the only place `service_role` key and `GEMINI_API_KEY` exist.
