# /phase-summary
> Run after QA report status = PASS and TestFlight build is submitted.

1. Review all feature reports in `docs/reports/phase1/features/` (00–09)

2. Review all ADRs in `docs/decisions/`

3. Copy `.claude/templates/phase-summary.md` → `docs/reports/phase1/phase-summary.md`

4. Fill all sections:
   - What Shipped: confirm 10 features against task files
   - ADR Index: list all decisions files created
   - Tech Debt: items explicitly punted to Phase 2
   - KPI Targets: set PostHog baseline metrics to track
   - TestFlight: build number, submission date, tester count
   - Lessons: process/architecture/UX improvements for Phase 2

5. Begin Phase 2 planning:
   - Update `.claude/tasks/phase2/README.md` — start populating feature files
   - Read PRD sections 13–15 for Phase 2 scope

6. Commit:
   ```
   Docs: Phase 1 완료 요약 보고서

   - 10개 기능 완료
   - TestFlight 빌드: {number}
   ```
