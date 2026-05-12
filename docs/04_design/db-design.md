# 데이터베이스 설계서

| 항목 | 내용 |
|------|------|
| 프로젝트 | OwnUrTime |
| 버전 | v1.0 |
| 작성일 | 2026-05-12 |
| 작성자 | Wonjin Choi |
| 상태 | 확정 (Phase 1) |

---

## 1. 개요

OwnUrTime의 핵심 데이터 구조를 정의한다. 모든 테이블은 Supabase PostgreSQL (`public` 스키마)에 위치하며, Row Level Security(RLS)를 전체 활성화해 사용자 간 데이터 격리를 보장한다.

**인증**: Supabase Auth (`auth.users` 테이블). 모든 RLS 정책은 `auth.uid()`로 현재 사용자를 식별한다.

---

## 2. 테이블 목록

| 테이블명 | 설명 | 마이그레이션 |
|---------|------|------------|
| user_profiles | 사용자 프로필 및 설정 | 20260511000001 |
| tasks | 사용자 태스크 (할 일) | 20260511000002 |
| sessions | 집중 세션 | 20260511000003 |
| distractions | 세션 중 분산 기록 | 20260511000004 |
| mood_checks | 기분 체크 기록 | 20260511000005 |
| ai_usage_log | AI 기능 사용량 추적 (서버 전용) | 20260512000002 |

---

## 3. 테이블 명세

### 3.1 user_profiles

**설명**: 회원가입 시 생성되는 사용자 프로필. `auth.users`와 1:1 관계.

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 설명 |
|--------|-----------|----------|--------|------|
| id | UUID | NOT NULL | — | PK, `auth.users.id` 참조 |
| display_name | TEXT | NULL | — | 표시 이름 (최대 100자) |
| mood_check_enabled | BOOLEAN | NOT NULL | true | 기분 체크 알림 활성화 여부 |
| session_count | INTEGER | NOT NULL | 0 | 완료된 세션 수 (게스트→인증 임계값 판단용) |
| created_at | TIMESTAMPTZ | NOT NULL | NOW() | 생성 일시 |

**제약 조건**
- PK: `id`
- FK: `id` → `auth.users.id` (ON DELETE CASCADE)
- CHECK: `char_length(display_name) <= 100`

**RLS 정책**

| 정책명 | 작업 | 조건 |
|--------|------|------|
| user_profiles_select | SELECT | `auth.uid() = id` |
| user_profiles_insert | INSERT | `auth.uid() = id` |
| user_profiles_delete | DELETE | `auth.uid() = id` |

> ⚠️ UPDATE 정책 없음. 프로필 수정은 `update_user_profile()` RPC 함수, 세션 수 증가는 `increment_session_count()` RPC 함수를 통해서만 가능 (클라이언트 직접 수정 차단).

**RPC 함수**
- `update_user_profile(p_display_name, p_mood_check_enabled)` — SECURITY DEFINER, `authenticated` 호출 가능
- `increment_session_count()` — SECURITY DEFINER, `authenticated` 호출 가능

---

### 3.2 tasks

**설명**: 사용자가 생성한 태스크. AI 분해 결과(`decomposed_steps`)를 JSONB로 저장.

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 설명 |
|--------|-----------|----------|--------|------|
| id | UUID | NOT NULL | gen_random_uuid() | PK |
| user_id | UUID | NOT NULL | — | FK → `auth.users.id` |
| title | TEXT | NOT NULL | — | 태스크 제목 (1~500자) |
| decomposed_steps | JSONB | NULL | — | AI 분해 결과 `["step1","step2","step3"]` |
| status | TEXT | NOT NULL | 'pending' | 태스크 상태 |
| created_at | TIMESTAMPTZ | NOT NULL | NOW() | 생성 일시 |
| started_at | TIMESTAMPTZ | NULL | — | 세션 시작 일시 |
| completed_at | TIMESTAMPTZ | NULL | — | 완료 일시 |

**제약 조건**
- PK: `id`
- FK: `user_id` → `auth.users.id` (ON DELETE CASCADE)
- CHECK: `status IN ('pending', 'in_progress', 'completed', 'abandoned')`
- CHECK: `char_length(title) BETWEEN 1 AND 500`

**RLS 정책**

| 정책명 | 작업 | 조건 |
|--------|------|------|
| tasks_select | SELECT | `auth.uid() = user_id` |
| tasks_insert | INSERT | `auth.uid() = user_id` |
| tasks_update | UPDATE | `auth.uid() = user_id` |
| tasks_delete | DELETE | `auth.uid() = user_id` |

**인덱스**

| 인덱스명 | 컬럼 | 타입 | 비고 |
|---------|------|------|------|
| idx_tasks_user_id | user_id | BTREE | |
| idx_tasks_user_decomposed_at | (user_id, created_at) | BTREE | `WHERE decomposed_steps IS NOT NULL` — AI 사용량 조회 최적화 |

---

### 3.3 sessions

**설명**: 사용자의 집중 세션. 태스크와 연결되며 타이머, 분산, 리셋 정보를 기록.

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 설명 |
|--------|-----------|----------|--------|------|
| id | UUID | NOT NULL | gen_random_uuid() | PK |
| user_id | UUID | NOT NULL | — | FK → `auth.users.id` |
| task_id | UUID | NULL | — | FK → `tasks.id` (연결 태스크) |
| target_duration_minutes | INTEGER | NOT NULL | — | 목표 집중 시간 (분) |
| status | TEXT | NOT NULL | 'active' | 세션 상태 |
| distraction_count | INTEGER | NOT NULL | 0 | 분산 발생 횟수 |
| reset_count | INTEGER | NOT NULL | 0 | 타이머 리셋 횟수 (최대 3) |
| manual_work_mode | BOOLEAN | NOT NULL | false | 수동 작업 모드 여부 |
| started_at | TIMESTAMPTZ | NOT NULL | NOW() | 세션 시작 일시 |
| completed_at | TIMESTAMPTZ | NULL | — | 세션 종료 일시 |

**제약 조건**
- PK: `id`
- FK: `user_id` → `auth.users.id` (ON DELETE CASCADE)
- FK: `task_id` → `tasks.id` (ON DELETE SET NULL)
- CHECK: `target_duration_minutes > 0`
- CHECK: `status IN ('active', 'completed', 'abandoned')`
- CHECK: `distraction_count >= 0`
- CHECK: `reset_count BETWEEN 0 AND 3`

**RLS 정책**

| 정책명 | 작업 | 조건 |
|--------|------|------|
| sessions_select | SELECT | `auth.uid() = user_id` |
| sessions_insert | INSERT | `auth.uid() = user_id` |
| sessions_update | UPDATE | `auth.uid() = user_id` |
| sessions_delete | DELETE | `auth.uid() = user_id` |

**인덱스**

| 인덱스명 | 컬럼 | 타입 | 비고 |
|---------|------|------|------|
| idx_sessions_user_id | user_id | BTREE | |
| idx_sessions_task_id | task_id | BTREE | |

---

### 3.4 distractions

**설명**: 세션 중 발생한 분산(방해) 이벤트 기록. 유형별 분류 및 복귀 시간 추적.

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 설명 |
|--------|-----------|----------|--------|------|
| id | UUID | NOT NULL | gen_random_uuid() | PK |
| session_id | UUID | NOT NULL | — | FK → `sessions.id` |
| user_id | UUID | NOT NULL | — | FK → `auth.users.id` |
| distraction_type | TEXT | NOT NULL | — | 분산 유형 |
| occurred_at | TIMESTAMPTZ | NOT NULL | NOW() | 분산 발생 일시 |
| returned_at | TIMESTAMPTZ | NULL | — | 복귀 일시 |

**제약 조건**
- PK: `id`
- FK: `session_id` → `sessions.id` (ON DELETE CASCADE)
- FK: `user_id` → `auth.users.id` (ON DELETE CASCADE)
- CHECK: `distraction_type IN ('urgent', 'impulsive', 'rest')`

> **distraction_type 정의**  
> `urgent` — 긴급 처리 필요 (전화, 급한 메시지)  
> `impulsive` — 충동적 이탈 (SNS, 다른 생각)  
> `rest` — 의도적 휴식

**RLS 정책**

| 정책명 | 작업 | 조건 |
|--------|------|------|
| distractions_select | SELECT | `auth.uid() = user_id` |
| distractions_insert | INSERT | `auth.uid() = user_id` AND session이 본인 소유 |
| distractions_update | UPDATE | `auth.uid() = user_id` AND session이 본인 소유 |
| distractions_delete | DELETE | `auth.uid() = user_id` |

> INSERT/UPDATE 시 `EXISTS (SELECT 1 FROM sessions s WHERE s.id = session_id AND s.user_id = auth.uid())` 서브쿼리로 session_id 소유권 검증.

**인덱스**

| 인덱스명 | 컬럼 | 타입 | 비고 |
|---------|------|------|------|
| idx_distractions_session_id | session_id | BTREE | |
| idx_distractions_user_id | user_id | BTREE | |

---

### 3.5 mood_checks

**설명**: 세션 전후 기분 체크 기록. PIPA 감도 데이터.

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 설명 |
|--------|-----------|----------|--------|------|
| id | UUID | NOT NULL | gen_random_uuid() | PK |
| user_id | UUID | NOT NULL | — | FK → `auth.users.id` |
| session_id | UUID | NULL | — | FK → `sessions.id` (세션 없이도 기록 가능) |
| mood_level | INTEGER | NOT NULL | — | 기분 수준 (1=매우 나쁨 ~ 5=매우 좋음) |
| checked_at | TIMESTAMPTZ | NOT NULL | NOW() | 기록 일시 |

**제약 조건**
- PK: `id`
- FK: `user_id` → `auth.users.id` (ON DELETE CASCADE)
- FK: `session_id` → `sessions.id` (ON DELETE SET NULL)
- CHECK: `mood_level BETWEEN 1 AND 5`

**RLS 정책**

| 정책명 | 작업 | 조건 |
|--------|------|------|
| mood_checks_select | SELECT | `auth.uid() = user_id` |
| mood_checks_insert | INSERT | `auth.uid() = user_id` |
| mood_checks_update | UPDATE | `auth.uid() = user_id` |
| mood_checks_delete | DELETE | `auth.uid() = user_id` |

> ⚠️ UPDATE 정책 존재 — 향후 PIPA 감도 데이터 보호 차원에서 UPDATE 제거 및 SECURITY DEFINER 함수 전환 검토 필요 (Tech Debt).

**인덱스**

| 인덱스명 | 컬럼 | 타입 | 비고 |
|---------|------|------|------|
| idx_mood_checks_user_id | user_id | BTREE | |
| idx_mood_checks_session_id | session_id | BTREE | `WHERE session_id IS NOT NULL` (partial) |

---

### 3.6 ai_usage_log

**설명**: AI 기능(decompose-task) 사용량 서버 기록. 클라이언트 write 불가 — 서비스 롤 전용.

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 설명 |
|--------|-----------|----------|--------|------|
| id | UUID | NOT NULL | gen_random_uuid() | PK |
| user_id | UUID | NOT NULL | — | FK → `auth.users.id` |
| function_name | TEXT | NOT NULL | 'decompose-task' | 호출된 Edge Function 이름 |
| called_at | TIMESTAMPTZ | NOT NULL | NOW() | 호출 일시 |

**제약 조건**
- PK: `id`
- FK: `user_id` → `auth.users.id` (ON DELETE CASCADE)

**RLS 정책**

| 정책명 | 작업 | 조건 |
|--------|------|------|
| ai_usage_select | SELECT | `auth.uid() = user_id` |

> INSERT/UPDATE/DELETE RLS 정책 없음 → `anon`/`authenticated` 역할 write 차단. Edge Function이 `SUPABASE_SERVICE_ROLE_KEY`로 INSERT.

**인덱스**

| 인덱스명 | 컬럼 | 타입 | 비고 |
|---------|------|------|------|
| idx_ai_usage_user_called | (user_id, called_at) | BTREE | 일일 사용량 쿼리 최적화 |

---

## 4. ERD (관계 다이어그램)

```
auth.users ||--o| user_profiles       : "1:1 프로필"
auth.users ||--o{ tasks               : "1:N 태스크"
auth.users ||--o{ sessions            : "1:N 세션"
auth.users ||--o{ distractions        : "1:N 분산"
auth.users ||--o{ mood_checks         : "1:N 기분체크"
auth.users ||--o{ ai_usage_log        : "1:N AI사용"
tasks      ||--o{ sessions            : "1:N (ON DELETE SET NULL)"
sessions   ||--o{ distractions        : "1:N (ON DELETE CASCADE)"
sessions   ||--o{ mood_checks         : "1:N (ON DELETE SET NULL)"
```

---

## 5. 변경 이력

| 버전 | 변경일 | 변경 내용 |
|------|--------|----------|
| v1.0 | 2026-05-12 | Phase 1 최초 작성 (6개 테이블) |
