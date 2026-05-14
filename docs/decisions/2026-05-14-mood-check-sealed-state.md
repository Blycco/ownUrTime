---
date: 2026-05-14
status: accepted
task: 05-feature-mood
---

# ADR: MoodCheckNotifier sealed state로 세션 타이밍 관리

## Context
Mood check는 "당일 첫 세션 전에만 표시, 이후 세션에는 미표시, 세션 완료 후에는 표시"라는 타이밍 룰이 필요하다. Phase 1에서 Supabase가 없으므로 날짜 기반 persistence 없이 이를 구현해야 한다.

## Decision
`@Riverpod(keepAlive: true)` Notifier가 `sealed MoodCheckState {pending | done(suggestedMinutes?)}` 두 상태만 관리한다. `pending → done` 전이는 앱 세션 동안 유지되어 2번째 세션 idle 시 mood widget이 자동으로 숨겨진다.

## Consequences
- Easier: 날짜 비교 로직 불필요, 상태 전이만으로 타이밍 룰 충족
- Harder: 앱 재시작 시 state 초기화 → 매 실행마다 mood check 표시됨 (Phase 1 허용)

## Alternatives Considered
| Option | Why Rejected |
|--------|--------------|
| session_provider에 `_hasMoodCheckedToday` 플래그 추가 | timer_provider 책임 비대화, 단일책임 원칙 위반 |
| `getTodayMoodChecksUseCase`로 오늘 체크 여부 async 초기화 | Phase 1 in-memory에서 오버엔지니어링; Phase 2에서 추가 |
| SharedPreferences로 날짜 persist | Phase 1 의존성 추가 불필요 |
