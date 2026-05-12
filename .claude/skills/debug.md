---
name: debug
description: Systematic bug investigation. Use when a bug is reported, a test fails unexpectedly, or runtime behavior is wrong. Produces a regression test + bug report.
---

# Debug Workflow — Flutter/Dart

## When to Activate
- Bug reported by tester or user
- Unexpected test failure
- Runtime crash or wrong behavior in simulator

## Step 1: Reproduce
Create the minimal reproduction case first. Do not investigate before confirming you can reproduce.

```bash
# Option A: failing test
flutter test test/features/{feature}/{layer}/{test_file}.dart -v

# Option B: run on simulator
flutter run --debug
```

If you cannot reproduce → ask for more context (device, OS version, steps). Never guess.

## Step 2: Isolate — Layer-by-Layer Bisect

Work inward from UI toward the data source:

```
UI Widget → Notifier → UseCase → Repository → DataSource → Supabase
```

At each layer, add a temporary assertion to confirm data is correct:
```dart
// Temporary — remove after isolation
debugPrint('[DEBUG] task list: $tasks');
assert(tasks != null, 'tasks must not be null at this point');
```

Rules:
- Use `debugPrint`, never `print` (stripped in release builds)
- Do NOT fix anything yet — just narrow down the layer
- Stop when you find the layer where the contract is violated

```bash
# Run layer-specific tests
flutter test test/features/{feature}/domain/ -v    # UseCase layer
flutter test test/features/{feature}/data/ -v      # Repository/DataSource layer
```

## Step 2b: Supabase-Specific Layer Isolation

If the bug involves Supabase (data not loading, auth issues, real-time not updating):

```
1. RLS policy     → run raw SQL in Supabase Studio as the affected user_id
2. DataSource     → log the raw Supabase client response before model conversion
3. Repository     → log what the impl returns after mapping
4. UseCase        → log inputs and output of the use case call
5. Notifier       → log state transitions in AsyncNotifier.build() and methods
```

```dart
// Temporary Supabase debug — remove after isolation
final raw = await supabase.from('tasks').select().eq('user_id', userId);
debugPrint('[SUPABASE RAW] $raw');
```

## Step 3: Root Cause

**PHASE GATE — You may NOT proceed to Step 4 until you can complete this sentence:**

> "This bug occurs because **{specific reason}**, not because {symptom}."

If you cannot write this sentence → return to Step 2. Guessing the cause and fixing it is not debugging.

Examples:
- ❌ Wrong: "The list is empty" → add a null check
- ✅ Right: "getTasks() is called before Supabase.initialize() completes" → await init before calling
- ❌ Wrong: "The button doesn't work" → add a try/catch
- ✅ Right: "ref.watch() is used inside a callback (not build), causing stale closure" → change to ref.read()

## Step 4: Fix
- Minimum change — touch only the files needed
- Do NOT refactor or clean up unrelated code in the same commit
- Remove all temporary `debugPrint` / `assert` statements before committing

```bash
flutter analyze    # zero warnings
flutter test       # all pass
```

**3-Strike Rule (obra/superpowers):**
If you have applied 3 or more different fixes and the test still fails → **STOP**.
Do not try a 4th fix. The problem is almost certainly architectural.
Options:
1. Break the problem into a smaller, isolated reproduction case
2. Invoke `/agent flutter-expert` for a deeper diagnosis
3. Re-read the relevant layer's contract (domain interface vs. implementation)

## Step 5: Regression Test (Required)
Write a test that would have caught this bug. Commit it separately.

```bash
# RED: new test fails against unfixed code
git stash         # temporarily stash fix
flutter test test/features/{feature}/{layer}/{new_test}.dart
# → Expected: FAIL
git stash pop     # restore fix
flutter test test/features/{feature}/{layer}/{new_test}.dart
# → Expected: PASS
```

Commit order:
```
Test: regression test for {bug description}   ← RED commit (before fix)
Fix: {root cause fixed}                       ← GREEN commit
```

Korean commit body:
```
Fix: {한국어 버그 원인 요약}
- 재현: {재현 조건}
- 원인: {근본 원인}
- 수정: {변경 내용}
```

## Step 6: Bug Report
If severity is MEDIUM or higher → create `docs/bugs/{YYYY-MM-DD}-{slug}.md`
Copy from `.claude/templates/bug-report.md`.

Fill:
- Reproduce steps (exact)
- Root cause (one sentence)
- Fix applied (file + line)
- Prevention (test added / rule added / accepted risk)

## Definition of Done
- [ ] Bug reproducible before fix, not reproducible after
- [ ] Regression test written and committed (RED → GREEN sequence)
- [ ] `flutter analyze` — zero warnings
- [ ] All other tests still pass
- [ ] Temporary debug statements removed
- [ ] Bug report filed (MEDIUM severity and above)
