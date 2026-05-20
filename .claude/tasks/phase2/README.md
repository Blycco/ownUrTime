# Phase 2 태스크 목록

> **목표**: 100 외부 베타 사용자 확보  
> **기간**: 약 8주  
> **전제 조건**: Phase 1 완료, Phase 1 QA CONDITIONAL PASS 해소

---

## 태스크 목록

| # | 파일 | 내용 | 선제 조건 | 상태 |
|---|------|------|----------|------|
| 00 | [00-appstore-blockers.md](00-appstore-blockers.md) | 앱스토어 블로커 해소 (PrivacyInfo, deleteAccount, CI) | 없음 | [ ] |
| 01 | [01-supabase-connect.md](01-supabase-connect.md) | Supabase 실 연결 (4개 datasource) | Task 00 | [ ] |
| 02 | [02-feature-onboarding.md](02-feature-onboarding.md) | 온보딩 (3단계 슬라이드 + 알림 opt-in) | Task 01 | [ ] |
| 03 | [03-feature-tracking.md](03-feature-tracking.md) | 자동 추적 (5개 지표) | Task 01 | [ ] |
| 04 | [04-feature-heatmap.md](04-feature-heatmap.md) | 히트맵 (활동 시각화) | Task 01, 03 | [ ] |
| 05 | [05-feature-reward-layer2.md](05-feature-reward-layer2.md) | 레이어-2 보상 (뱃지, 유료 전환 포인트) | Task 01, 03 | [ ] |
| 06 | [06-feature-auth-complete.md](06-feature-auth-complete.md) | Apple Sign In 완성 + PostHog identify | Task 01 | [ ] |
| 07 | [07-feature-calendar.md](07-feature-calendar.md) | Apple Calendar 연동 (read-only) | Task 01 | [ ] |
| 08 | [08-feature-med-reminder.md](08-feature-med-reminder.md) | 약 복용 리마인더 (APNs) | Task 02 | [ ] |
| 09 | [09-feature-iap.md](09-feature-iap.md) | 인앱 결제 인프라 (RevenueCat) | Task 05, 06 | [ ] |

---

## Phase 2 태스크 파일 형식

Phase 1과 달리 아주 상세하게 작성됨:

1. **설계 명세 (Claude Code)** — 완전한 Dart 코드 (entity, interface, state machine, SQL)
2. **Codex 프롬프트** — `codex exec "$(cat .claude/codex-prompts/taskNN-*.md)"` 바로 실행 가능
3. **구현 파일 목록** — 각 파일 경로 + 담당(Claude Code/Codex)
4. **테스트 케이스** — 입력/기대 출력 명시
5. **l10n 추가** — ARB 키 + 한국어 + 영어 값 전부
6. **Done When** — 구체적 검증 조건

---

## Claude Code / Codex 역할 구분

| Claude Code | Codex |
|-------------|-------|
| 인터페이스 / 엔티티 설계 | 모든 코드 작성 |
| 상태 머신 설계 | 보일러플레이트 |
| Supabase 스키마/RLS 설계 | 테스트 작성 |
| Codex 프롬프트 작성 | l10n ARB 추가 |
| Done When 기준 정의 | 위젯 구현 |

**규칙**: Claude Code는 코드를 작성하지 않는다. Codex 프롬프트에 설계 코드를 포함시키고 위임.

---

## 시작 방법

```bash
# 태스크 시작
/new-task {feature}

# 태스크 파일 읽기
cat .claude/tasks/phase2/NN-feature-name.md

# Codex 프롬프트 실행
codex exec "$(cat .claude/codex-prompts/taskNN-feature.md)"
```

---

## Phase 2 완료 기준

- [ ] TestFlight 제출 가능 (블로커 0개)
- [ ] 실기기: 온보딩 → 첫 세션 → 복귀 전체 플로우
- [ ] Supabase: 데이터 영속성 확인
- [ ] PostHog: 5개 KPI 이벤트 + identify 확인
- [ ] RevenueCat: Sandbox 구매 성공
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` 전체 통과
