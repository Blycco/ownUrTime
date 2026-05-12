---
task: 01-supabase-schema
phase: 1
date: 2026-05-12
agent: Claude Code
status: complete
---

# Feature Report: Supabase 스키마 + RLS + Edge Function

## Summary

PostgreSQL 5개 테이블(user_profiles, tasks, sessions, distractions, mood_checks)과 RLS 정책을 구축하고, Gemini 2.5 Flash를 호출해 태스크를 3단계로 분해하는 Edge Function `decompose-task`를 구현했다. 보안 리뷰(flutter-reviewer) 결과 HIGH 7개, MEDIUM 5개를 발견해 모두 수정 완료했다.

## Architecture Decisions

- Decision: rate limit을 `tasks.decomposed_steps` 카운트 대신 서버 전용 `ai_usage_log` 테이블로 이동 | Reason: 클라이언트가 저장 안 하면 rate limit 우회 가능 — 서비스 롤 클라이언트만 INSERT 허용
- Decision: `user_profiles` UPDATE RLS 제거 → `update_user_profile()` / `increment_session_count()` SECURITY DEFINER 함수로 대체 | Reason: RLS만으로는 컬럼 단위 제한 불가 — 클라이언트가 `session_count`를 임의 조작하는 것을 막기 위해
- Decision: Gemini API key를 URL 쿼리 파라미터 → `x-goog-api-key` 헤더로 이동 | Reason: 쿼리 파라미터는 프록시·서버 로그에 노출 가능
- Decision: `gemini-2.0-flash` → `gemini-2.5-flash` | Reason: 2.0은 AI Studio 무료 할당량 `limit: 0`으로 실사용 불가

## Implementation Notes

- `supabase functions serve`는 `SUPABASE_SERVICE_ROLE_KEY`를 자동으로 주입 — `.env`에 별도 추가 불필요
- 마이그레이션 파일명은 14자리 타임스탬프 필수 (`20260511000001_*.sql`). 날짜만 쓰면 버전 충돌로 `db reset` 실패
- `gemini-2.5-flash`는 한국어 응답 시 `maxOutputTokens: 200` 부족 — 500으로 증가 필요
- `distractions_insert` RLS의 session_id 소유권 검증: `UPDATE` 정책에도 동일 서브쿼리 적용 필요 (INSERT만 고치면 UPDATE로 우회 가능)
- Fetch AbortController 10초 timeout 추가 — Deno `fetch`는 기본 timeout 없음

## Test Coverage

| Layer | Coverage |
|-------|----------|
| SQL migrations | 수동 검증 — `supabase db reset` 7개 마이그레이션 전체 적용 |
| Edge Function | curl 엔드투엔드 테스트 통과 (JWT 인증 → rate limit → Gemini → ai_usage_log 기록) |
| Flutter (domain/data/presentation) | 해당 없음 — Task 01은 백엔드 전용 |

## Known Limitations / Tech Debt

- [ ] `updated_at` 컬럼 없음 — Realtime 연결 시 필요 (Phase 2)
- [ ] `user_profiles` 자동 생성 트리거 없음 — 가입 후 profile INSERT 실패 시 고아 유저 발생 가능 (Phase 2)
- [ ] `supabase-js@2` esm.sh 버전 미핀 — `deno.json` 추가로 재현성 보장 필요
- [ ] CI Flutter 버전 미핀 (`channel: stable`) + `flutter pub audit` 미적용
- [ ] `mood_checks` UPDATE RLS — PIPA 감도 데이터 수정 가능, 향후 SECURITY DEFINER 함수로 대체 권장
- [ ] `distraction_count` 상한 제약 없음 (Task 03 세션 화면 구현 시 결정)
- [ ] H2 rate limit: `ai_usage_log`에 INSERT하기 전 Gemini 호출이 실패하면 사용량 기록 안 됨 (장애 시 무료 통과) — 허용 가능한 트레이드오프

## Key Files

- `supabase/migrations/20260511000001_user_profiles.sql` ~ `20260511000005_mood_checks.sql`
- `supabase/migrations/20260512000001_add_constraints.sql`
- `supabase/migrations/20260512000002_security_fixes.sql`
- `supabase/functions/decompose-task/index.ts`
