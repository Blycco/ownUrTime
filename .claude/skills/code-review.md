---
name: code-review
description: Request a structured code review before merging any branch. Dispatches flutter-reviewer agent with full context. Never skip — not even for "small" changes.
origin: Adapted from obra/superpowers requesting-code-review (78K stars)
---

# Code Review Workflow — OwnUrTime

## When to Activate
- Before every `feat/*` → `develop` merge
- Before every `develop` → `main` merge
- Before every PR to Codex-generated code that touches domain/ or data/ layers

**Never skip because "it's a small change."**
The cost of a skipped review is always higher than the review itself.

---

## Step 1: Summarize the Change

```bash
git diff develop...HEAD --stat
git log develop..HEAD --oneline
```

Prepare a one-paragraph context for the reviewer:
- What feature/bug this addresses
- Which task file it corresponds to (`.claude/tasks/phase1/{NN}-{name}.md`)
- Any known constraints or tradeoffs made

## Step 2: Run Pre-Review Checks

These must pass before invoking the reviewer:

```bash
flutter analyze --fatal-infos    # zero warnings required
flutter test                      # all tests pass
grep -rn "sk-\|apiKey.*=.*['\"]" --include="*.dart" lib/   # no secrets
```

If any check fails → fix first, then request review.

## Step 3: Invoke flutter-reviewer

```
/agent flutter-reviewer
```

Provide the agent with:
1. The diff summary from Step 1
2. The context paragraph
3. Specific areas of concern (e.g., "not sure about RLS on the new table" or "this Riverpod pattern feels off")

## Step 4: Act on Findings

| Severity | Action |
|----------|--------|
| ❌ **CRITICAL** | Merge blocked. Fix and re-run `/code-review` from Step 1 |
| ⚠️ **HIGH** | Fix before merging. If skipping for valid reason → document in ADR |
| ℹ️ **MEDIUM** | Fix now or create a tracked tech debt task |
| 💬 **LOW** | Optional — fix if trivial, otherwise note in feature report |

## Step 5: Record Results

- If CRITICAL or HIGH found and fixed → note in the feature report (`docs/reports/phase1/features/{NN}.md`)
- If HIGH was knowingly skipped → create `docs/decisions/{date}-review-override.md`
  - Fill: what the finding was, why it was accepted, when it will be addressed

## When to Invoke flutter-expert Instead

`/code-review` + `flutter-reviewer` handles: security, architecture, layer violations, secrets.

If the reviewer surfaces a Flutter-specific implementation problem (widget rebuild, Riverpod state, async race) that needs deeper analysis → invoke `/agent flutter-expert` separately.

## Definition of Done
- [ ] Pre-review checks all pass
- [ ] flutter-reviewer ran and produced a findings report
- [ ] All CRITICAL issues resolved
- [ ] All HIGH issues resolved or documented in ADR
- [ ] Results noted in feature report
