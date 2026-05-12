# Branch and Commit Policy

## Branch Naming
- `feat/{description}`: new feature work
- `fix/{description}`: bug fixes
- `chore/{description}`: maintenance, tooling, docs operations

## Commit Granularity
- Do not commit every tiny iteration.
- Commit when a change is a meaningful unit (behavior, testable step, or coherent refactor).
- Multi-file commits are encouraged when one objective spans several files.

## Anti-Fragmentation Rule
- If commit cadence becomes too high, pause and batch related edits.
- Aim for fewer, meaningful commits rather than many micro-commits.
- Keep `fix/*` fast, but include clear validation context.

## Before PR / Merge
- Squash noisy history into a concise set of meaningful commits.
- Ensure each remaining commit is explainable on its own.
- Confirm analysis/tests pass before final merge.

## Decision Flow Contract
- Orchestrator may propose and execute, but final decision authority is the user.
- For important decisions/high-impact work:
  1. Send proposal using `templates/agent-proposal-template.md`
  2. Wait for explicit approval
  3. Execute
  4. Send report using `templates/agent-report-template.md`

## Suggested Final Shape
- Small fix: 1-3 commits
- Standard feature: 2-6 commits
- Larger feature/refactor: 4-10 commits
