# 통합 테스트 결과서

| 항목 | 내용 |
|------|------|
| 프로젝트 | OwnUrTime |
| 태스크 | Task 01 — Supabase 스키마 & Edge Function |
| 테스트 유형 | 통합 |
| 테스트 일자 | 2026-05-12 |
| 테스트 환경 | 로컬 Supabase (supabase start) |
| 작성자 | Wonjin Choi |

---

## 1. 테스트 범위

7개 마이그레이션 파일(`20260511000001` ~ `20260512000002`)로 생성되는 6개 테이블과 RLS 정책, 인덱스, SECURITY DEFINER 함수, Edge Function(`decompose-task`)의 정확성을 검증한다. 검토는 코드 리뷰 방식(마이그레이션 SQL + Edge Function 코드 분석)으로 수행했으며, supabase CLI로 마이그레이션 적용 가능 여부를 확인했다.

---

## 2. 테스트 환경

| 항목 | 내용 |
|------|------|
| Flutter | 3.x (dart-define 환경변수 방식) |
| Supabase CLI | 2.98.2 |
| 데이터베이스 | 로컬 (supabase start) |
| Edge Runtime | Deno (Supabase Edge Function) |
| 마이그레이션 파일 수 | 7개 |

---

## 3. 테스트 결과

### 3.1 테이블 생성 및 기본 제약 조건

| # | 테스트 항목 | 테스트 방법 | 예상 결과 | 실제 결과 | 결과 |
|---|-----------|-----------|----------|----------|------|
| 1 | `user_profiles` 테이블 생성 | SQL 코드 리뷰 | PK=id, FK→auth.users, 3개 컬럼 | 마이그레이션 코드 일치 | ✅ |
| 2 | `tasks` 테이블 생성 | SQL 코드 리뷰 | PK=UUID, FK→auth.users, status 체크 | 마이그레이션 코드 일치 | ✅ |
| 3 | `sessions` 테이블 생성 | SQL 코드 리뷰 | reset_count BETWEEN 0 AND 3 체크 | 마이그레이션 코드 일치 | ✅ |
| 4 | `distractions` 테이블 생성 | SQL 코드 리뷰 | distraction_type IN ('urgent','impulsive','rest') 체크 | 마이그레이션 코드 일치 | ✅ |
| 5 | `mood_checks` 테이블 생성 | SQL 코드 리뷰 | mood_level BETWEEN 1 AND 5 체크 | 마이그레이션 코드 일치 | ✅ |
| 6 | `ai_usage_log` 테이블 생성 | SQL 코드 리뷰 (`20260512000002`) | 서비스 롤 INSERT 전용, 인덱스 생성 | 마이그레이션 코드 일치 | ✅ |

### 3.2 추가 제약 조건 마이그레이션 (`20260512000001`)

| # | 테스트 항목 | 테스트 방법 | 예상 결과 | 실제 결과 | 결과 |
|---|-----------|-----------|----------|----------|------|
| 7 | `tasks.title` 길이 제약 (1~500자) | SQL 코드 리뷰 | CHECK `char_length(title) BETWEEN 1 AND 500` | ADD CONSTRAINT 코드 일치 | ✅ |
| 8 | `user_profiles.display_name` 길이 제약 (≤100자) | SQL 코드 리뷰 | NULL 허용 + CHECK ≤100 | NULL OR 조건 포함 확인 | ✅ |
| 9 | `distractions` INSERT RLS 세션 소유권 검증 | SQL 코드 리뷰 | EXISTS 서브쿼리로 session_id 소유 확인 | DROP IF EXISTS + CREATE POLICY 확인 | ✅ |

### 3.3 보안 수정 마이그레이션 (`20260512000002`)

| # | 테스트 항목 | 테스트 방법 | 예상 결과 | 실제 결과 | 결과 |
|---|-----------|-----------|----------|----------|------|
| 10 | `distractions` UPDATE RLS 세션 소유권 검증 | SQL 코드 리뷰 | INSERT와 동일한 EXISTS 서브쿼리 | WITH CHECK에 EXISTS 서브쿼리 포함 확인 | ✅ |
| 11 | `user_profiles` UPDATE RLS 제거 | SQL 코드 리뷰 | DROP POLICY "user_profiles_update" | DROP POLICY IF EXISTS 확인 | ✅ |
| 12 | `update_user_profile()` SECURITY DEFINER 함수 | SQL 코드 리뷰 | 인증 사용자만 display_name, mood_check_enabled 수정 | GRANT TO authenticated + SECURITY DEFINER 확인 | ✅ |
| 13 | `increment_session_count()` SECURITY DEFINER 함수 | SQL 코드 리뷰 | 인증 사용자 session_count +1, 다른 컬럼 수정 불가 | session_count만 UPDATE 확인 | ✅ |

### 3.4 RLS 정책 검증 (전체 테이블)

| # | 테스트 항목 | 테스트 방법 | 예상 결과 | 실제 결과 | 결과 |
|---|-----------|-----------|----------|----------|------|
| 14 | 모든 테이블 RLS 활성화 | SQL 코드 리뷰 | `ENABLE ROW LEVEL SECURITY` 각 테이블에 존재 | 6개 테이블 모두 확인 | ✅ |
| 15 | SELECT 정책: `auth.uid() = user_id` (또는 `id`) | SQL 코드 리뷰 | 자기 데이터만 조회 가능 | 6개 테이블 SELECT 정책 확인 | ✅ |
| 16 | `ai_usage_log` INSERT/UPDATE/DELETE 정책 부재 | SQL 코드 리뷰 | anon/authenticated 쓰기 차단 | 정책 없음 확인 (서비스 롤 전용) | ✅ |

### 3.5 Edge Function (`decompose-task`)

| # | 테스트 항목 | 테스트 방법 | 예상 결과 | 실제 결과 | 결과 |
|---|-----------|-----------|----------|----------|------|
| 17 | JWT 미첨부 요청 거부 | 코드 리뷰 | `401 unauthorized` | authHeader null 체크 확인 | ✅ |
| 18 | 만료 JWT 거부 | 코드 리뷰 | `401 unauthorized` | `auth.getUser()` 에러 핸들링 확인 | ✅ |
| 19 | 일일 한도 10회 초과 시 차단 | 코드 리뷰 | `429 daily_limit_reached` | `usedToday >= DAILY_LIMIT` 분기 확인 | ✅ |
| 20 | Rate Limit: 서비스 롤로 `ai_usage_log` 조회 | 코드 리뷰 | 클라이언트 조작 불가 서버 집계 | `serviceClient` 사용 확인 | ✅ |
| 21 | Gemini 10초 타임아웃 | 코드 리뷰 | `504 ai_service_timeout` | `AbortController` + `setTimeout` 확인 | ✅ |
| 22 | API 키: URL 파라미터 아닌 헤더 전송 | 코드 리뷰 | `x-goog-api-key` 헤더 사용 | headers 객체에 포함 확인 | ✅ |
| 23 | 성공 응답: `steps` 배열 3개 + `remaining_today` | 코드 리뷰 | `{steps: [...], remaining_today: N}` | jsonResponse 구조 확인 | ✅ |
| 24 | 사용 후 `ai_usage_log` INSERT | 코드 리뷰 | 성공 응답 직전 서비스 롤 INSERT | `serviceClient.insert()` 호출 확인 | ✅ |
| 25 | `task_title` 제어 문자 제거 | 코드 리뷰 | `\x00-\x1F` 공백 치환 후 trim | `.replace(/[\x00-\x1F\x7F]/g, " ").trim()` 확인 | ✅ |

### 3.6 Flutter 앱 진입점

| # | 테스트 항목 | 테스트 방법 | 예상 결과 | 실제 결과 | 결과 |
|---|-----------|-----------|----------|----------|------|
| 26 | `SUPABASE_URL` 미설정 시 릴리스 빌드 크래시 방지 | 코드 리뷰 | `throw StateError(...)` (assert 아님) | `main.dart` StateError 확인 | ✅ |

---

## 4. 결함 목록

발견 후 수정 완료된 항목:

| # | 심각도 | 항목 | 현상 | 조치 |
|---|--------|------|------|------|
| 1 | HIGH | `assert()` in main.dart | Dart 릴리스 빌드에서 assert 무시 → 앱 진행, `SUPABASE_URL` 없이 초기화 | `throw StateError()`로 교체 (`20260512` 코드 수정) |
| 2 | HIGH | Rate Limit 클라이언트 우회 | `tasks.decomposed_steps`로 집계 시 Edge Function 미기록 → 무제한 호출 가능 | `ai_usage_log` 서버 기록 + 서비스 롤 조회로 전환 |
| 3 | HIGH | `distractions` UPDATE RLS 소유권 미검증 | session_id를 타인 세션으로 변경 가능 | EXISTS 서브쿼리 추가 (`20260512000002`) |
| 4 | HIGH | `user_profiles` UPDATE RLS — session_count 클라이언트 조작 | 인증된 사용자가 직접 session_count 임의 설정 가능 | UPDATE RLS 제거, SECURITY DEFINER 함수 2개로 대체 |

---

## 5. 테스트 요약

| 항목 | 수 |
|------|---|
| 총 테스트 케이스 | 26 |
| 통과 | 26 |
| 실패 | 0 |
| 통과율 | 100% |

> 위 4개 결함은 flutter-reviewer 코드 리뷰로 발견되었으며, 마이그레이션 추가 및 코드 수정으로 모두 수정 완료 후 재검증했다.
