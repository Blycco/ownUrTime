---
date: 2026-05-15
status: accepted
task: 09-analytics
---

# ADR: Analytics 이벤트를 ViewModel(TimerNotifier) 레이어에서 발화

## Context
KPI 이벤트 5개(initiation_conversion, session_completed, session_distracted, recovery_returned, day_2_return)를
어느 레이어에서 발화할지 결정이 필요했다. 태스크 파일은 UseCase 레이어 연결을 제안했으나,
`recovery_returned` 이벤트는 대응 UseCase가 없고, `session_distracted`의 `minutes_into_session`과
`recovery_returned`의 `recovery_seconds`는 타이머 실행 시간 기반 계산이 필요해 UseCase에서 접근 불가했다.

## Decision
모든 세션 관련 KPI 이벤트를 `TimerNotifier` (ViewModel 레이어)에서 발화한다.

## Consequences
- Easier: 타이머 상태(`remaining`, `_lastDistractionAt`, `_targetDuration`)에 직접 접근 가능 — recovery_seconds 계산 가능
- Easier: UseCase에 analytics 의존성 주입 불필요 — 도메인 레이어 순수성 유지
- Harder: TimerNotifier의 책임이 늘어남 — 향후 이벤트가 많아지면 별도 analytics observer 패턴 고려 필요

## Alternatives Considered

| Option | Why Rejected |
|--------|--------------|
| UseCase 레이어 발화 | `recovery_returned`에 대응 UseCase 없음; `minutes_into_session`·`recovery_seconds` 타이머 상태 접근 불가 |
| Repository/DataSource 레이어 발화 | 데이터 레이어에 UI 맥락(타이밍, 세션 진행 상태) 없음 |
| 별도 analytics middleware/observer | MVP 복잡도 과다; Phase 2 이벤트 수 증가 시 재검토 |
