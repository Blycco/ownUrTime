---
task: 05-feature-mood
phase: 1
date: 2026-05-14
agent: Claude Code + Codex
status: complete
---

# Feature Report: Mood Check

## Summary
세션 시작 전·후 사용자 컨디션(mood 1–5)을 이모지 1-tap으로 기록하고, 레벨에 따라 세션 권장 시간(10/15/25분)을 `DurationSelector`에 자동 pre-fill하는 기능을 구현했다. ADHD 동반 우울/불안 비율(47%/19–32%)을 고려해 낮은 mood → 짧은 세션을 유도, "컨디션이 나빠도 시작할 수 있다"는 심리적 장벽 완화가 목표. `MoodCheckNotifier`의 `keepAlive: true` sealed state가 "당일 첫 세션 전만 표시, 이후 세션엔 미표시" 타이밍 룰을 서버 없이 구현한다.

## Architecture Decisions
- **Decision**: `CheckMoodUseCase`가 `(MoodCheck, int suggestedMinutes)` Dart record를 반환 | **Reason**: suggestedMinutes는 presentation 관심사(UI pre-fill)이므로 domain entity에 포함시키지 않고 UseCase 계층에서 계산·전달
- **Decision**: `MoodCheckWidget`을 순수 StatelessWidget(callback 기반)으로 구현 | **Reason**: Riverpod 미결합 → 위젯 테스트 ProviderScope 불필요, 재사용성 극대화
- **Decision**: `MoodCheckNotifier(keepAlive: true)` sealed state로 타이밍 관리 | **Reason**: Phase 1 in-memory에서 날짜 persistence 없이 "당일 첫 세션" 판별; `pending`→`done` 전이가 세션 간 유지되어 2번째 세션 idle 시 mood widget 미표시를 자동 처리

## Implementation Notes
- `codex exec` 백그라운드 실행 시 stdin hang 문제 반복 발생 → 프롬프트를 `/tmp` 파일로 저장 후 `$(cat file)` 방식으로 우회
- build_runner가 `mood_check_provider.dart` 코드 생성 시 provider 이름을 `moodCheckProvider`로 생성 (`moodCheckNotifierProvider` 아님) — riverpod_annotation 4.x 명명 규칙
- 기존 `session_screen_test.dart` 2개 테스트가 idle 상태에서 `DurationSelector`를 바로 기대하여 실패 → 테스트 헬퍼에 mood skip 단계 추가로 수정

## Test Coverage
| Layer | 항목 | 결과 |
|-------|------|------|
| domain/usecases | CheckMoodUseCase — 7개 (레벨별 suggestion, saveMoodCheck 검증, entity 반환) | ✅ 100% |
| domain/usecases | GetTodayMoodChecksUseCase | 직접 테스트 없음 (widget 통합으로 커버) |
| data/ | InMemoryMoodDataSource, MoodRepositoryImpl | Phase 1 정책상 직접 단위 테스트 없음 |
| presentation/widgets | MoodCheckWidget — 5개 (이모지 5개 표시, 레벨 콜백, skip 콜백) | ✅ 100% |

전체: 41/41 통과 (신규 12개 포함)

## Known Limitations / Tech Debt
- [ ] Phase 2: `InMemoryMoodDataSource` → Supabase `mood_checks` 테이블로 교체 필요
- [ ] Phase 2: `MoodCheckNotifier` build()에서 `getTodayMoodChecksUseCase`로 오늘 체크 여부 초기 로드 필요 (앱 재시작 시 state 초기화됨)
- [ ] `GetTodayMoodChecksUseCase` 단위 테스트 누락 — Phase 2 데이터 레이어 교체 시 추가
- [ ] Supabase RLS 정책 미구현 (Phase 1 in-memory이므로 해당 없음, Phase 2 필수)

## Key Files
- `lib/features/mood/domain/entities/mood_check.dart` — freezed entity
- `lib/features/mood/domain/usecases/check_mood_usecase.dart` — level → suggestedMinutes 핵심 로직
- `lib/features/mood/presentation/providers/mood_check_provider.dart` — 타이밍 sealed state
- `lib/features/mood/presentation/widgets/mood_check_widget.dart` — 이모지 UI
- `lib/features/mood/data/providers/mood_providers.dart` — Riverpod DI 체인
- `lib/features/session/presentation/screens/session_screen.dart` — idle/completed 트리거 통합
- `lib/features/session/presentation/widgets/duration_selector.dart` — suggestedMinutes pre-fill
