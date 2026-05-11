# OwnUrTime

External scaffolding app for adults with ADHD traits.  
Focus: initiation (2-min micro-start), maintenance (flexible session timer), recovery (1-tap re-entry).

## Tech Stack
- Flutter (iOS/macOS first)
- Riverpod (state)
- Supabase (Auth/DB/Realtime/Edge Functions)

## Quick Start
```bash
flutter pub get
flutter analyze
flutter test
```

## Project Conventions
- Feature-first structure: `lib/features/{feature}/{data,domain,presentation}/`
- Supabase calls only in `data/datasources/`
- Riverpod only (no BLoC/Provider/GetX)
- No hardcoded Korean strings (use ARB)

## Agent Workflow
- Orchestrator: Claude Code (`CLAUDE.md`)
- Implementer: Codex (`AGENTS.md`)
- Delegation command: `.claude/commands/codex.md`

## Core Docs
- Project rules and orchestration: `CLAUDE.md`
- Codex execution boundaries: `AGENTS.md`
- Feature/architecture context: `.claude/context/`
- Phase tasks: `.claude/tasks/phase1/`
