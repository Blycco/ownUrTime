# API 명세서

| 항목 | 내용 |
|------|------|
| 프로젝트 | {프로젝트명} |
| 버전 | v{N}.{N} |
| 작성일 | {YYYY-MM-DD} |
| 작성자 | {작성자} |
| 상태 | 초안 / 확정 / 변경 |

---

## 1. 개요

{API 목적 및 범위}

**Base URL**: `{base_url}`  
**인증 방식**: Bearer JWT (Supabase Auth)  
**Content-Type**: `application/json`

---

## 2. 공통 사항

### 2.1 인증 헤더

```
Authorization: Bearer {access_token}
```

### 2.2 공통 에러 코드

| HTTP 상태 | 에러 코드 | 설명 |
|----------|----------|------|
| 400 | invalid_request_body | 요청 바디 파싱 실패 |
| 400 | missing_required_fields | 필수 필드 누락 |
| 401 | unauthorized | 인증 토큰 없음 또는 유효하지 않음 |
| 429 | daily_limit_reached | 일일 한도 초과 |
| 500 | internal_error | 서버 내부 오류 |

---

## 3. API 목록

### 3.{N}. {기능명}

**엔드포인트**: `{METHOD} {path}`  
**설명**: {기능 설명}  
**인증**: 필요 / 불필요

#### 요청 (Request)

**Headers**
| 헤더 | 필수 | 설명 |
|------|------|------|
| Authorization | Y | Bearer {JWT} |

**Body**
| 파라미터 | 타입 | 필수 | 제약 | 설명 |
|---------|------|------|------|------|
| {param} | string | Y | 최대 {N}자 | {설명} |

#### 응답 (Response)

**성공 (200)**
```json
{
  "{field}": "{value}"
}
```

**에러**
| HTTP | 에러 코드 | 발생 조건 |
|------|----------|----------|
| 400 | {code} | {조건} |

---

## 4. 변경 이력

| 버전 | 변경일 | 변경 내용 | 변경자 |
|------|--------|----------|--------|
| v1.0 | {날짜} | 최초 작성 | |
