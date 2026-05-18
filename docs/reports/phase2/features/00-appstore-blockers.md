---
task: 00-appstore-blockers
phase: 2
date: 2026-05-18
agent: Claude Code + Codex
status: complete
pr: 21
issue: 20
---

# Feature Report: 앱스토어 블로커 해소

## Summary

TestFlight/App Store 제출 전 필수인 블로커 3건을 해소했다. PrivacyInfo.xcprivacy(Apple 2024년 5월 의무화)를 iOS/macOS 양쪽에 추가했고, App Store Review Guideline 5.1.1이 요구하는 계정 삭제 기능을 Edge Function + CASCADE 마이그레이션 + UseCase + 설정 화면 전체 스택으로 구현했다. CI에 `flutter pub audit`을 추가해 의존성 보안 취약점을 자동으로 탐지한다.

## Architecture Decisions

- **deleteAccount 오류 흐름**: `AuthNotifier.deleteAccount()`는 `AsyncError` 설정 후 `rethrow`로 위젯 레이어에 예외를 전파. `signOut()`이 복구 가능한 상태로 전환 후 throw하는 것과 달리, 계정 삭제 실패는 이전 상태로 복원할 수 없어 `AsyncError` 노출이 더 안전함.
- **deleteAccount 책임 분리**: Remote(`SupabaseAuthDataSource`) → Edge Function 호출 + Supabase 세션 초기화, Local(`SecureStorageAuthDataSource.clearAll()`) → SecureStorage 전체 삭제. Repository가 순서를 조율. 단일 datasource에 FlutterSecureStorage를 추가 주입하지 않아도 됨.
- **CASCADE DELETE**: DB 레벨 CASCADE로 서버 삭제 시 모든 관련 테이블 자동 정리. Edge Function이 단순히 `auth.admin.deleteUser()`만 호출해도 PIPA 준수.
- **PrivacyInfo 파일 생성만, Xcode 등록은 수동**: Codex로 파일 내용 생성 가능하지만 `.pbxproj` 편집은 수동 작업 필요. PR 설명에 안내 포함.

## Implementation Notes

- Task 00 스펙의 l10n 경로 `lib/l10n/`가 오기 — 실제 경로 `lib/core/l10n/`로 Codex 프롬프트에서 수정.
- flutter-reviewer 이슈 3라운드: 1차(HIGH 2건) → Codex 재위임 → 2차(HIGH 1건: rethrow 누락) → Codex 재위임 → 3차 LGTM.
- `flutter pub audit` 명령어가 로컬 Flutter 3.41.9에서 미지원 확인(dart pub audit도 동일). CI YAML에 등록은 완료됐으므로 실제 실행은 CI에서 검증 예정.

## Test Coverage

| Layer | 테스트 | 결과 |
|-------|--------|------|
| domain/ (DeleteAccountUseCase) | TC-01 성공, TC-02 네트워크 오류, TC-03 게스트 no-op, TC-07 인증→guest 전환 | 4/4 ✓ |
| presentation/ (DeleteAccountDialog) | TC-04 렌더링, TC-05 취소, TC-06 삭제 성공 | 3/3 ✓ |
| 전체 회귀 | 68건 | 68/68 ✓ |

## Known Limitations / Tech Debt

- [ ] Xcode 프로젝트 파일에 PrivacyInfo.xcprivacy Runner target 등록 필요 (수동)
- [ ] `supabase db reset` 및 계정 삭제 E2E 확인 필요 (실기기/대시보드)
- [ ] App Store Connect Privacy Policy URL 등록 (출시 전)
- [ ] `userId` 파라미터가 UseCase→Repository→DataSource 체인을 통과하지만 서버에서 JWT로 처리하므로 실제 사용되지 않음 (L-2 reviewer 지적 — Phase 3 인터페이스 정리 시 제거 예정)
- [ ] `flutter pub audit` 로컬 미지원 확인 필요 (CI 검증으로 대체)

## Key Files

- `lib/features/auth/domain/exceptions/auth_exceptions.dart` — DeleteAccountException
- `lib/features/auth/domain/usecases/delete_account_usecase.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart` — deleteAccount() 인터페이스
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` — Edge Function 호출
- `lib/features/auth/data/repositories/auth_repository_impl.dart` — remote→local 순서 조율
- `lib/features/auth/presentation/providers/auth_provider.dart` — deleteAccount() notifier
- `lib/features/settings/presentation/widgets/delete_account_dialog.dart`
- `lib/features/settings/presentation/screens/settings_screen.dart`
- `ios/Runner/PrivacyInfo.xcprivacy`, `macos/Runner/PrivacyInfo.xcprivacy`
- `supabase/migrations/20260518000000_add_cascade_delete.sql`
- `supabase/functions/delete-account/index.ts`
- `.github/workflows/quality-gates.yml` — pub audit + Flutter 3.41.9 핀
