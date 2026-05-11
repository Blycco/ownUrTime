# /qa-report
> Run when all phase1 task checkboxes are complete. Required before TestFlight submission.

If QA decision implies release-impacting action, draft proposal first:
- `docs/02_dev_playbook/templates/agent-proposal-template.md`
- Wait for explicit user approval before proceeding

1. Run `/agent flutter-reviewer` — capture all CRITICAL/HIGH findings

2. Run automated checks:
   ```bash
   flutter analyze
   flutter test --coverage
   grep -rn "sk-\|apiKey.*=" --include="*.dart" lib/
   grep -r '"지금\|"잠깐\|"집중\|"오늘' lib/
   ```

3. Copy `.claude/templates/qa-report.md` → `docs/reports/phase1/qa-report.md`

4. Fill all sections:
   - Paste flutter analyze and test --coverage output
   - Paste flutter-reviewer findings table
   - Complete manual test golden path table
   - List all known issues with severity
   - Set status: PASS / FAIL / CONDITIONAL PASS

5. If FAIL: fix all CRITICAL/HIGH issues → re-run from step 1
   If CONDITIONAL PASS: list conditions → create bug reports for each

6. Commit:
   ```
   Docs: Phase 1 QA 보고서 작성
   - 상태: {PASS/FAIL/CONDITIONAL}
   ```

After completion, provide summary report using:
- `docs/02_dev_playbook/templates/agent-report-template.md`
