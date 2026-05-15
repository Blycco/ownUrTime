---
phase: 1
date: 2026-05-15
qa-report: docs/reports/phase1/qa-report.md
status: CONDITIONAL PASS
---

# Phase 1 Summary — OwnUrTime

## What Shipped

| # | Feature | 핵심 내용 |
|---|---------|----------|
| 00 | Project Init | Flutter 프로젝트, Supabase 연결, AppTheme, GoRouter, Riverpod 3.x, l10n 인프라 |
| 01 | Supabase Schema | 5개 테이블 RLS (user_profiles/tasks/sessions/distractions/mood_checks), Edge Function (Gemini Flash 2.0 decompose-task, 10회/일 rate limit) |
| 02 | Task feature | CRUD, 2분 micro-start, AI 분해 (3단계), DailyLimitException |
| 03 | Session Timer | 유연 타이머 (10/15/25+커스텀), 3회 리셋, +1분 연장, adaptive check-in (5분 전) |
| 04 | Recovery | 3가지 방해 유형 (urgent/impulsive/rest), context restore 카드, 1-tap 재진입 |
| 05 | Mood Check | 5단계 이모지, 세션 전후 체크, 레벨≤2 → 10분 자동 추천 |
| 06 | Auth | 게스트 모드 우선, 세션 3회 완료 후 Apple Sign In 프롬프트, local→Supabase 마이그레이션 UseCase |
| 07 | Reward | 세션 완료 시 HapticFeedback + 애니메이션, 조건 없음 (항상 발동) |
| 08 | i18n + iCloud Backup | ARB 구조 (ko/en), 세션 완료 시 iCloud Drive 백업, 앱 기동 시 복원 |
| 09 | Analytics | PostHog EU (PIPA 준수), 5개 KPI 이벤트 (initiation_conversion / session_completed / session_distracted / recovery_returned / day_2_return) |

**Tests**: 61/61 passed | **flutter analyze**: 0 issues | **Coverage**: 50.1% overall (domain+data 40.9%)

---

## ADR Index

| 파일 | 결정 한 줄 요약 |
|------|----------------|
| [2026-05-12-riverpod-3x-notifier-provider.md](../../decisions/2026-05-12-riverpod-3x-notifier-provider.md) | StateProvider 제거됨 → NotifierProvider로 전환 |
| [2026-05-13-in-memory-datasource-phase1.md](../../decisions/2026-05-13-in-memory-datasource-phase1.md) | Phase 1 전체 로컬 InMemory datasource (Phase 2에서 Supabase 교체) |
| [2026-05-14-guest-first-auth-and-oauth-callback-pattern.md](../../decisions/2026-05-14-guest-first-auth-and-oauth-callback-pattern.md) | 게스트 우선 + Apple Sign In OAuth deep link callback 패턴 |
| [2026-05-14-mood-check-sealed-state.md](../../decisions/2026-05-14-mood-check-sealed-state.md) | MoodCheckState sealed class (pending / done) |
| [2026-05-15-analytics-viewmodel-layer.md](../../decisions/2026-05-15-analytics-viewmodel-layer.md) | Analytics events in TimerNotifier (ViewModel layer, not UseCase) |

---

## Tech Debt Carried Forward to Phase 2

| ID | 심각도 | 내용 | Phase 2 처리 방법 |
|----|--------|------|-------------------|
| QA-01 | MEDIUM | TaskListNotifier — Apple Sign In 후 task 불가시 (userId 불일치) | authProvider watch 추가 |
| QA-02 | MEDIUM | DurationSelector — `await` 후 `mounted` 체크 누락 | `if (!mounted) return` 추가 |
| QA-03 | MEDIUM | backup `catch(_)` 로그 없음 | `LoggerService.warning` 추가 |
| QA-04 | LOW | LoginScreen dead code (미연결 라우트) | 삭제 또는 라우트 연결 |
| QA-05 | LOW | DistractionDataSource 인터페이스 없음 | Supabase datasource 추가 시 생성 |
| QA-06 | INFO | domain/+data/ coverage 40.9% (목표 80% 미달) | Supabase repository 단위 테스트 작성 |
| QA-07 | INFO | `identify(userId)` 미연결 | Apple Sign In 완성 후 authProvider에서 호출 |

---

## Phase 1 KPI Targets (PostHog Baseline — Week 1부터 측정)

| KPI | 목표 | 측정 방법 |
|-----|------|-----------|
| `initiation_conversion` | ≥60% | app_open → 2-min start 탭, 첫 주 코호트 |
| `session_completed` rate | ≥50% | 시작 세션 대비 완료 세션 |
| `day_2_return` | ≥40% | 첫 세션 다음 날 복귀 사용자 비율 |
| `recovery_returned` rate | ≥70% | 방해 발생 후 재진입 비율 |

> 측정 시작 조건: 실기기 `--dart-define=POSTHOG_API_KEY=<key>` 주입 후 TestFlight 배포

---

## TestFlight

> 아래 항목은 실기기 CONDITIONAL 항목 완료 후 채울 것

- Build: _(미완)_
- Submitted: _(미완)_
- Internal testers: _(미완)_
- Feedback summary: _(내부 테스트 기간 후 작성)_

**CONDITIONAL 완료 조건** (TestFlight 제출 전):
1. Xcode: Runner target → Signing & Capabilities → + iCloud → Documents 활성화
2. 실기기에서 세션 완료 → Files 앱 → iCloud Drive 백업 파일 확인
3. `--dart-define=POSTHOG_API_KEY=<key>` 주입 후 세션 완료 → PostHog EU 대시보드 5개 이벤트 확인

---

## Lessons for Phase 2

**아키텍처**
- InMemory datasource를 Phase 1 전체에 유지한 것은 올바른 결정 — domain/presentation 레이어를 백엔드 없이 완성할 수 있었음. Phase 2 Supabase 교체 시 인터페이스만 바꾸면 됨.
- Analytics events는 UseCase가 아닌 ViewModel(TimerNotifier)에 두는 것이 정답 — `recovery_returned`처럼 UseCase 없는 이벤트가 존재하고, timer elapsed/recovery 시간은 presentation state임.

**프로세스**
- flutter-reviewer를 매 태스크마다 실행하는 것이 핵심 — 통합 QA에서 HIGH 2건만 남은 이유.
- Codex `stdin hang` 이슈 → 프롬프트 파일 경유 (`codex exec "$(cat .claude/codex-prompts/...)"`) 방식으로 안정화.
- 레이어 설계(인터페이스/엔티티)를 먼저 확정하고 Codex 위임하는 흐름이 효율적임.

**보안**
- `userId` 스레딩(datasource → repository → usecase → notifier)을 Phase 1 초반에 정립했어야 함 — 후반에 HIGH 이슈로 발견됨.
- `kFirstSessionDateStorageKey` 같은 storage key는 상수로 단일화 — 파일 간 키 불일치 버그 예방.
