---
date: 2026-05-13
status: accepted
task: 02-feature-task
---

# ADR: Phase 1 InMemory DataSource 수직 슬라이스 전략

## Context

Task feature 구현 시 Supabase 연결 전에 UI/UX 흐름을 검증해야 했다. RemoteDataSource를 먼저 구현하면 Supabase 스키마 변경과 UI 개발이 강하게 결합되어 반복 속도가 떨어진다.

## Decision

Phase 1에서 `InMemoryTaskDataSource`를 primary datasource로 사용하고, `TaskRemoteDataSource`는 인터페이스만 정의한 stub으로 유지한다. AI limit counter도 client-side InMemory로 구현하되, 실제 권위 있는 rate limit은 Supabase Edge Function에서 처리한다.

## Consequences

- Easier: UI/UX 흐름을 Supabase 없이 즉시 검증 가능. 네트워크 없이 테스트 실행.
- Harder: 앱 재시작 시 데이터 소실. AI counter가 ProviderScope 수명에 묶임. Phase 2에서 RemoteDataSource 교체 시 인터페이스 일치 여부 재검증 필요.

## Alternatives Considered

| Option | Why Rejected |
|--------|--------------|
| Phase 1부터 Supabase 직접 연결 | UI 개발과 스키마 변경이 결합 → 속도 저하. Phase 1 목표는 UX 검증 |
| MockDataSource (테스트용 fake) | 앱 실행 불가. 실제 상태 관리 검증 안 됨 |
