import 'package:ownurtime/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  Future<int> getSessionCompletionCount();
  Future<void> saveSessionCompletionCount(int count);
  Future<AppUser> signInWithApple();
  Future<void> signOut();
  Future<AppUser?> getPersistedUser();
}
