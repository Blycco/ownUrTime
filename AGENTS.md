# OwnUrTime — Codex Agent Instructions

## Project
External scaffolding app for adults with ADHD. Flutter + Supabase + Riverpod. iOS/macOS first, Korea launch.
Three core moments: task initiation (2-min micro-start), session maintenance (flexible timer), recovery (1-tap re-entry).

## Your Role
- Implement functions and widget boilerplate
- Generate unit tests and widget tests
- Review existing code and flag bugs or improvements

## Boundary & Override
- Default: Claude Code is orchestrator; Codex is execution-focused implementer.
- Codex scope: implementation, tests, localized refactors, quick debug loops.
- Out of scope by default: architecture redesign, new dependency decisions, policy/security decisions.
- Exception: if the user explicitly requests an override, Codex may handle out-of-scope work.
- Priority: the latest explicit user instruction overrides default boundaries.

## Approval Gate
- For important decisions or high-impact tasks, always propose first.
- Execute only after explicit user approval.
- If approval is unclear, stop and ask for approval before changing files or running impactful operations.
- Final decision authority is always the user.
- Use standard communication flow:
  1. Proposal
  2. Execution (after approval)
  3. Report

## Commit Granularity
- Avoid micro-commits for tiny iterative edits.
- One commit may include many files if they serve one coherent objective.
- Prefer fewer, meaningful commits over frequent fragmented commits.

## Commands
```bash
flutter test               # run all tests
flutter test --coverage    # with coverage report
flutter analyze            # static analysis (target: zero warnings)
flutter build ios --simulator --debug
flutter build macos --debug
dart format .              # format code
flutter pub get            # install packages
```

## Folder Structure (Feature-first)
```
lib/
  core/
    supabase/        ← SupabaseClient singleton
    router/          ← GoRouter config
    theme/           ← AppTheme, AppColors
    l10n/            ← ARB files & localization
    providers/       ← global shared providers
  features/
    {feature}/
      data/
        datasources/ ← Supabase calls ONLY here
        models/      ← JSON models (freezed)
        repositories/ ← Repository implementations
      domain/
        entities/    ← business entities
        repositories/ ← abstract interfaces
        usecases/    ← business logic
      presentation/
        providers/   ← Riverpod Notifiers
        screens/     ← screen widgets
        widgets/     ← reusable widgets

test/
  features/{feature}/
    data/
    domain/
    presentation/
```

## Phase 1 Features
- `task/` — task CRUD, 2-min micro-initiation, AI decomposition
- `session/` — flexible timer (10/15/25 min + custom)
- `recovery/` — distraction logging, context restore card, 1-tap re-entry
- `mood/` — mood check (5-level emoji)
- `auth/` — guest mode first, Apple/Google Sign In

## Stack Specifics
- State: **Riverpod only** (AsyncNotifier, StateNotifier patterns)
- Supabase: called from datasource layer only; RLS required on all tables
- Models: freezed + json_serializable
- Routing: GoRouter
- l10n: flutter_localizations + intl (ARB files)

## Don'ts
- No architecture changes → ask Claude Code first
- No new pubspec.yaml dependencies → discuss first
- No state management other than Riverpod
- No hardcoded Korean strings → use ARB files
- No Supabase calls in presentation layer
- Minimize `dynamic` type usage
- No ad SDK code ever

## Code Style
- Files: snake_case
- Classes: PascalCase
- Variables/functions: camelCase
- Private members: _prefix
- Line length: 80 recommended, 120 max
