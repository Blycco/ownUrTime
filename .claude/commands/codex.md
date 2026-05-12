# /codex {task}
> Generate a Codex CLI prompt for delegated implementation.
> Example: /codex "write TaskRepository implementation"

Before execution, if task includes important decisions/high-impact changes:
- Create proposal first with `docs/02_dev_playbook/templates/agent-proposal-template.md`
- Wait for explicit user approval

Generate a prompt using this template, then run it in the Codex CLI terminal:

---
**Codex prompt template:**

```
Project: OwnUrTime (Flutter + Supabase + Riverpod, iOS-first)
Folder structure: see AGENTS.md

Task: {task}

Before implementation, read only relevant context files in `.claude/context/` (for example: `dart-patterns.md`, `folder-structure.md`, `adhd-domain.md`).

Related files:
- Interface: lib/features/{feature}/domain/repositories/{file}.dart
- Model: lib/features/{feature}/data/models/{file}.dart

Requests:
1. Write {file}_impl.dart implementation (data/repositories/)
2. Write unit tests for that implementation (test/features/{feature}/data/)

Constraints:
- Riverpod only for state
- Supabase calls in datasource only
- Type hints required, no dynamic
- Zero flutter analyze warnings
- If the user explicitly requests a boundary override, proceed with the requested scope and state the override in output.
```
---

Then in the Codex CLI terminal:
```bash
cd /Users/verity/develop/project/ownUrTime
codex "{generated prompt}"
```

After work is completed, send report with:
- `docs/02_dev_playbook/templates/agent-report-template.md`
