# OwnUrTime — CLAUDE.md
> Auto-loaded every session. Keep under 120 lines. Details in `.claude/context/`.

---

## Project Overview
External Scaffolding app for adults with ADHD ("착수·유지·복귀" — initiation, maintenance, recovery).
- **Stage**: MVP (Phase 1) | **Platform**: iPhone + Mac first → iPad → Android → Windows → Web
- **Market**: Korea launch first | **Developer**: Solo
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
| Agent | Tool | Owns |
|-------|------|------|
| **Claude Code** | direct | Architecture, interfaces, security/RLS, final PR |
| **Codex** | `codex exec "..."` | Implementation, tests, boilerplate, code review |
| **Gemini** | `gemini -p "..."` | Research, doc lookup, tech comparisons |

> Details → `.claude/rules/codex-gemini-workflow.md`

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
RULE 10  Widget/unit tests required; build gate before merge: flutter build ios + macos --debug (when toolchain available)
RULE 11  ADHD UX: minimize initiation barrier, no forced input, first action = 1 tap
RULE 12  Guest mode first — no forced login before 3rd session completion
RULE 13  i18n structure from Phase 1 — actual translations in Phase 4
RULE 14  Read relevant .claude/context/ files before starting any task
RULE 15  Plan Mode required — run /plan before writing any code
RULE 16  Codex-labeled task items: generate /codex prompt first, no implementation before Codex runs
```

---

## Branch & Commit Rules
`main` ← `develop` ← `feat/fix/chore/*` (Claude Code on feat/fix/chore only; direct commits to develop/main prohibited)
`hotfix/*` branches from `main`, merges to both `main` + `develop`.

Commit format: `Feat/Fix/Perf/Refactor/Test/Docs/Chore: 한국어 요약`
- One commit per coherent objective; no micro-commits; no `Co-Authored-By:` line; `Ref: #{issue}` 필수

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

## Design & Test Documents
| Change type | Update target |
|------------|--------------|
| DB schema change (table/column/RLS/index) | `docs/04_design/db-design.md` |
| Edge Function add/change | `docs/04_design/api-spec.md` |
| System architecture change | `docs/04_design/architecture.md` |
| Task completion | Add `docs/05_test_results/integration/{NN}-{name}.md` |

## Agents & Skills
- `/agent claude-architect` — orchestration, architecture ownership, final decision
- `/agent codex-implementer` — bounded implementation, tests, fast execution loops
- `/agent flutter-reviewer` — before PR merge (architecture + Riverpod + security)
- `/tdd` — starting a new feature or bug fix
## Done Criteria
`flutter analyze` clean → tests pass → flutter-reviewer → user approval → commit
> Full order → `.claude/rules/process-workflow.md`
