# OwnUrTime — Codex Agent Instructions

## Project
External scaffolding app for adults with ADHD. Flutter + Supabase + Riverpod. iOS/macOS first, Korea launch.
Three core moments: task initiation (2-min micro-start), session maintenance (flexible timer), recovery (1-tap re-entry).

## Your Role
- Implement functions and widget boilerplate
- Generate unit tests and widget tests
- Review existing code and flag bugs or improvements

> Role boundary, approval gate, commit rules → `CLAUDE.md` + `.claude/rules/codex-gemini-workflow.md`

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
