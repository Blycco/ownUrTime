---
date: 2026-05-18
status: accepted
task: 00-appstore-blockers
---

# ADR: deleteAccount 오류 흐름 — AsyncError + rethrow

## Context

`AuthNotifier`의 다른 비동기 액션(`signOut`, `signInWithApple`)은 예외 발생 시 복구 가능한 상태(`AsyncData(AuthState.guest())`)로 전환한 뒤 예외를 재던진다. `deleteAccount()`는 같은 패턴을 쓸 수 없다: 삭제 실패 시 "인증 상태"인지 "삭제 중 실패"인지 불명확하여 `AuthState.authenticated`로 복원하는 것이 부정확하다.

또한 첫 구현에서 `catch` 후 `rethrow`를 누락해 `DeleteAccountDialog._onDelete()`의 `catch(e)` 블록이 실행되지 않았고 — 실패 시 `_loading`이 `true`로 영구 고착되는 HIGH 버그가 발생했다.

## Decision

`deleteAccount()` catch 블록에서 `state = AsyncError(e, st)` 설정 후 `rethrow`한다. 위젯이 try/catch로 직접 에러를 처리하고, provider는 AsyncError 상태를 노출한다.

## Consequences

- Easier: 위젯이 실패를 직접 catch해 스낵바 표시 및 `_loading` 초기화 가능
- Easier: AsyncError 상태를 listen하는 다른 위젯도 에러를 감지 가능
- Harder: 호출부가 예외를 반드시 처리해야 함 (unhandled exception 주의)

## Alternatives Considered

| Option | Why Rejected |
|--------|--------------|
| 실패 시 `AsyncData(AuthState.authenticated)` 복원 후 rethrow | 삭제 시도 중 실패한 계정의 상태가 불명확 — 서버에서 일부 삭제됐을 수도 있음 |
| `AsyncError`만 설정, rethrow 없음 | 위젯 catch 블록 미실행 → _loading 영구 잠금 버그 (실제로 발생) |
| 위젯에서 `authProvider` 상태 변화를 watch | 위젯 복잡도 증가, 기존 패턴(try/catch on notifier method)과 불일치 |
