import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/features/auth/data/providers/auth_providers.dart';
import 'package:ownurtime/features/auth/domain/entities/app_user.dart';
import 'package:ownurtime/features/auth/domain/entities/auth_state.dart';
import 'package:ownurtime/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:ownurtime/features/auth/domain/repositories/auth_repository.dart';
import 'package:ownurtime/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:ownurtime/features/auth/domain/usecases/migrate_local_data_usecase.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';
import 'package:ownurtime/features/session/domain/entities/session.dart';
import 'package:ownurtime/features/session/domain/repositories/session_repository.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';

class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo({this.deleteError, this.persistedUser});

  final Object? deleteError;
  final AppUser? persistedUser;

  @override
  Future<void> deleteAccount(String userId) async {
    final error = deleteError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<AppUser?> getPersistedUser() async => persistedUser;

  @override
  Future<int> getSessionCompletionCount() async => 0;

  @override
  Future<void> saveSessionCompletionCount(int count) async {}

  @override
  Future<AppUser> signInWithApple() async =>
      const AppUser(id: 'user-123', email: 'test@example.com');

  @override
  Future<void> signOut() async {}
}

class _FakeTaskRepo implements TaskRepository {
  @override
  Future<Task> createTask(String userId, String title) async =>
      throw UnimplementedError();

  @override
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId,
    String title,
  ) async => throw UnimplementedError();

  @override
  Future<List<Task>> getTasks(String userId) async => const [];

  @override
  Future<void> migrateToUser({
    required List<Task> tasks,
    required String newUserId,
  }) async {}

  @override
  Future<void> updateTask(Task task) async => throw UnimplementedError();
}

class _FakeSessionRepo implements SessionRepository {
  @override
  Future<Session> abandonSession(String sessionId) async =>
      throw UnimplementedError();

  @override
  Future<Session> completeSession(String sessionId) async =>
      throw UnimplementedError();

  @override
  Future<List<Session>> getSessions(String userId) async => const [];

  @override
  Future<void> migrateToUser({
    required List<Session> sessions,
    required String newUserId,
  }) async {}

  @override
  Future<Session> startSession({
    required String userId,
    String? taskId,
    required int targetDurationMinutes,
    required bool manualWorkMode,
  }) async => throw UnimplementedError();

  @override
  Future<Session> updateSession(Session session) async =>
      throw UnimplementedError();
}

class _FakeMigrateLocalDataUseCase extends MigrateLocalDataUseCase {
  _FakeMigrateLocalDataUseCase()
    : super(
        taskRepository: _FakeTaskRepo(),
        sessionRepository: _FakeSessionRepo(),
      );
}

void main() {
  group('DeleteAccountUseCase', () {
    test('TC-01: deleteAccount 성공', () async {
      final repo = _FakeAuthRepo();
      final useCase = DeleteAccountUseCase(repo);

      await expectLater(useCase('user-123'), completes);
    });

    test('TC-02: deleteAccount 네트워크 오류', () async {
      final repo = _FakeAuthRepo(
        deleteError: const DeleteAccountException('network_error'),
      );
      final useCase = DeleteAccountUseCase(repo);

      await expectLater(
        useCase('user-123'),
        throwsA(isA<DeleteAccountException>()),
      );
    });

    test('TC-03: 게스트 상태에서 AuthNotifier.deleteAccount() 호출', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
          migrateLocalDataUseCaseProvider.overrideWithValue(
            _FakeMigrateLocalDataUseCase(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      await container.read(authProvider.future);
      final before = container.read(authProvider).value;

      await expectLater(notifier.deleteAccount(), completes);

      final after = container.read(authProvider).value;
      expect(before, const AuthState.guest(sessionCompletionCount: 0));
      expect(after, const AuthState.guest(sessionCompletionCount: 0));
    });

    test('TC-07: 인증 상태에서 deleteAccount() → guest로 전환', () async {
      final authenticatedRepo = _FakeAuthRepo(
        persistedUser: const AppUser(id: 'user-123', email: 'test@example.com'),
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authenticatedRepo),
          migrateLocalDataUseCaseProvider.overrideWithValue(
            _FakeMigrateLocalDataUseCase(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.future);
      expect(
        container.read(authProvider).value,
        const AuthState.authenticated(
          user: AppUser(id: 'user-123', email: 'test@example.com'),
        ),
      );

      final notifier = container.read(authProvider.notifier);
      await notifier.deleteAccount();
      await container.read(authProvider.future);

      expect(
        container.read(authProvider).value,
        const AuthState.guest(sessionCompletionCount: 0),
      );
    });
  });
}
