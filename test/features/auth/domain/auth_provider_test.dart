import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/features/auth/data/providers/auth_providers.dart';
import 'package:ownurtime/features/auth/domain/entities/app_user.dart';
import 'package:ownurtime/features/auth/domain/entities/auth_state.dart';
import 'package:ownurtime/features/auth/domain/repositories/auth_repository.dart';
import 'package:ownurtime/features/auth/domain/usecases/migrate_local_data_usecase.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';
import 'package:ownurtime/features/session/domain/entities/session.dart';
import 'package:ownurtime/features/session/domain/repositories/session_repository.dart';
import 'package:ownurtime/features/task/domain/entities/task.dart';
import 'package:ownurtime/features/task/domain/repositories/task_repository.dart';

class FakeAuthRepository implements AuthRepository {
  int _count = 0;
  AppUser? _persistedUser;

  @override
  Future<int> getSessionCompletionCount() async => _count;

  @override
  Future<void> saveSessionCompletionCount(int count) async {
    _count = count;
  }

  @override
  Future<AppUser> signInWithApple() async {
    final user = const AppUser(id: 'u1', email: 'test@test.com');
    _persistedUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _persistedUser = null;
  }

  @override
  Future<AppUser?> getPersistedUser() async => _persistedUser;

  @override
  Future<void> deleteAccount(String userId) async {}
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
  Future<void> updateTask(Task task) async {}
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

class FakeMigrateLocalDataUseCase extends MigrateLocalDataUseCase {
  FakeMigrateLocalDataUseCase()
    : super(
        taskRepository: _FakeTaskRepo(),
        sessionRepository: _FakeSessionRepo(),
      );
}

void main() {
  group('AuthNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          migrateLocalDataUseCaseProvider.overrideWithValue(
            FakeMigrateLocalDataUseCase(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('build()는 guest(count=0) 상태를 반환한다', () async {
      final state = await container.read(authProvider.future);
      expect(state, const AuthState.guest(sessionCompletionCount: 0));
    });

    test('incrementSessionCompletionCount()를 3회 호출하면 count가 3이 된다', () async {
      await container.read(authProvider.future);
      final notifier = container.read(authProvider.notifier);

      await notifier.incrementSessionCompletionCount();
      await notifier.incrementSessionCompletionCount();
      await notifier.incrementSessionCompletionCount();

      final state = container.read(authProvider).value;
      expect(state, const AuthState.guest(sessionCompletionCount: 3));
    });

    test(
      'authenticated 상태에서 incrementSessionCompletionCount()는 무시된다',
      () async {
        await container.read(authProvider.future);
        final notifier = container.read(authProvider.notifier);

        await notifier.signInWithApple();
        await notifier.incrementSessionCompletionCount();

        final state = container.read(authProvider).value;
        expect(state, isA<AuthAuthenticated>());
        final completionCount = state?.sessionCompletionCount;
        expect(completionCount, 0);
      },
    );

    test('signInWithApple() 성공 시 AuthAuthenticated 상태가 된다', () async {
      await container.read(authProvider.future);
      final notifier = container.read(authProvider.notifier);

      await notifier.signInWithApple();

      final state = container.read(authProvider).value;
      expect(state, isA<AuthAuthenticated>());
    });

    test('signOut() 호출 시 AuthGuest(count=0) 상태가 된다', () async {
      await container.read(authProvider.future);
      final notifier = container.read(authProvider.notifier);

      await notifier.signInWithApple();
      await notifier.signOut();

      final state = container.read(authProvider).value;
      expect(state, const AuthState.guest(sessionCompletionCount: 0));
    });
  });
}
