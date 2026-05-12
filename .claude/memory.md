# Memory — Cross-Session Notes
> Format: {date} | {completed} | {next} | {notes}
> Most recent at top.

## 2026-05-12 | Task 01 완료 — Supabase 스키마 + RLS + Edge Function

- **Completed**:
  1. 5개 마이그레이션: user_profiles, tasks, sessions, distractions, mood_checks (4-way split RLS + 인덱스)
  2. 2개 보안 마이그레이션: add_constraints (CHECK 제약), security_fixes (ai_usage_log, H3/H4 수정)
  3. decompose-task Edge Function: JWT 인증 → 서비스 롤 rate limit (ai_usage_log) → Gemini 2.5 Flash → 3단계 반환
  4. flutter-reviewer HIGH 7개, MEDIUM 5개 발견 및 전부 수정
  5. 브랜치 계층 규칙 문서화 (main/develop/feat/hotfix), Co-Authored-By 금지, /done 자동 제안 규칙 추가
- **State**:
  - Branch: `feat/project-bootstrap` (develop 머지 대기)
  - 7개 마이그레이션 `supabase db reset` 전체 통과
  - Edge Function curl 테스트 통과 (remaining_today: 9)
  - `flutter analyze` zero warnings, `flutter test` 1 passed
- **Known Limitations** (다음 태스크 전 처리 권장):
  - `user_profiles.updated_at` 없음 (Phase 2 Realtime 시 추가)
  - 프로필 자동 생성 트리거 없음 (Phase 2)
  - CI Flutter 버전 미핀 + `flutter pub audit` 미적용
  - `mood_checks` UPDATE RLS (PIPA 감도 데이터)
- **Next**:
  1. feat/project-bootstrap → develop 머지
  2. Task 02: task feature 수직 슬라이스 (domain → InMemoryRepo → presentation → GoRouter)
  3. Task 02 완료 후 RemoteTaskDataSource로 교체 (Supabase 연결)

## 2026-05-12 | Task 00 완료 — 의존성 설치 + 코어 인프라 구축

- **Completed**:
  1. pubspec.yaml: flutter_riverpod 3.3.1, go_router 17.2.3, supabase_flutter 2.12.4, freezed, talker 5.1.17 등 전체 Phase 1 의존성 추가
  2. analysis_options.yaml: strict-casts/inference/raw-types + avoid_dynamic_calls/prefer_const_constructors
  3. l10n 인프라: l10n.yaml + app_ko.arb + app_en.arb (skeleton) → app_localizations.dart 자동 생성
  4. core/supabase/supabase_config.dart: dart-define 기반 SupabaseConfig
  5. core/providers/supabase_provider.dart: Provider<SupabaseClient>
  6. core/logging/log_context_provider.dart: NotifierProvider (Riverpod 3.x — StateProvider 제거됨)
  7. core/logging/logger_service.dart: LoggerService + appTalker (모듈 수준 공유 Talker)
  8. core/router/app_router.dart: GoRouter 플레이스홀더 (Task 02에서 실제 라우트 추가)
  9. main.dart: ProviderScope + TalkerRiverpodObserver + 조건부 Supabase.initialize + l10n
  10. .env.example 생성
- **State**:
  - Branch: `feat/project-bootstrap`
  - Validation: `flutter analyze` 경고 0, `flutter test` 통과, iOS/macOS 빌드 성공
  - Riverpod 3.x 변경 사항: StateProvider 제거 → NotifierProvider 사용
  - Supabase 초기화: SUPABASE_URL이 비어있으면 skip (Task 01에서 실제 프로젝트 생성 후 주입)
- **Next**:
  1. Task 01: Supabase 스키마 + RLS + Edge Function (decompose-task) 설정
  2. Task 02: task 피처 수직 슬라이스 — domain → LocalRepositoryImpl → presentation → GoRouter 라우트
  3. Task 02 완료 후: RemoteTaskDataSource로 교체 (Supabase 연결)
- **Notes**:
  - Riverpod 3.x: @riverpod 어노테이션 사용 시 build_runner 필요 (Task 02에서 첫 실행)
  - posthog_flutter macOS 빌드에서 Xcode C++ 경고 있음 — pod 내부 코드, 무시 가능

## 2026-05-11 | Harness governance finalized + Flutter bootstrap initialized
- **Completed**:
  1. Harness governance and approval flow finalized (proposal → approval → execution → report).
  2. Agent boundaries clarified (Claude orchestrator, Codex implementer, user as final decision authority).
  3. CI/security baseline added (`.gitignore`, `quality-gates.yml`, pre-commit policy docs).
  4. Flutter iOS/macOS project initialized in-place with valid package name (`ownurtime`).
  5. Feature-first folder skeleton created under `lib/` and `test/features/`.
  6. Bootstrap app connected (`MaterialApp.router`, `AppTheme`, minimal `AppRouter`) and test updated.
- **State**:
  - Branch: `feat/project-bootstrap`
  - Recent commits:
    - `40565ed` Feat: 앱 부트스트랩 라우터/테마 연결
    - `4c9473d` Chore: 커밋 전 빌드 검증 규칙 강화
  - Validation passed: `flutter analyze`, `flutter test`, `flutter build ios --simulator --debug`, `flutter build macos --debug`
- **Next**:
  1. Start first minimal vertical slice for `task` feature (data → domain → presentation → tests).
  2. Introduce minimal router route(s) for task entry screen.
  3. Define local-first temporary data flow before Supabase wiring.
  4. After slice is stable, proceed to Supabase datasource integration.
- **Notes**:
  - Keep split commits: app code vs governance/docs.
  - Continue approval gate on important decisions/high-impact changes.

## 2026-05-11 | Harness environment setup + English conversion
- **Completed**: CLAUDE.md, AGENTS.md, .claude/ harness files created and converted to English
- **State**: MVP dev environment ready. Flutter project not yet initialized.
- **Next**:
  1. `flutter create --org com.ownurtime --platforms ios,macos .`
  2. Create Supabase project, configure .env
  3. Start Phase 1 tasks → `/new-task task`
- **Notes**: Solo dev, iOS+macOS first. Claude Code = arch/logic, Codex = impl/tests.
