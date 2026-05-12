# Process & Workflow Rules — Auto-loaded
> Loaded every session. All rules are MUST — no exceptions.

---

## ⛔ Pre-commit Hard Blockers — No Exceptions

All 5 checks must pass **in order** before any commit command is executed.
"Small fix", "urgent", "CI passed", "I know this code", "already reviewed" — none are exceptions.

```
[ ] 1. flutter analyze        → zero warnings
[ ] 2. flutter test           → all passed
[ ] 3. Secret scan            → grep -rn "sk-\|apiKey.*=.*['\"]" --include="*.dart" lib/
[ ] 4. Run flutter-reviewer agent → capture full output (report "no issues" if clean)
[ ] 5. Present results 1–4 to user + wait for explicit approval
```

**Do not execute `git commit` until step 5 is complete.**

---

## ⛔ Common Rationalization Patterns — All Rejected

Stop immediately when any of these thoughts arise. Return to the hard blocker checklist.

| Rationalization | Why it's rejected |
|-----------------|------------------|
| "analyze/test passed, that's enough" | flutter-reviewer catches design & security issues automation misses |
| "it's a small fix, reviewer not needed" | A "small fix" this session produced 3 HIGH issues |
| "it's urgent, move fast" | Urgency increases error risk. Blockers cannot be shortened |
| "user already approved the plan" | Plan approval ≠ commit approval. Report results first, get separate approval |
| "I know this code, review is pointless" | Review finds what you *missed*, not what you *don't know* |
| "I'll fix it right after committing" | Commits are permanent history. Don't create unfixed commits |
| "It's Codex work but I'm faster, I'll do it" | Not using Codex is itself a violation. Return to Pre-work Gate |

---

## /done Execution Order

Same as the hard blocker checks, plus:

1. flutter analyze → capture output
2. flutter test → capture output
3. Secret scan
4. **Run flutter-reviewer agent** (capture full output)
5. Fix found issues (if any) → re-run steps 1–4 after fixes
6. Present steps 1–5 results to user + request approval ← **must stop here**
7. Confirm explicit approval, then commit

**Steps 6 and 7 must never be bundled into the same message.**

---

## develop merge → push immediately

When a merge into `develop` completes, run `git push origin develop` **immediately**.  
Merge and push are one unit — stopping after merge without pushing is an incomplete state.

```bash
git merge --no-ff {branch} -m "Merge {branch}: ..." && git push origin develop
```

If `git push` fails (conflict, auth, etc.), report to user immediately and stop.  
**Prohibited**: deciding to "push later" after a merge.

---

## Approval Gate — Commit/Push

Before committing, always present:
```
"Committing the following files:
  - [file list]
Commit message: [message]
QA result: [summary]
Do you approve?"
```
Wait for explicit "yes" / "go ahead" / "OK" from the user before executing.

**Prohibited**: auto-committing because checks passed.  
**Prohibited**: bundling "shall I commit?" and the commit execution in the same message.

---

## Codex Role Boundary — Delegation Criteria

### Claude Code owns (Orchestrator)
- Architecture decisions and changes
- Domain entities / interfaces / UseCase design
- Cross-feature refactors
- Security, data, and RLS decisions
- Final PR review and merge judgment
- Review and integration of Codex output

### Codex owns (Implementer + QA)
- Widget implementation / boilerplate
- Repository implementation (data layer)
- DataSource implementation
- Test generation (unit / widget)
- Code review and bug flagging
- Config file edits
- Package installation and simple file edits

### ⛔ Task Start = /codex First — Hard Blocker

If the task file has **any** item labeled `Codex`:

```
[ ] 1. Identify Claude Code items (interfaces / entities / architecture)
[ ] 2. Identify Codex items (implementation / tests / boilerplate)
[ ] 3. Write /codex prompt and hand off to user ← must stop here
[ ] 4. Receive Codex output after user runs Codex CLI
[ ] 5. Then start Claude Code items
```

**Writing even one line of code in a Codex-labeled item is a rule violation.**  
"Just a draft", "just the interface", "just the skeleton" — all count as implementation. /codex first.

### After Receiving Codex Output — Claude Code Review

After Codex finishes, Claude Code must:
1. `flutter analyze` — zero warnings
2. Verify domain interface ↔ implementation alignment
3. If items are missing: re-delegate via `/codex` or report to user

### ⛔ Codex Rationalization Patterns — All Rejected

| Rationalization | Why it's rejected |
|-----------------|------------------|
| "I'm faster than waiting for Codex" | Speed does not outrank collaboration rules |
| "This file is simple enough to do myself" | Simplicity is not grounds for boundary violation |
| "Writing a Codex prompt takes longer" | Writing the prompt IS Claude Code's design role |
| "I'll write a draft and hand it to Codex" | A draft is implementation. Write /codex prompt first |
| "I designed it, so implementing is efficient" | When design is done, stopping is Claude Code's role |

### Boundary Violations
Directly implementing Codex-owned items is prohibited regardless of reason.  
Only exception: user explicitly says "Claude, do it directly."

---

## /done Proactive Suggestion

When a task appears complete, Claude Code must proactively suggest — do not wait for the user to call `/done`:

```
The task appears complete. Shall I run `/done`?
(flutter analyze → test → secret scan → flutter-reviewer → report → commit approval)
```

**Timing:**
- Immediately after implementation + validation (curl/build/etc.) are both done
- When user signals "done", "complete", "next"
- When next task comes up but current task hasn't been committed yet

**Prohibited**: waiting for the user to call `/done`.

---

## Session Start Checklist

Before the first task of every session, read `.claude/memory.md` and output at least one line of text describing current state (branch, completed items, next step).  
Do not make decisions that contradict memory.md contents.

---

## Context File Reading (RULE 14 enforcement)

Before starting any task, in addition to reading relevant `.claude/context/` files:  
- Read `memory.md`
- Read the relevant task file (`.claude/tasks/phase1/{NN}-*.md`)

Compare task file contents against current state — do not mistake "already done" for "to do."

---

## Self-Check Triggers

Stop and verify rule compliance in these situations:
- About to run a commit command → have all 5 hard blockers been cleared?
- Thought of "let me finish this quickly" → check rationalization pattern list
- About to proceed without user approval
- Task file assigns item to Codex but Claude Code is implementing it → stop immediately, switch to writing /codex prompt
- Task file has Codex items but /codex has not been called yet → run Pre-work Gate
