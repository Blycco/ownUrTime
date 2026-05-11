# /done
> Run when a task file's checkboxes are all complete.

Before finalizing, provide execution report using:
- `docs/02_dev_playbook/templates/agent-report-template.md`

1. Pre-commit checks:
   ```bash
   flutter analyze
   flutter test
   grep -rn "sk-\|apiKey.*=.*['\"]" --include="*.dart" lib/
   ```

2. File Feature Report:
   - Copy `.claude/templates/feature-report.md`
     → `docs/reports/phase1/features/{NN}-{name}.md`
   - Fill: summary, architecture decisions, test coverage %, known limitations, key files

3. If an architecture decision was made:
   - Copy `.claude/templates/adr.md` → `docs/decisions/{YYYY-MM-DD}-{title}.md`
   - Fill: context, decision (one sentence), consequences, alternatives

4. If a bug was found and fixed:
   - Copy `.claude/templates/bug-report.md` → `docs/bugs/{YYYY-MM-DD}-{slug}.md`
   - Fill: reproduce steps, root cause, fix applied, prevention

5. Update `.claude/memory.md`:
   ```
   ## {date} | {completed} | {next} | {notes}
   ```

6. Commit:
   ```
   Docs: {NN}-{name} feature report

   Feat: 한국어로 완료 작업 요약
   - 세부 내용
   Ref: #{issue}
   ```
