# 시스템 아키텍처 설계서

| 항목 | 내용 |
|------|------|
| 프로젝트 | OwnUrTime |
| 버전 | v1.0 |
| 작성일 | 2026-05-12 |
| 작성자 | Wonjin Choi |
| 상태 | 확정 (Phase 1) |

---

## 1. 개요

OwnUrTime의 전체 시스템 구성, 레이어 구조, 인증 흐름, 오프라인/온라인 전환 정책을 정의한다. 모든 아키텍처 결정은 이 문서를 기준으로 하며, 변경 시 변경 이력에 기록한다.

---

## 2. 전체 시스템 구성

```
┌─────────────────────────────────────────────────────────┐
│  Flutter App (iOS / macOS / iPad / Android / Web)        │
│                                                          │
│  Presentation Layer                                      │
│    Widget ──→ Riverpod Notifier ──→ UseCase              │
│                                                          │
│  Domain Layer                                            │
│    UseCase ──→ Repository Interface                      │
│                                                          │
│  Data Layer                                              │
│    Repository Impl ──→ DataSource ──→ Supabase Client    │
└────────────────────────┬────────────────────────────────┘
                         │ HTTPS / Realtime WebSocket
┌────────────────────────▼────────────────────────────────┐
│  Supabase Platform                                       │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │  Auth        │  │  PostgreSQL  │  │  Edge Function│  │
│  │  (JWT/Apple/ │  │  (6 tables   │  │  decompose-   │  │
│  │   Google)    │  │   + RLS)     │  │  task (Deno)  │  │
│  └──────────────┘  └──────────────┘  └───────┬───────┘  │
│                                               │          │
│  ┌──────────────┐  ┌──────────────┐           │          │
│  │  Realtime    │  │  Storage     │           │          │
│  │  (WebSocket) │  │  (Phase 2+)  │           │          │
│  └──────────────┘  └──────────────┘           │          │
└────────────────────────────────────────────────┼─────────┘
                                                 │ HTTPS
┌────────────────────────────────────────────────▼─────────┐
│  External Services                                        │
│                                                          │
│  Gemini Flash 2.0                PostHog Analytics       │
│  (task decomposition)            (event tracking)        │
│                                                          │
│  APNs / FCM (Phase 2+)           iCloud Drive (iOS/macOS)│
│  (push notifications)            (offline backup)        │
└─────────────────────────────────────────────────────────┘
```

---

## 3. 레이어 구조

### 3.1 레이어 의존 방향

```
Widget
  ↓ (only)
Riverpod Notifier/Provider
  ↓ (only)
UseCase
  ↓ (only)
Repository Interface (domain)
  ↓ (impl in data)
DataSource
  ↓ (only)
Supabase Client / External SDK
```

**위반 금지 사항**:
- Widget이 UseCase/Repository/DataSource 직접 호출 금지
- Notifier가 Repository/DataSource/Supabase Client 직접 호출 금지
- DataSource가 다른 DataSource 호출 금지
- Feature 간 내부 모듈 import 금지 (공유 데이터는 `lib/core/` 엔티티 경유)

### 3.2 폴더 구조

```
lib/
├── core/
│   ├── analytics/          ← PostHog 래퍼 (AnalyticsService)
│   ├── backup/             ← iCloud Drive 백업 서비스 (Phase 2)
│   ├── l10n/               ← ARB 파일 + 생성된 AppLocalizations
│   ├── router/             ← GoRouter (app_router.dart)
│   ├── supabase/           ← SupabaseConfig (dart-define 상수)
│   └── theme/              ← AppTheme, AppColors
└── features/
    └── {feature}/
        ├── data/
        │   ├── datasources/    ← Supabase 호출 전담
        │   ├── models/         ← freezed + json_serializable DTO
        │   └── repositories/   ← domain 인터페이스 구현체
        ├── domain/
        │   ├── entities/       ← freezed, 외부 의존 없음
        │   ├── repositories/   ← abstract 인터페이스
        │   └── usecases/       ← 단일 책임, public 메서드 1개
        └── presentation/
            ├── providers/      ← AsyncNotifier / StreamProvider
            ├── screens/        ← 페이지 단위 위젯
            └── widgets/        ← 재사용 가능한 UI 컴포넌트
```

### 3.3 Riverpod 상태 관리 패턴

| 상태 유형 | Provider 타입 | 예시 |
|---------|--------------|------|
| 서버 데이터 (비동기, 가변) | `AsyncNotifier` | 태스크 목록, 세션 상태 |
| 실시간 스트림 | `StreamProvider` | 세션 라이브 업데이트 |
| 파생/계산값 | `Provider` | 필터된 태스크 수 |
| 정적 설정 | `Provider` | theme, router, SupabaseClient |

- `ref.watch`: build 메서드 내에서만 사용
- `ref.read`: 콜백(onTap, onPressed 등) 내에서만 사용
- 전역 가변 싱글톤 금지 — 모든 의존성은 Riverpod `ref`로 주입

---

## 4. 인증 흐름

### 4.1 최초 앱 실행 — 게스트 모드

```
앱 실행
  ↓
supabase.auth.currentSession == null?
  ↓ YES
게스트 모드 진입 (session_count < 3)
  ↓
태스크 생성 → 세션 시작 가능 (로컬 상태)
  ↓
session_count == 3 도달
  ↓
"더 많은 세션을 위해 저장하세요" 안내 → 소셜 로그인 유도
```

### 4.2 소셜 로그인 흐름

```
Apple Sign In / Google Sign In
  ↓
supabase.auth.signInWithApple() / signInWithGoogle()
  ↓
Supabase Auth가 JWT 발급 → auth.users 레코드 생성
  ↓
DB Trigger (auth.users INSERT) → public.user_profiles 레코드 자동 생성
  ↓
게스트 데이터 마이그레이션 (session_count 포함)
  ↓
인증 사용자 세션 시작
```

### 4.3 JWT 갱신

Supabase Client SDK가 자동 토큰 갱신 처리. 앱 포그라운드 복귀 시 `onAuthStateChange`로 세션 상태 동기화.

---

## 5. 오프라인 / 온라인 전환 정책

| 상태 | 동작 |
|------|------|
| 온라인 | Supabase Realtime 스트림 활성화, 모든 쓰기 즉시 동기화 |
| 오프라인 | 세션 타이머 및 분산 기록 로컬 유지, 재연결 시 일괄 업로드 |
| iCloud Drive 백업 | 세션 완료 시 iOS/macOS에서 자동 백업 (게스트 데이터 보호) |

> 오프라인 상태에서 AI 기능(`decompose-task`)은 네트워크 불가로 비활성화. UI에서 오프라인 상태 표시 필요.

---

## 6. Edge Function 아키텍처

| Function | 트리거 | 목적 | 보안 |
|----------|-------|------|------|
| `decompose-task` | Flutter HTTP POST | Gemini Flash 2.0 → 3 세부 단계 반환 | JWT 인증 + 서비스 롤 Rate Limit |
| `send-push` | Supabase DB Webhook | APNs 푸시 알림 (Phase 2) | Service Role 전용 |

### decompose-task 처리 흐름

```
Flutter POST /functions/v1/decompose-task
  ↓ Authorization: Bearer {JWT}
Edge Function (Deno runtime)
  ↓ userClient.auth.getUser() → JWT 검증
  ↓ serviceClient.ai_usage_log SELECT → 일일 사용량 확인 (DAILY_LIMIT = 10)
  ↓ 한도 초과 → 429 daily_limit_reached
  ↓ fetch(GEMINI_API_URL) with AbortController (10s timeout)
  ↓ Gemini Flash 2.0 응답 파싱 → 3 steps 추출
  ↓ serviceClient.ai_usage_log INSERT → 사용량 기록
  ↓ { steps: [...], remaining_today: N } 반환
```

> `SUPABASE_SERVICE_ROLE_KEY`와 `GEMINI_API_KEY`는 Edge Function 런타임에서만 접근 가능. Flutter 앱 내 노출 금지.

---

## 7. 멀티플랫폼 전략

| 플랫폼 | 단계 | 비고 |
|-------|------|------|
| iOS | Phase 1 | 1차 출시 타겟 |
| macOS | Phase 1 | 동일 코드베이스; Cmd+Shift+P 단축키 추가 |
| iPad | Phase 2 | 동일 코드베이스; 적응형 레이아웃 |
| Android | Phase 3 | 동일 코드베이스; APNs → FCM 전환 |
| Windows/Web | Phase 4+ | iCloud 백업 미지원 |

**플랫폼 분기 패턴**:

```dart
if (Platform.isMacOS) { /* macOS 전용: 키보드 단축키 */ }
if (Platform.isIOS || Platform.isMacOS) { /* Apple 전용: iCloud, EventKit */ }
```

Swift 브리지는 `EventKit` (Phase 2 캘린더)에만 사용. Dart로 가능한 기능에 Swift 금지.

---

## 8. 보안 원칙

| 원칙 | 구현 |
|------|------|
| 서버 비밀 격리 | `GEMINI_API_KEY`, `SUPABASE_SERVICE_ROLE_KEY` — Edge Function 런타임 전용 |
| 클라이언트 쓰기 차단 | `ai_usage_log`, `user_profiles.session_count` — RLS로 직접 쓰기 차단, SECURITY DEFINER 함수로만 변경 |
| RLS 전체 활성화 | 모든 테이블에 RLS 활성화, `auth.uid()` 기반 행 격리 |
| PIPA 준수 | 기분 데이터(`mood_checks`) 직접 UPDATE 향후 제거 예정 (Tech Debt) |
| 분석 PII 차단 | PostHog에 개인 식별 정보 전송 금지 (익명 이벤트만) |

---

## 9. 변경 이력

| 버전 | 변경일 | 변경 내용 |
|------|--------|----------|
| v1.0 | 2026-05-12 | Phase 1 최초 작성 |
