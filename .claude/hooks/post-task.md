# Hook: Post-Task

After every completed task:

1. Update `.claude/memory.md`:
   ```
   ## {today's date} | {one-line summary of what was completed} | {next task} | {notes}
   ```
2. If an architecture decision was made:
   - Create `docs/decisions/` directory if needed
   - Write `{date}-{title}.md` with: decision, rationale, alternatives considered
3. If a new error pattern was found:
   - Append to `.claude/errors.md`:
     ```
     ## {error name} | {symptom} | {cause} | {fix}
     ```
4. Run `/done` to commit
