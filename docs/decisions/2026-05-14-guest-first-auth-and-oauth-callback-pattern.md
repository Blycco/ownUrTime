---
date: 2026-05-14
status: accepted
task: 06-feature-auth
---

# ADR: Guest-First Auth + OAuth Callback via onAuthStateChange

## Context

Phase 1은 ADHD 사용자의 착수 장벽 최소화(RULE 11, 12)가 최우선이다. Apple Sign In은 App Store 정책상 필수이지만, 회원가입 강요 자체가 이탈 요인이 된다. 또한 `supabase.auth.signInWithOAuth()`는 외부 브라우저를 열고 즉시 반환하므로 콜백 도착 전에 `currentUser`를 읽으면 항상 null이다.

## Decision

세션 3회 완료 전까지 모든 기능을 로그인 없이 제공하고, OAuth 콜백은 `onAuthStateChange` 스트림 + `Completer`로 대기한다.

## Consequences

- **Easier**: 초기 사용자 마찰 제거, 앱 스토어 정책 준수, 실제 Apple Sign In 동작 보장
- **Harder**: 게스트 데이터 마이그레이션 로직 필요, `TimerNotifier`의 userId 관리가 Phase 2에 복잡해짐 (현재 'guest' 고정)

## Alternatives Considered

| Option | Why Rejected |
|--------|--------------|
| 앱 첫 실행 시 즉시 로그인 | ADHD 착수 장벽 — 로그인 전에 가치를 먼저 보여줘야 함 |
| `currentUser` 즉시 읽기 | OAuth는 redirect 기반 — 콜백 도착 전 항상 null |
| `Future.delayed` 폴링 | 비결정적 타이밍, race condition 불가피 |
| 별도 deep link 핸들러에서 signIn 완료 | Supabase Flutter SDK가 이미 내부적으로 처리하므로 중복 |
