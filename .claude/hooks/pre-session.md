# Hook: Pre-Session

On every session start:

1. Read `CLAUDE.md` — confirm current rules and agent roles
2. Read `.claude/memory.md` — review last session summary
3. Check branch status:
   ```bash
   git branch --show-current && git status --short
   ```
4. Output:
   ```
   [Session Start — OwnUrTime]
   Phase  : {current MVP phase}
   Branch : {current branch}
   Last   : {top memory.md entry, one line}
   Ready. Awaiting direction.
   ```
5. Remind: every task starts with /plan (RULE 15)
