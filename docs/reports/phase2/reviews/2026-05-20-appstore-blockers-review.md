---
review_date: 2026-05-20
branch: feat/appstore-blockers
base: develop
reviewer: Claude Code (자체) + Codex (위임)
scope: ADHD UX 회귀 · 출시 블로커 잔여 · 보안 · 회귀
status: BLOCK (HIGH 2건)
---

# Review: feat/appstore-blockers PR — ADHD UX & 출시 블로커 점검

## 0. 종합 판정

**BLOCK** — HIGH 2건이 출시 차단 사유. 본 PR은 별도 fix 브랜치 2건이 머지된 후 출시 가능.

| 등급 | 건수 | 비고 |
|------|------|------|
| HIGH | 2 | PrivacyInfo Xcode 미등록, delete-account CORS 부재 |
| MEDIUM | 3 | 단일 confirm, auth_expired 분기 부족, pub audit CI 안정성 |
| LOW | 3 | dead userId, TaskListNotifier 'guest' 고정, CASCADE 마이그레이션 중복 |

ADHD UX 핵심 원칙(RULE 11 마찰 최소화, RULE 12 게스트 우선)은 **회귀 없음**.
- 라우터 `initialLocation: '/tasks'` 유지 (로그인 강요 없음)
- TaskListScreen: 1-tap FAB로 세션 시작 동선 유지
- 설정 진입은 AppBar 우측 아이콘 — 마찰 최소
- Phase 2 Task 02 온보딩 설계도 "스킵 가능 · 1탭 · 강요 없음" 명시

---

## 1. HIGH — 출시 차단

### H-1. PrivacyInfo.xcprivacy가 Xcode 타깃에 미등록

- **위치**: `ios/Runner.xcodeproj/project.pbxproj`, `macos/Runner.xcodeproj/project.pbxproj`
- **확인**: 양쪽 pbxproj에 `grep -n "PrivacyInfo"` 결과 **0건**.
- **영향**: 파일은 `ios/Runner/`, `macos/Runner/`에 존재하지만 빌드 phase의 `Copy Bundle Resources`에 포함되지 않아 IPA/APP 아카이브에 실제로 들어가지 않을 가능성. Apple 2024-05 의무화 위반으로 App Store Connect 자동 검사에서 제출 거절될 수 있음.
- **권장 수정**:
  1. Xcode에서 `Runner` 타깃 → Build Phases → Copy Bundle Resources에 `PrivacyInfo.xcprivacy` 추가 (iOS·macOS 각각)
  2. `git diff` 후 pbxproj에 `PrivacyInfo` 항목 생성 확인
  3. 제출 전 `xcodebuild archive` 후 IPA 내부에 파일 포함 여부 검증
- **수정은 별도 PR**: `fix/appstore-privacy-xcode-registration`

### H-2. delete-account Edge Function CORS/OPTIONS 미처리

- **위치**: `supabase/functions/delete-account/index.ts:4-28`
- **확인**: 30라인 코드 전체에 CORS 헤더 부재, `OPTIONS` preflight 분기 없음.
- **영향**: Flutter `functions.invoke()`는 native HTTP라 CORS 영향 없음 → **모바일 실사용 차단 영향은 없음**. 그러나 (a) Supabase 대시보드 함수 테스트 도구, (b) 차후 웹 어드민 또는 Phase 3 웹 클라이언트, (c) 디버깅 시 `curl --preflight` 호출이 모두 실패. App Store 심사 직접 차단은 아니나 운영 가시성 차원에서 HIGH로 분류.
- **참고**: Codex가 HIGH로 분류함. 본 리뷰는 사실관계상 영향이 운영툴에 한정되므로 **HIGH/MEDIUM 경계**임을 명시. 사용자 판단에 따라 MEDIUM 강등 가능.
- **권장 수정**:
  ```ts
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  }
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  // 모든 응답에 ...corsHeaders 머지
  ```
- **수정은 별도 PR**: `fix/delete-account-cors`

---

## 2. MEDIUM — 출시 후 1주 내 수정 권장

### M-1. 계정 삭제 단일 confirm — 충동 클릭 위험

- **위치**: `lib/features/settings/presentation/widgets/delete_account_dialog.dart:23-31`
- **근거**: 빨간 텍스트 1탭 → AlertDialog → confirm 1탭 = 총 2탭으로 영구 삭제. ADHD 충동성(미디케이션 미복용 시 특히) 고려 시 오조작 위험. l10n 카피("되돌릴 수 없어요")는 적절하나 시각적 차단 부족.
- **권장 수정**: 2단계 confirm(체크박스 "이해했어요" → 활성화되는 삭제 버튼), 또는 holding press 3초. RULE 11 마찰 최소화와 충돌하는 예외 케이스로 명문화.
- **수정은 별도 PR**: `fix/delete-account-double-confirm`

### M-2. `auth_expired` 오류 별도 동선 부재

- **위치**: `lib/features/auth/data/datasources/auth_remote_datasource.dart:74`, `lib/features/settings/presentation/widgets/delete_account_dialog.dart:61-65`
- **근거**: 세션 만료 시 `DeleteAccountException('auth_expired')` 발생하나 위젯이 `network_error` 외엔 전부 `server_error`로 처리 → 사용자는 "서버 오류"만 보고 재로그인 동선 인지 불가.
- **권장 수정**: l10n에 `deleteAccountErrorAuthExpired` 추가, 위젯에서 `auth_expired` 분기 + "다시 로그인" 액션 SnackBar.

### M-3. CI pub audit 폴백 부재

- **위치**: `.github/workflows/quality-gates.yml:52-54`
- **근거**: 피처 리포트에 로컬 Flutter 3.41.9에서 `flutter pub audit` 미지원 확인. CI Flutter 버전 업데이트 시 동일 증상 가능. 단일 실패로 quality-gates 전체 차단됨.
- **권장 수정**: `flutter pub audit || dart pub audit` 폴백, 또는 `continue-on-error` 임시 처리 + 별도 슬랙 알림.

---

## 3. LOW — Phase 3 이월 가능

### L-1. `userId` dead 파라미터 잔존 (이미 피처 리포트에 명시)

- **위치**: `lib/features/auth/domain/usecases/delete_account_usecase.dart:8`, `lib/features/auth/domain/repositories/auth_repository.dart:13`, `lib/features/auth/data/datasources/auth_remote_datasource.dart:70`
- **근거**: Edge Function이 JWT user.id로 처리. 클라이언트 인자는 미사용.
- **권장**: Phase 3 인터페이스 정리 시 `deleteAccount()` 무인자로 단순화.

### L-2. TaskListNotifier `_guestUserId='guest'` 고정 (Phase 1 잔존, Task 01에 영향)

- **위치**: `lib/features/task/presentation/providers/task_provider.dart:14, 19-22`
- **근거**: 본 PR과 무관하지만 Task 01(Supabase 실연결) 진입 시 즉시 충돌. 인증 후에도 `'guest'`로 조회.
- **권장**: Task 01 설계 단계에서 `authProvider` 연동 — guest/auth userId source 단일화.

### L-3. CASCADE 마이그레이션 중복 (자체 점검 추가 발견)

- **위치**: `supabase/migrations/20260518000000_add_cascade_delete.sql:1-23`
- **근거**: 모든 테이블이 원본 `CREATE TABLE` 시점부터 이미 `REFERENCES auth.users(id) ON DELETE CASCADE` 보유. 새 마이그레이션은 4개 테이블(`user_profiles`, `tasks`, `sessions`, `mood_checks`)에 대해 DROP + 동일 ADD 재정의. `distractions`, `ai_usage_log`는 새 마이그레이션에서 빠졌으나 원본 그대로 CASCADE 유효 — **삭제 시 모든 데이터 정리됨, 기능적 문제 없음**.
- **권장**: 코드 정리 차원에서 마이그레이션 주석에 "기존 CASCADE 명시적 재선언 (보존 목적)" 추가, 또는 Phase 3 마이그레이션 정리 시 통합.

---

## 4. ADHD UX 회귀 점검 — 결과 PASS

| 항목 | 결과 | 확인 |
|------|------|------|
| RULE 11 (1-tap 진입) | PASS | `initialLocation: '/tasks'` + FAB 1-tap 시작 |
| RULE 12 (게스트 우선) | PASS | 로그인 강요 없음, 세션 3회 후 prompt |
| 마찰 추가 여부 | PASS | 설정은 AppBar 아이콘, 계정삭제는 자발적 접근 |
| 강제 모달/팝업 | PASS | 첫 진입 시 PrivacyInfo/동의 화면 없음 |
| Phase 2 Task 02 온보딩 | PASS (설계) | "스킵 가능, 1탭, 강요 없음" 명시 |

---

## 5. Phase 2 진행 권고

| 시나리오 | 권고 |
|----------|------|
| HIGH 2건 미해결 상태로 Task 01 진입 | **비권장** — PrivacyInfo는 빌드 산출물에 영향, CORS는 운영 가시성 차단 |
| HIGH 2건 fix 머지 후 Task 01 | **권장** — Task 01(Supabase 실연결) 설계 시 L-2(TaskListNotifier guest 고정) 동시 해결 권장 |
| MEDIUM 우선순위 | M-1, M-2는 출시 후 1주 내. M-3은 CI 안정성 차원에서 Task 01 전 권장 |

### 후속 PR 제안 (별도 브랜치)

1. `fix/appstore-privacy-xcode-registration` — H-1, Xcode 수동 작업 (1시간 이내)
2. `fix/delete-account-cors` — H-2, Edge Function 5라인 추가 (30분 이내)
3. `fix/delete-account-double-confirm` — M-1, 위젯 + l10n 수정 (2시간 이내)
4. `fix/delete-account-auth-expired-flow` — M-2, l10n + 분기 추가 (1시간 이내)
5. `chore/ci-pub-audit-fallback` — M-3, workflow 1줄 수정 (15분 이내)

L-1, L-2, L-3은 Phase 2 Task 01 또는 Phase 3 정리 PR에 통합.

---

## 6. Codex 원문 리뷰 (전체)

```
codex exec --sandbox read-only --skip-git-repo-check (2026-05-20)
tokens used: 33,664

## 종합 판정 (PASS / CONDITIONAL / BLOCK)
BLOCK

## HIGH (출시 차단 또는 ADHD 핵심 원칙 위반)
1. PrivacyInfo가 Xcode 타깃에 미등록 상태 (실제 제출 블로커 잔존)
   - docs/reports/phase2/features/00-appstore-blockers.md:40, :22
   - ios/Runner/PrivacyInfo.xcprivacy:1, macos/Runner/PrivacyInfo.xcprivacy:1
   근거: 리포트에 "파일 생성만, Xcode 등록은 수동" 명시. .xcprivacy 파일 존재와 별개로 빌드 아티팩트 포함 보장 없음.
   권장: Runner 타깃 Copy Bundle Resources에 추가, project.pbxproj에 PrivacyInfo 항목 생성 확인, xcodebuild로 IPA 포함 검증.

2. delete-account Edge Function CORS/OPTIONS 미처리
   - supabase/functions/delete-account/index.ts:4, :6, :26-28
   근거: 모든 응답에서 CORS 헤더 부재, OPTIONS preflight 분기 없음. 디버그/웹 호출/운영툴 실패 가능.
   권장: OPTIONS 200 즉시 반환, 성공/에러 응답 모두에 Access-Control-Allow-* 추가, 에러 응답 JSON 통일.

## MEDIUM (출시 후 1주 내 수정 권장)
1. 계정 삭제 확인 강도가 낮아 오조작 리스크 존재
   - delete_account_dialog.dart:23-31, app_ko.arb:82
   근거: 단일 다이얼로그 + 단일 확인 버튼. ADHD 영구 삭제는 예외적으로 오조작 방지 필요.
   권장: 2-step 확인 또는 명시 체크박스. 실패 시 재시도/문의 동선.

2. 삭제 실패 복구 메시지가 거칠고 원인별 행동 유도 약함
   - delete_account_dialog.dart:61-65, auth_remote_datasource.dart:74
   근거: auth_expired도 server_error로 뭉뚱그려짐. 재로그인 행동 인지 어려움.
   권장: 오류 코드 매핑 분리, auth_expired는 로그인 화면 액션 제공.

3. CI flutter pub audit 단일 실패로 파이프라인 불안정 가능
   - .github/workflows/quality-gates.yml:52-54
   근거: 문서상 로컬 미지원 확인. CI 런타임/SDK 조합에 따라 명령 실패.
   권장: flutter pub audit || dart pub audit 폴백, 실패 원인 구분 출력.

## LOW (Phase 3 이월 가능)
1. userId 파라미터 dead threading 잔존
   - delete_account_usecase.dart:8, auth_repository_impl.dart:29-30, auth_remote_datasource.dart:70
   권장: Phase 3에서 deleteAccount() 무인자로 단순화.

2. Phase 1 잔존 이슈: TaskListNotifier 반응성 문제
   - task_provider.dart:14, 19-22
   근거: _guestUserId='guest' 고정 조회. Task 01 시작 시 충돌 가능.
   권장: Task 01 착수 전 authProvider 연동 설계 확정.

## Phase 2 진행 권고
바로 진행 비권장. HIGH 2건을 먼저 닫고 Task 01로 넘어가는 것이 안전. MEDIUM 중 삭제 실패 복구 메시지 개선까지 선반영하면 TestFlight 내부테스트 실패율 감소.
```
