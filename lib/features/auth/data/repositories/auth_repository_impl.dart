import 'package:ownurtime/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ownurtime/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ownurtime/features/auth/domain/entities/app_user.dart';
import 'package:ownurtime/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<int> getSessionCompletionCount() => _local.getSessionCompletionCount();

  @override
  Future<void> saveSessionCompletionCount(int count) =>
      _local.saveSessionCompletionCount(count);

  @override
  Future<AppUser> signInWithApple() => _remote.signInWithApple();

  @override
  Future<void> signOut() => _remote.signOut();

  @override
  Future<AppUser?> getPersistedUser() => _remote.getPersistedUser();

  @override
  Future<void> deleteAccount(String userId) async {
    await _remote.deleteAccount(userId);
    await _local.clearAll();
  }
}
