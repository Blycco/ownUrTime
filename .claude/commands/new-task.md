# /new-task {feature}
> Example: /new-task session

Start a new feature:

1. Read `.claude/context/folder-structure.md` — confirm structure
2. Find `{feature}` spec in `.claude/context/prd-summary.md`
3. Read `.claude/context/tech-stack.md` — relevant patterns
4. For important/high-impact decisions, draft proposal first using:
   - `docs/02_dev_playbook/templates/agent-proposal-template.md`
   - Wait for explicit user approval before execution
5. Create branch:
   ```bash
   git checkout -b feat/{feature}
   ```
6. Run `/plan` — design and get approval before writing code (RULE 15)
7. Begin implementation
8. After execution, report using:
   - `docs/02_dev_playbook/templates/agent-report-template.md`
