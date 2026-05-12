---
date: 2026-05-12
status: accepted
task: 00-project-init
---

# ADR: Riverpod 3.x — StateProvider 대신 NotifierProvider 사용

## Context
`log_context_provider.dart`에서 `userId`, `sessionId`를 mutable 상태로 저장하기 위해 `StateProvider<String?>`를 사용하려 했으나, 설치된 Riverpod 3.x (`flutter_riverpod 3.3.1`)에서 `StateProvider`가 완전히 제거되어 컴파일 에러 발생.

## Decision
`StateProvider` 대신 `NotifierProvider<T, State>`를 사용한다. 각 상태 값마다 `Notifier<State>` 서브클래스를 선언하고 `.state` setter로 업데이트한다.

## Consequences
- Easier: Riverpod 3.x 공식 패턴 준수, `@riverpod` 코드 생성과도 일관됨
- Harder: 단순 값 하나에도 Notifier 클래스 2개 선언 필요 (LogUserIdNotifier, LogSessionIdNotifier) — 보일러플레이트 소폭 증가

## Alternatives Considered
| Option | Why Rejected |
|--------|--------------|
| `StateProvider` 유지 | Riverpod 3.x에서 API 제거됨 — 컴파일 불가 |
| `@riverpod` 어노테이션으로 생성 | build_runner 첫 실행 전까지 생성 파일 없으므로 Task 00에서 사용 불가 |
| `ProviderContainer`로 직접 상태 보관 | Riverpod 패턴 벗어남, ref 없이 읽기 복잡 |
