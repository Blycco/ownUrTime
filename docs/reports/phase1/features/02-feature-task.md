---
task: 02-feature-task
phase: 1
date: 2026-05-13
agent: Claude Code + Codex
status: complete
---

# Feature Report: Task

## Summary

Task feature Phase 1 수직 슬라이스 완료. ADHD 사용자의 착수(initiation) 장벽을 낮추는 핵심 기능으로, 제목 없이 1탭으로 작업을 시작할 수 있는 흐름과 AI 분해 기능 (InMemory stub)을 구현했다. Supabase 미연결 상태에서 InMemoryTaskDataSource로 전체 레이어를 검증하는 수직 슬라이스 전략을 채택했다.

## Architecture Decisions

- Decision: Phase 1은 InMemoryTaskDataSource 사용, RemoteTaskDataSource는 stub만 정의 | Reason: Supabase 연결 전 UI/UX 흐름 검증 우선. Phase 2에서 교체.
- Decision: AI limit counter를 client-side InMemory로 구현 | Reason: Phase 1 stub용 UI guard. 권위 있는 rate limit은 Supabase Edge Function (decompose-task)에서 처리.
- Decision: `decomposeTask` 반환 타입으로 Dart record type `({List<String> steps, int remainingToday})` 사용 | Reason: Phase 1 도메인에서 별도 값 객체 정의 없이 간결하게 표현 가능. Phase 2 실제 연결 시 재검토.
- Decision: 한국어 stub 문자열 대신 영문 placeholder 사용 | Reason: RULE 06 (hardcoded Korean 금지). 실제 AI 생성 단계(Phase 2)에서 대체됨.

## Implementation Notes

- `InMemoryTaskDataSource`의 `_remainingToday`는 인스턴스 상태라 ProviderScope 유지 중에만 유효. 앱 재시작 시 10으로 초기화됨 (stub 의도된 동작).
- `dart format` pre-commit hook이 13개 파일 자동 포맷 → 포맷된 파일 재스테이지 후 커밋 필요했음.
- Codex `codex exec "..."` 방식이 stdin 대기로 블록됨 → `cat << 'EOF' | codex exec` heredoc 방식으로 해결.

## Test Coverage

| Layer | Tests | Pass |
|-------|-------|------|
| domain/usecases | 4 | 4/4 |
| data/datasource | 2 | 2/2 |
| data/repository | 2 | 2/2 |
| presentation/widgets | 3 | 3/3 |
| widget (통합) | 3 | 3/3 |
| **Total** | **14** | **14/14** |

## Known Limitations / Tech Debt

- [ ] `InMemoryTaskDataSource._remainingToday` — 앱 재시작 시 리셋. Phase 2에서 Supabase ai_usage_log로 교체.
- [ ] `task_remote_datasource.dart` — 모든 메서드 `UnimplementedError`. Phase 2 Supabase 연결 시 구현.
- [ ] `createTask` 시 decomposedSteps 미전달 — decompose 후 시작해도 Task entity에 steps 미저장. Phase 2 범위.
- [ ] AI 단계 문자열 현재 영문 placeholder — Phase 2 Gemini Edge Function 연결 시 실제 AI 생성 내용으로 대체.

## Key Files

- `lib/features/task/domain/entities/task.dart` — Task entity, TaskStatus enum
- `lib/features/task/domain/repositories/task_repository.dart` — 추상 인터페이스
- `lib/features/task/data/datasources/in_memory_task_datasource.dart` — Phase 1 stub (counter 포함)
- `lib/features/task/presentation/providers/task_provider.dart` — TaskListNotifier, DecomposeTaskNotifier
- `lib/features/task/presentation/screens/task_list_screen.dart` — 메인 태스크 목록
- `lib/features/task/presentation/screens/task_start_screen.dart` — 착수 화면 (1탭 시작, AI 분해)
- `lib/features/task/presentation/widgets/ai_limit_indicator.dart` — AI 한도 UX
