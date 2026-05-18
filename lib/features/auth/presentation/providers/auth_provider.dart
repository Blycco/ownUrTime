import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ownurtime/features/auth/data/providers/auth_providers.dart';
import 'package:ownurtime/features/auth/domain/entities/auth_state.dart';
import 'package:ownurtime/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:ownurtime/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:ownurtime/features/auth/domain/usecases/sign_out_usecase.dart';

part 'auth_provider.g.dart';

/// 로그인 프롬프트 해제 상태 — in-memory only (앱 재시작 시 초기화).
@riverpod
class SignInPromptNotifier extends _$SignInPromptNotifier {
  @override
  bool build() => false;

  void dismiss() => state = true;
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final user = await repo.getPersistedUser();
    if (user != null) return AuthState.authenticated(user: user);
    final count = await repo.getSessionCompletionCount();
    return AuthState.guest(sessionCompletionCount: count);
  }

  /// 세션 완료 시 TimerNotifier._complete()에서 호출.
  Future<void> incrementSessionCompletionCount() async {
    final current = state.value;
    if (current == null || current is! AuthGuest) return;
    final newCount = current.sessionCompletionCount + 1;
    final repo = ref.read(authRepositoryProvider);
    await repo.saveSessionCompletionCount(newCount);
    state = AsyncData(AuthState.guest(sessionCompletionCount: newCount));
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final migrateUseCase = ref.read(migrateLocalDataUseCaseProvider);
      final user = await SignInWithAppleUseCase(repo)();

      try {
        await migrateUseCase(
          guestUserId: 'guest',
          authenticatedUserId: user.id,
        );
      } on Exception {
        // 마이그레이션 실패는 치명적이지 않음 — 데이터는 로컬에 유지
      }

      await repo.saveSessionCompletionCount(0);
      state = AsyncData(AuthState.authenticated(user: user));
    } on Exception catch (e, st) {
      try {
        final repo = ref.read(authRepositoryProvider);
        final count = await repo.getSessionCompletionCount();
        state = AsyncData(AuthState.guest(sessionCompletionCount: count));
      } on Exception {
        // Storage failure during recovery — fall back to count=0 to avoid
        // leaving the provider permanently stuck in AsyncLoading.
        state = const AsyncData(AuthState.guest());
      }
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await SignOutUseCase(repo)();
      await repo.saveSessionCompletionCount(0);
      state = const AsyncData(AuthState.guest());
    } on Exception catch (e, st) {
      // Restore a usable state rather than leaving the UI stuck in loading.
      state = const AsyncData(AuthState.guest());
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> deleteAccount() async {
    final currentState = state.value;
    if (currentState == null) return;
    final userId = currentState.whenOrNull(authenticated: (user) => user.id);
    if (userId == null) return;

    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final useCase = DeleteAccountUseCase(repo);
      await useCase(userId);
      state = const AsyncData(AuthState.guest());
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
