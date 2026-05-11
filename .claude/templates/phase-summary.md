---
phase: 1
date: {YYYY-MM-DD}
testflight-build: {number}
qa-report: docs/reports/phase1/qa-report.md
status: complete
---

# Phase 1 Summary — OwnUrTime

## What Shipped
- **Project Init**: Flutter project, Supabase connection, theme, GoRouter
- **Supabase Schema**: 5 tables with RLS, Edge Function (Gemini Flash 2.0 decompose-task)
- **Task Feature**: CRUD, 2-min micro-start, AI decomposition (10/day limit)
- **Session Feature**: Flexible timer (10/15/25+custom), 3 resets, +1 min extend
- **Recovery Feature**: 3 distraction types, context restore card, 1-tap re-entry
- **Mood Check**: 5-level emoji, auto-suggest session length (≤2 → 10 min)
- **Auth**: Guest mode first, Apple Sign In prompt after 3rd session, local→Supabase sync
- **Reward**: Layer-1 sound + animation on every session completion
- **i18n + Backup**: ARB structure (ko/en), iCloud Drive backup on session complete
- **Analytics**: PostHog, 5 KPI events wired

## ADR Index
| File | Decision |
|------|----------|
| docs/decisions/... | |

## Tech Debt Carried Forward to Phase 2
- [ ] ...

## Phase 1 KPI Targets (PostHog Baseline — measure from Week 1)
| KPI | Target | How Measured |
|-----|--------|--------------|
| initiation_conversion | ≥60% | app_open → 2-min start tapped, first-week cohort |
| session_completed rate | ≥50% | sessions started vs. completed |
| day_2_return | ≥40% | users who return day after first session |
| recovery_returned rate | ≥70% | distractions that result in re-entry |

## TestFlight
- Build: {number}
- Submitted: {date}
- Internal testers: {count}
- Feedback summary: (fill after internal test period)

## Lessons for Phase 2
<!-- What to do differently — process, architecture, UX -->
