# OwnUrTime — CLAUDE.md
> Auto-loaded every session. Keep under 120 lines. Details in `.claude/context/`.

---

## Project Overview
External Scaffolding app for adults with ADHD traits ("착수·유지·복귀" — initiation, maintenance, recovery).
The app supplies structure so execution happens via architecture, not willpower.
- **Stage**: MVP (Phase 1 in development)
- **Developer**: Solo (design + dev + product)
- **Platform**: iPhone + Mac first → iPad → Android → Windows → Web
- **Market**: Korea launch first → English-speaking markets
- **Last Session**: `.claude/memory.md`

---

## Tech Stack
```
Mobile/Desktop  Flutter (Dart) + Riverpod
Backend/DB      Supabase (PostgreSQL + Auth + Storage + Realtime + Edge Functions)
AI (free)       Gemini Flash 2.0 (1,500 req/day free, called from Edge Functions)
AI (paid)       Gemini Pro / Claude API (paid subscribers only)
Auth            Supabase Auth — Apple Sign In (required by App Store) + Google Sign In
Sync            Supabase Realtime (primary) + iCloud Drive (Apple offline backup)
Analytics       PostHog (set up from Phase 1)
Push            APNs (iOS/macOS) / FCM (Android, Phase 3+)
```

---

## Agent Division of Labor
| Agent | Owns |
|-------|------|
| **Claude Code (me)** | Architecture design, complex business logic, project context, final PR review |
| **Codex CLI** | Function implementations, widget boilerplate, test generation, review drafts |

Delegate to Codex: `/codex {task}` → generates prompt → run in Codex CLI terminal

### Orchestration & Exception Rule
- Default mode: Claude Code orchestrates, Codex executes implementation-heavy loops.
- Final decision authority: user.
- Claude Code ownership: architecture changes, cross-feature refactors, product/security decisions, final merge judgment.
- Codex ownership: bounded implementation, test generation, structured file edits, fast fix loops.
- User override: if user explicitly requests, either agent may take the other side's scope (e.g., token budget, availability, speed).
- Override precedence: newest explicit user instruction wins for that task.

### Approval Gate (Critical)
- Important decisions and high-impact work require user approval first.
- Execution model: propose first, execute only after explicit user approval.
- Applies to architecture changes, dependency changes, policy/security decisions, destructive actions, and release-impacting changes.
- If approval is not explicit, stop at proposal/checklist and wait.
- Communication flow template:
  1. Proposal (understanding + plan + risks + approval request)
  2. Execute after approval
  3. Report (what changed + validation + next decisions)

---

## Mandatory Rules
```
RULE 01  No hardcoded secrets — .env or Supabase Vault only
RULE 02  Riverpod only — no GetX, Provider, or BLoC
RULE 03  Supabase calls only inside data/datasources layer
RULE 04  Repository abstract interface in domain/, implementation in data/
RULE 05  Type hints required on all Dart code — minimize dynamic
RULE 06  l10n required — no hardcoded Korean strings; use ARB files
RULE 07  Never show "how much wasn't done" — only "how much was done"
RULE 08  No ad code ever (permanent policy)
RULE 09  Zero flutter analyze warnings
RULE 10  Widget tests required (key screens); unit tests required (business logic)
RULE 11  ADHD UX: minimize initiation barrier, no forced input, first action = 1 tap
RULE 12  Guest mode first — no forced login before 3rd session completion
RULE 13  i18n structure from Phase 1 — actual translations in Phase 4
RULE 14  Read relevant .claude/context/ files before starting any task
RULE 15  Plan Mode required — run /plan before writing any code
```

---

## Branch & Commit Rules
```
Branches: feat/{description} | fix/{description} | chore/{description}

Commit format (Korean body — developer preference):
  Feat: 한국어로 작업 요약
  - 세부 내용 1
  - 세부 내용 2
  Ref: #{issue}

Types: Feat | Fix | Perf | Refactor | Test | Docs | Chore
```

- Do not create micro-commits for tiny iterative steps.
- For `feat/refactor/chore/test/docs`, commit only when the change forms a meaningful unit.
- Multiple files changed in one commit is acceptable when they represent one coherent objective.
- Before opening PR or merging, squash noisy history and keep a concise, meaningful commit set.
- `fix/*` may be small and fast, but must still include reproducible context and validation.

---

## Context Reference Guide
| File | Use When |
|------|----------|
| `.claude/context/prd-summary.md` | Feature specs, MVP phases |
| `.claude/context/tech-stack.md` | Stack choices, Supabase/Riverpod patterns |
| `.claude/context/architecture.md` | System data flow, layer rules, multi-platform |
| `.claude/context/cicd.md` | GitHub Actions, TestFlight pipeline, secrets |
| `.claude/context/deployment.md` | Zero-downtime migrations, App Store staged rollout |
| `.claude/context/ios-compliance.md` | PrivacyInfo.xcprivacy, PIPA, App Store checklist |
| `.claude/context/adhd-domain.md` | ADHD domain knowledge, UX rules |
| `.claude/context/folder-structure.md` | Folder layout, DB schema |
| `.claude/context/business.md` | KPIs, revenue, competitors |
| `.claude/context/dart-patterns.md` | Riverpod + Repository code patterns |
| `.claude/context/dart-testing.md` | Test patterns, fakes, coverage |
| `.claude/context/logging.md` | Log levels, LoggerService, PII rules, Talker setup |

> Rules: `.claude/rules/` — auto-loaded every session.

## Task Tracking
| Phase | Location |
|-------|----------|
| Phase 1 (active) | `.claude/tasks/phase1/` — 10 files, checkbox per task |
| Phase 2 (pending) | `.claude/tasks/phase2/README.md` — populate before Phase 1 ends |

Start a feature: `/new-task {feature}` → reads tasks/phase1/{N}-feature-{name}.md

## Reports & Records
| Trigger | Command | Output |
|---------|---------|--------|
| Each task done | `/done` | `docs/reports/phase1/features/{NN}-{name}.md` |
| All tasks done | `/qa-report` | `docs/reports/phase1/qa-report.md` |
| QA passed | `/phase-summary` | `docs/reports/phase1/phase-summary.md` |
| Arch decision | inside `/done` | `docs/decisions/{date}-{title}.md` |
| Bug found | inside `/done` or anytime | `docs/bugs/{date}-{slug}.md` |

Templates: `.claude/templates/` — feature-report, qa-report, phase-summary, adr, bug-report

## Agents & Skills
- `/agent claude-architect` — orchestration, architecture ownership, final decision
- `/agent codex-implementer` — bounded implementation, tests, fast execution loops
- `/agent flutter-reviewer` — before PR merge (architecture + Riverpod + security)
- `/tdd` — starting a new feature or bug fix
## Done Criteria
1. `flutter analyze` clean; relevant tests pass
2. `.claude/memory.md` updated; feature report filed via `/done`
