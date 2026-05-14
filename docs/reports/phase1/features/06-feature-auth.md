---
task: 06-feature-auth
phase: 1
date: 2026-05-14
agent: Claude Code + Codex
status: complete
---

# Feature Report: Auth / Guest Mode First

## Summary

Guest-first 인증 흐름을 구현했다. RULE 12에 따라 3번째 세션 완료 전까지 로그인 강요 없이 모든 Phase 1 기능이 동작한다. 세션 완료 카운터를 `flutter_secure_storage`에 저장하고, 3회 완료 시 비차단형 `SignInPromptSheet`를 표시한다. Apple Sign In 성공 시 로컬 게스트 데이터(tasks + sessions)를 인증 사용자로 마이그레이션한다. Phase 1은 in-memory 저장소만 사용하므로 실제 Supabase 업로드는 Phase 2에서 수행된다.

## Architecture Decisions

- **Decision**: `@Riverpod(keepAlive: true)` AuthNotifier로 앱 생명주기 전체 인증 상태 유지 | **Reason**: 세션 완료 카운터가 여러 화면에서 접근되며, 재빌드 시 초기화 방지 필요
- **Decision**: `SignInPromptNotifier`를 `@riverpod` (auto-dispose, in-memory only)로 선언 | **Reason**: 앱 재시작 시 dismiss 상태 초기화 = "오늘 이후 다시 표시 가능" 의도와 일치
- **Decision**: `onAuthStateChange` 스트림 + Completer로 OAuth 콜백 대기 | **Reason**: `signInWithOAuth`는 브라우저를 열고 즉시 반환하므로, 직후 `currentUser` 읽기는 항상 null
- **Decision**: `taskRepositoryProvider`를 `task/data/providers/task_data_providers.dart`로 이동, presentation layer에서 export | **Reason**: `auth/data/` 레이어가 `task/presentation/`에 의존하면 RULE 04 위반
- **Decision**: `MigrateLocalDataUseCase`를 `auth/domain/usecases/`에 배치하고 TaskRepository + SessionRepository를 주입 | **Reason**: cross-feature 데이터 이전은 auth 도메인의 sign-in 흐름에 종속되며, application-layer coordinator 역할을 함

## Implementation Notes

- Riverpod 3.x에서 `@riverpod` 코드젠 결과: `authProvider` (not `authNotifierProvider`), `signInPromptProvider` (not `signInPromptNotifierProvider`) — 초기 구현에서 naming mismatch 발생, sed로 일괄 수정
- `AsyncValue.valueOrNull`이 Riverpod 3.x에 없음 → `.value` (T?) 또는 `.asData?.value` 사용
- auto-dispose provider를 `container.listen` 없이 `ref.read`만 하면 tap 후 위젯 unmount 시 state가 disposal됨 → `sign_in_prompt_sheet_test`에서 `container.listen`으로 해결
- `flutter gen-l10n`은 `l10n.yaml` 존재 시 CLI 인자 무시 — ARB 수정 후 빌드 시 자동 재생성

## Test Coverage

| Layer | 테스트 |
|-------|--------|
| domain (AuthNotifier) | 5개 — guest init, increment×3, increment when authenticated (무시), signInWithApple 성공, signOut |
| presentation (SignInPromptSheet) | 2개 — Apple 버튼 렌더링, 나중에 탭 → dismiss state=true |
| 전체 regression | 48/48 pass |

## Known Limitations / Tech Debt

- [ ] **Phase 2**: `TimerNotifier`가 `_guestUserId = 'guest'` 고정 사용 중 — 인증 후에도 세션이 guest로 저장됨. 로그인 완료 후 `AuthNotifier.state.userId`에서 읽어야 함 (migration으로 일단 보완되나 장기적으로 수정 필요)
- [ ] **Phase 2**: `_complete()`의 `incrementSessionCompletionCount().ignore()` — Keychain write 실패 시 카운터 불일치 가능. async `_complete()` 전환 또는 error boundary 추가 필요
- [ ] **Phase 2**: `MigrateLocalDataUseCase` 비원자적 — tasks 이전 후 sessions 이전 실패 시 partial migration. Supabase batch transaction으로 교체 예정
- [ ] **수동 설정 필요**: iOS `Info.plist` CFBundleURLSchemes `com.ownurtime.app`, macOS `Info.plist` 동일, Xcode Sign In with Apple capability, Supabase dashboard Apple provider + redirect URL

## Key Files

**신규**
- `lib/features/auth/domain/entities/app_user.dart` — Freezed AppUser
- `lib/features/auth/domain/entities/auth_state.dart` — sealed AuthState (guest / authenticated)
- `lib/features/auth/domain/repositories/auth_repository.dart` — repository interface
- `lib/features/auth/domain/usecases/migrate_local_data_usecase.dart` — cross-feature migration
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` — Supabase OAuth (onAuthStateChange 패턴)
- `lib/features/auth/data/datasources/auth_local_datasource.dart` — flutter_secure_storage wrapper
- `lib/features/auth/data/providers/auth_providers.dart` — DI 체인
- `lib/features/auth/presentation/providers/auth_provider.dart` — AuthNotifier + SignInPromptNotifier
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/widgets/sign_in_prompt_sheet.dart`
- `lib/features/task/data/providers/task_data_providers.dart` — 레이어 분리를 위해 task repo provider를 data layer로 이동

**수정**
- `lib/features/session/presentation/providers/timer_provider.dart` — `_complete()`에서 `authProvider.incrementSessionCompletionCount()` 호출 추가
- `lib/features/session/presentation/screens/session_screen.dart` — `ref.listen<AsyncValue<AuthState>>(authProvider, ...)` 추가, 3회 완료 시 bottom sheet 표시
- `lib/features/task/domain/repositories/task_repository.dart` — `migrateToUser` 추가
- `lib/features/session/domain/repositories/session_repository.dart` — `getSessions` + `migrateToUser` 추가
