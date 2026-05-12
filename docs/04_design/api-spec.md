# API 명세서

| 항목 | 내용 |
|------|------|
| 프로젝트 | OwnUrTime |
| 버전 | v1.0 |
| 작성일 | 2026-05-12 |
| 작성자 | Wonjin Choi |
| 상태 | 확정 (Phase 1) |

---

## 1. 개요

OwnUrTime의 AI 기능을 제공하는 Supabase Edge Function API를 정의한다. Phase 1에는 `decompose-task` 단일 엔드포인트가 존재하며, Gemini Flash 2.0을 통해 태스크를 3개의 실행 가능한 세부 단계로 분해한다.

**Base URL**: `{SUPABASE_URL}/functions/v1`  
**인증 방식**: Bearer JWT (Supabase Auth)  
**Content-Type**: `application/json`

> Edge Functions은 Supabase 프로젝트의 `SUPABASE_URL` 환경변수로 Base URL을 결정한다. 로컬 개발 시 `http://127.0.0.1:54321/functions/v1`.

---

## 2. 공통 사항

### 2.1 인증 헤더

모든 엔드포인트는 `Authorization` 헤더 필수. Supabase Auth의 `access_token`을 전달한다.

```
Authorization: Bearer {access_token}
```

헤더 누락 또는 유효하지 않은 JWT 시 즉시 `401 unauthorized` 반환.

### 2.2 CORS

다음 헤더를 모든 응답에 포함한다:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: authorization, x-client-info, apikey, content-type
```

Preflight `OPTIONS` 요청에는 `200 null` body 응답.

### 2.3 공통 에러 코드

| HTTP 상태 | 에러 코드 | 설명 |
|----------|----------|------|
| 400 | `invalid_request_body` | 요청 바디 JSON 파싱 실패 |
| 400 | `missing_required_fields` | 필수 필드 누락 또는 잘못된 타입 |
| 400 | `task_title_too_long` | `task_title` 500자 초과 |
| 401 | `unauthorized` | 인증 토큰 없음 또는 유효하지 않음 |
| 429 | `daily_limit_reached` | 일일 사용 한도 초과 |
| 500 | `internal_error` | 서버 내부 오류 (DB 쿼리 실패 등) |
| 502 | `ai_service_error` | Gemini API 비정상 응답 |
| 502 | `ai_parse_error` | Gemini 응답 파싱 실패 (3개 스텝 미만) |
| 503 | `service_unavailable` | `GEMINI_API_KEY` 미설정 |
| 503 | `ai_service_unavailable` | Gemini API 연결 불가 |
| 504 | `ai_service_timeout` | Gemini API 10초 타임아웃 |

---

## 3. API 목록

### 3.1 decompose-task — 태스크 분해

**엔드포인트**: `POST /decompose-task`  
**설명**: 입력된 태스크 제목을 Gemini Flash 2.0으로 분석해 3개의 실행 가능한 세부 단계를 반환한다.  
**인증**: 필수 (Supabase Auth JWT)

#### 요청 (Request)

**Headers**

| 헤더 | 필수 | 설명 |
|------|------|------|
| `Authorization` | Y | `Bearer {access_token}` |
| `Content-Type` | Y | `application/json` |

**Body**

| 파라미터 | 타입 | 필수 | 제약 | 설명 |
|---------|------|------|------|------|
| `task_title` | string | Y | 1자 이상, 500자 이하 | 분해할 태스크 제목 |

**요청 예시**

```json
{
  "task_title": "주간 보고서 작성"
}
```

#### 응답 (Response)

**성공 (200)**

```json
{
  "steps": [
    "지난 주 완료 항목 목록 정리",
    "수치 데이터 및 진행률 취합",
    "보고서 초안 작성 후 팀장에게 전송"
  ],
  "remaining_today": 7
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `steps` | string[] | 분해된 3개의 세부 단계 (순서 있음) |
| `remaining_today` | integer | 당일 남은 사용 횟수 (0 이상) |

**에러**

| HTTP | 에러 코드 | 발생 조건 |
|------|----------|----------|
| 400 | `invalid_request_body` | 바디가 JSON이 아님 |
| 400 | `missing_required_fields` | `task_title` 없거나 string이 아님 |
| 400 | `task_title_too_long` | `task_title.length > 500` |
| 401 | `unauthorized` | Authorization 헤더 없음 / 만료된 JWT |
| 429 | `daily_limit_reached` | 당일 10회 사용 초과 |
| 500 | `internal_error` | `ai_usage_log` 조회 실패 |
| 502 | `ai_service_error` | Gemini HTTP 비정상 (4xx/5xx) |
| 502 | `ai_parse_error` | Gemini가 3개 미만 스텝 반환 |
| 503 | `service_unavailable` | `GEMINI_API_KEY` 환경변수 미설정 |
| 503 | `ai_service_unavailable` | Gemini fetch 연결 오류 |
| 504 | `ai_service_timeout` | Gemini 10초 내 응답 없음 |

**에러 응답 형식**

```json
{
  "error": "daily_limit_reached",
  "steps_used": 10
}
```

> `steps_used` 필드는 `daily_limit_reached` 에러 시에만 포함됨.

---

## 4. Rate Limit 정책

| 항목 | 값 |
|------|---|
| 단위 | 사용자(user_id)당 일일 |
| 한도 | 10회 / UTC 0시 기준 일별 리셋 |
| 측정 방식 | `ai_usage_log` 테이블 (서버 기록, 클라이언트 조작 불가) |
| 초과 시 | `429 daily_limit_reached` |

> 한도 내 마지막 성공 응답: `remaining_today: 0`  
> 한도 초과 요청: `429 daily_limit_reached` (응답 본문에 `steps_used: 10`)

---

## 5. 구현 참고

### 5.1 AI 프롬프트 구조

```
Break this task into exactly 3 short, actionable steps.
Return only the 3 steps, one per line, without numbering or bullet points:
{sanitized_task_title}
```

- 응답 온도(temperature): 0.3
- 최대 출력 토큰: 500
- 모델: `gemini-2.5-flash`

### 5.2 입력 제어 문자 처리

`task_title`의 제어 문자(`\x00–\x1F`, `\x7F`)는 공백으로 치환 후 trim.  
XSS 방지 목적이 아닌 Gemini 프롬프트 오염 방지.

### 5.3 서비스 롤 키 사용

`ai_usage_log` 테이블 INSERT/SELECT는 서비스 롤(`SUPABASE_SERVICE_ROLE_KEY`)로 수행.  
Supabase Edge Function 런타임에서 자동 주입됨 — 코드 내 하드코딩 금지.

---

## 6. 변경 이력

| 버전 | 변경일 | 변경 내용 |
|------|--------|----------|
| v1.0 | 2026-05-12 | Phase 1 최초 작성 (`decompose-task`) |
