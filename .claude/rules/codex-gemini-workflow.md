---
paths:
  - "**"
---

# Codex & Gemini Workflow — Auto-loaded

## Codex — Role Boundary

### Claude Code owns (Orchestrator)
- Architecture decisions and changes
- Domain entities / interfaces / UseCase design
- Cross-feature refactors
- Security, data, and RLS decisions
- Final PR review and merge judgment

### Codex owns (Implementer + QA)
- Widget implementation / boilerplate
- Repository / DataSource implementation
- Test generation (unit / widget)
- Code review and bug flagging
- Config file edits, package installation

## ⛔ Task Start = Codex First — Hard Blocker

If a task item is labeled `Codex`:

```
[ ] 1. Identify Claude Code items (interfaces / entities / architecture)
[ ] 2. Identify Codex items (implementation / tests / boilerplate)
[ ] 3. Run codex exec via Bash — Claude Code executes directly
[ ] 4. Review Codex output (flutter analyze + interface alignment)
[ ] 5. Then proceed with Claude Code items
```

```bash
codex exec "implementation prompt"
```

**Writing even one line of code in a Codex-labeled item is a rule violation.**  
Exception: user explicitly says "Claude, do it directly."

### After Receiving Codex Output

1. `flutter analyze` — zero warnings
2. Verify domain interface ↔ implementation alignment
3. Missing items → re-delegate or report to user

## ⛔ Codex Rationalization Patterns — All Rejected

| Rationalization | Why rejected |
|-----------------|-------------|
| "I'm faster than waiting for Codex" | Speed does not outrank rules |
| "This file is simple enough" | Simplicity is not grounds for violation |
| "Writing a Codex prompt takes longer" | Writing the prompt IS Claude Code's design role |
| "I'll write a draft and hand it to Codex" | A draft is implementation — write prompt first |
| "I designed it, implementing is efficient" | When design is done, stopping IS the role |

## Gemini CLI — Research & Lookup

```bash
gemini -p "question or search topic"
```

Use for: library/API comparisons, App Store/PIPA compliance, Flutter/Supabase release notes,
any lookup that benefits from up-to-date external search.

After Gemini responds: Claude Code interprets and applies to architectural decisions.

## File Size Limits — Bloat Prevention

| File | Limit |
|------|-------|
| CLAUDE.md | ≤ 120 lines |
| AGENTS.md | ≤ 80 lines |
| process-workflow.md | ≤ 130 lines |
| codex-gemini-workflow.md | ≤ 90 lines |
| rules/*.md (other) | ≤ 100 lines |

Before adding: check line count. If at limit, refactor existing content first — no append-only growth.
