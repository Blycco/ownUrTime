# Feature Report: Task 04 — Distraction Recovery Flow

**완료일:** 2026-05-14  
**이슈:** #8 | **브랜치:** feat/feature-recovery  
**PRD 참조:** Section 5-3

---

## 구현 요약

ADHD 사용자가 집중이 흐트러진 후 2× 빠르게 복귀할 수 있는 Recovery Flow를 구현했다.

### 신규 파일

| 파일 | 설명 |
|------|------|
| `lib/features/recovery/domain/entities/distraction.dart` | DistractionType enum + Distraction 엔티티 |
| `lib/features/recovery/domain/repositories/distraction_repository.dart` | 추상 인터페이스 |
| `lib/features/recovery/domain/usecases/log_distraction_usecase.dart` | distraction 기록 |
| `lib/features/recovery/domain/usecases/recover_session_usecase.dart` | 복귀 컨텍스트 생성 |
| `lib/features/recovery/data/` | InMemory datasource + model + repository impl |
| `lib/features/recovery/presentation/screens/recovery_screen.dart` | 4단계 복귀 화면 |
| `lib/features/recovery/presentation/widgets/context_restore_card.dart` | 이전 작업 컨텍스트 카드 |
| `test/features/recovery/` | domain 3개 + presentation 1개 |

### 수정 파일

| 파일 | 변경 내용 |
|------|----------|
| `timer_provider.dart` | `declareDistraction()` 수정, `resumeFromDistraction()` 추가 |
| `session_screen.dart` | `handleDistraction()` + `taskTitle` 파라미터 추가 |
| `app_router.dart` | `/recovery` 라우트 추가 |
| `app_ko.arb` + `app_en.arb` | recovery l10n 키 추가 |

---

## 아키텍처 결정

- Recovery는 `/recovery` 별도 GoRoute로 분리 (overlay 아님)
- `TimerState` sealed class 변경 없음 — distraction context는 별도 provider
- InMemory datasource (Task 06에서 Supabase 전환)
- 로깅 실패 시 타이머 pause 유지 + recovery 화면 표시 (UX 보호)
- 버튼 연타 race condition 방지: `_isSelecting` 플래그

---

## UX 구현 (PRD Section 5-3)

- **No-shame framing**: urgent/impulsive/rest 각각 긍정 메시지
- **External working memory**: ContextRestoreCard로 작업 제목 + 경과 시간 표시
- **1-tap resume**: 컨텍스트 카드 → "다시 시작" 1탭으로 타이머 재개
- **Error resilience**: 로깅 실패 시에도 복귀 버튼 항상 활성 (RULE 07)

---

## QA 결과

- flutter analyze: clean
- flutter test: 29/29 통과
- flutter-reviewer: HIGH 2건 수정 완료
- Codex 비관적 리뷰: HIGH 3건 수정 완료

전체 QA → `docs/05_test_results/integration/04-recovery.md`

---

## 알려진 기술부채

- `timer_provider`가 `recovery/data` 레이어에 직접 의존 → Task 06에서 분리
- `taskTitle` Phase 05~06 이전까지 빈 문자열 가능
