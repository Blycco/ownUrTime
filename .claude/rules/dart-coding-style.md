---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
  - "**/analysis_options.yaml"
---

# Dart Coding Style — Auto-loaded

## Formatting
- Run `dart format` on all Dart files; enforce in CI
- Max line length: 80 chars; trailing commas on multi-line lists

## Immutability
- `final` for local variables; `const` for compile-time constants
- `const` constructors when all fields are immutable
- Return unmodifiable collections from public APIs
- `copyWith()` for mutations on immutable state classes

## Naming
- `camelCase`: variables, parameters, named constructors
- `PascalCase`: classes, enums, typedefs, extensions
- `snake_case`: files and library names
- `SCREAMING_SNAKE_CASE`: top-level constants
- `_prefix`: private members

## Null Safety
- No bang operator (`!`) — use null-aware operators or pattern matching
- `late` only when initialization is guaranteed
- `required` for mandatory constructor parameters

## Sealed Types & Pattern Matching
- Model closed state with sealed classes
- Exhaustive `switch` — no default fallthrough

## Error Handling
- Specify exception types in `catch` clauses
- Never catch `Error` subtypes
- Result-style types for recoverable errors; no exceptions for control flow

## Async
- Always `await` Futures or explicitly call `unawaited()`
- Don't mark functions `async` without `await` inside
- `Future.wait()` for concurrent operations
- Check `context.mounted` after every `await` in Flutter widgets

## Imports
- `package:` imports only — **no relative imports, ever**
  - ✅ `import 'package:ownurtime/core/logging/logger_service.dart';`
  - ❌ `import 'log_context_provider.dart';`
  - ❌ `import '../../core/router/app_router.dart';`
- Order: `dart:` → external packages → internal packages
- Remove unused imports
- `always_use_package_imports: true` 를 `analysis_options.yaml`에 추가해 CI에서 강제할 것

## Code Generation (freezed / riverpod_generator)
- Never manually edit generated files (`*.g.dart`, `*.freezed.dart`)
- Annotations on source files only
