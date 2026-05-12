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

## feat/* → develop: PR 경유

feat/fix/chore 브랜치는 직접 `git merge` 금지 — PR 경유 필수 (변경 기록 문서화 목적).

```bash
gh pr create --base develop --title "{branch}: {한국어 요약}" \
  --body "변경 내용: {요약}\nQA: analyze clean / test passed / flutter-reviewer {결과}"
gh pr merge --merge --delete-branch
```

PR 머지 시 push 자동 완료.  
**Prohibited**: `git merge` 직접 실행으로 develop 변경.

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

> Codex & Gemini workflow → `.claude/rules/codex-gemini-workflow.md`

---

## Task Start — GitHub Issue

태스크 시작 시 GitHub 이슈 생성 후 태스크 파일 헤더에 번호 기록.

```bash
gh issue create --title "{task name}" --body "{brief description}"
```

해당 태스크의 모든 커밋: `Ref: #{issue}` 필수. PR body에도 이슈 번호 포함.
## /done Proactive Suggestion

태스크 완료 감지 시 사용자 호출 전에 먼저 제안 — 기다리지 말 것.

Triggers: 구현+검증 완료 직후; 사용자가 "done"/"완료"/"다음" 신호; 현재 태스크 미커밋 상태에서 다음 태스크 시작.  
**Prohibited**: 사용자가 `/done` 호출할 때까지 대기.

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
- Task file has Codex items → stop, write /codex prompt first; do not implement directly
