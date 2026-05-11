---
name: refactor
description: Safe structural refactoring with test coverage gate. Never refactor without green tests first. One concern per commit.
---

# Refactor Workflow — Flutter/Dart

## When to Activate
- Code works but is hard to read or maintain
- Extracting a method/class that is reused in 3+ places
- Renaming after domain clarification
- Splitting a file that has grown beyond one responsibility

## When NOT to Use
- To fix a bug — use `/debug` instead (separate concern)
- When coverage < 80% on the target file — add tests first
- When in the middle of a feature — finish the feature first

---

## Step 1: Coverage Gate

```bash
flutter test --coverage
# Check coverage for target files:
# open coverage/html/index.html (requires: genhtml coverage/lcov.info -o coverage/html)
```

If domain/ or data/ coverage for the target file is below 80% → **stop**.
Add tests first, then return to this workflow.

## Step 2: Freeze Tests

Run and confirm all tests are GREEN before touching any code:

```bash
flutter test         # all pass
flutter analyze      # zero warnings
```

Commit this state:
```
Test: freeze tests before refactor of {target description}
```

This commit is your safety net. If anything breaks, `git diff` against this commit shows exactly what you changed.

## Step 3: Refactor — One Concern at a Time

Apply **one refactoring pattern per commit**. Never mix two patterns in the same commit.

| Pattern | Example |
|---------|---------|
| Extract method | long method → 2–3 focused methods |
| Extract class | mixed responsibilities → separate class |
| Rename | unclear name → domain-accurate name |
| Inline | single-use variable/method → inline |
| Move | misplaced method → correct layer |

```bash
# After each change — verify nothing broke
flutter test         # must still pass
flutter analyze      # must still be zero warnings
dart format .        # keep formatting clean
```

## Step 4: Commit Each Step

```
Refactor: extract {what} from {source} into {destination}
Refactor: rename {old} to {new} — {reason}
Refactor: move {what} from {layer A} to {layer B}
```

Korean body:
```
Refactor: {한국어 구조 변경 요약}
- 변경 이유: {왜 필요한가}
- 영향 범위: {어떤 파일/레이어}
```

## Step 5: Final Verify

```bash
flutter test --coverage   # coverage must not drop below pre-refactor level
flutter analyze           # zero warnings
```

If coverage dropped → add tests to restore it before marking done.

## Hard Rules

- **No behavior changes** — refactoring must not change what the code does
- **No bug fixes** during refactor — open a separate `/debug` session
- **No new features** during refactor — finish the refactor, then add features
- **One PR per concern** — never combine rename + extract + move in one PR
- **No touching unrelated files** — resist the urge to "clean up while you're in there"

## Definition of Done
- [ ] All tests pass before and after (no new failures)
- [ ] `flutter analyze` — zero warnings
- [ ] Coverage did not drop
- [ ] Each commit has exactly one refactoring pattern
- [ ] No behavior changes (verify by running full test suite)
