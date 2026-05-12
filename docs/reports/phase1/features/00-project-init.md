---
task: 00-project-init
phase: 1
date: 2026-05-12
agent: Claude Code
status: complete
---

# Feature Report: Project Initialization

## Summary
Phase 1 전체 의존성과 코어 인프라를 구축했다. Flutter 부트스트랩 위에 Riverpod 3.x, GoRouter, Supabase Flutter, Talker 로깅, l10n 스켈레톤을 올리고, strict 린트 규칙과 조건부 Supabase 초기화 패턴을 확립해 이후 모든 피처 작업의 기반을 만들었다.

## Architecture Decisions
- Decision: `appTalker` 를 모듈 수준 변수로 선언해 `LoggerService`와 `TalkerRiverpodObserver`가 동일 인스턴스 공유 | Reason: `ProviderScope` 생성 전에 `Talker`가 필요하므로 DI 컨테이너 바깥에 위치시켜야 함
- Decision: `Supabase.initialize()`를 `SUPABASE_URL` 비어있을 때 skip | Reason: Task 01 이전까지 Supabase 프로젝트가 없으므로 로컬 실행 가능하게 함
- Decision: `StateProvider` 대신 `NotifierProvider` 사용 | Reason: Riverpod 3.x에서 `StateProvider` API 제거됨 (별도 ADR 참조)

## Implementation Notes
- `flutter_localizations`는 SDK 패키지라 `flutter pub add`로 추가 불가 → pubspec.yaml 직접 편집
- `intl: any` 로 명시해 flutter_localizations의 내부 버전과 충돌 방지
- `analysis_options.yaml`의 `exclude` 에 `*.g.dart`, `*.freezed.dart` 추가 → 코드 생성 파일에서 strict 규칙 false alarm 방지
- macOS 빌드 시 posthog_flutter pod의 C++ 코드에서 Xcode 경고 발생 — pod 내부 코드로 무시 가능

## Test Coverage
| Layer | Coverage |
|-------|----------|
| core/router | 100% (GoRouter bootstrap 렌더 1개 테스트) |
| core/logging | 0% (LoggerService 단위 테스트 미작성 — Task 02 이후 통합) |
| core/theme | 0% (정적 설정값, 테스트 불필요) |

## Known Limitations / Tech Debt
- [ ] `l10n` ARB 파일은 스켈레톤 (2개 키만) — Task 08에서 채움
- [ ] `LoggerService` 단위 테스트 없음 — 각 피처 테스트에서 fake 주입으로 간접 검증
- [ ] `posthog_flutter` 초기화 코드 없음 — Task 09 (Analytics)에서 추가

## Key Files
- `pubspec.yaml` — Phase 1 전체 의존성
- `analysis_options.yaml` — strict lint 규칙
- `l10n.yaml` + `lib/core/l10n/app_ko.arb` / `app_en.arb`
- `lib/core/supabase/supabase_config.dart`
- `lib/core/providers/supabase_provider.dart`
- `lib/core/logging/logger_service.dart`
- `lib/core/logging/log_context_provider.dart`
- `lib/core/router/app_router.dart`
- `lib/main.dart`
