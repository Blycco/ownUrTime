---
phase: 1
date: {YYYY-MM-DD}
prepared-by: Claude Code + flutter-reviewer
status: PASS | FAIL | CONDITIONAL
---

# QA Report — Phase 1

## Checklist
- [ ] flutter analyze — zero warnings
- [ ] flutter test --coverage — ≥80% domain/ + data/
- [ ] All 10 feature reports filed (docs/reports/phase1/features/)
- [ ] No secrets in lib/ (`grep -rn "sk-\|apiKey.*=" --include="*.dart" lib/` → 0 results)
- [ ] No hardcoded Korean strings in lib/ (`grep -r '"지금\|"잠깐\|"집중' lib/` → 0 results)
- [ ] Guest mode: full flow without login
- [ ] Sign-in prompt appears after exactly 3rd session
- [ ] Layer-1 reward fires on every session completion
- [ ] iCloud backup file appears in Files app after session complete
- [ ] All 5 PostHog events visible in dev dashboard within 30s

## Test Results
```
(paste: flutter test --coverage output)
```

## flutter analyze
```
(paste: flutter analyze output)
```

## flutter-reviewer Findings
| Severity | File | Issue |
|----------|------|-------|
| | | |

## Manual Test: Golden Path
> Guest → Mood → Task (2-min start) → Session → Distraction → Recovery → Reward → Session Complete

| Step | Result | Notes |
|------|--------|-------|
| App launch (no login screen) | | |
| Mood check (5-level emoji) | | |
| Task creation — 1-tap start | | |
| AI decomposition (3 steps) | | |
| AI limit message at 10/day | | |
| Session timer — 3 resets max | | |
| Session timer — +1 min extend | | |
| Distraction button → type selection | | |
| Context restore card → 1-tap re-entry | | |
| Session complete + reward animation | | |
| Sound plays on completion | | |
| Sign-in prompt after 3rd session | | |
| "Maybe later" dismisses without login | | |
| iCloud backup file created | | |

## Known Issues
| ID | Severity | Description | Resolution |
|----|----------|-------------|------------|
| | | | |

## QA Decision
**Status**: PASS / FAIL / CONDITIONAL PASS
**Conditional conditions** (if applicable): ...
**Next**: Submit TestFlight / Fix issues and re-QA
