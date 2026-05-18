import 'package:ownurtime/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  Future<int> getSessionCompletionCount();
  Future<void> saveSessionCompletionCount(int count);
  Future<AppUser> signInWithApple();
  Future<void> signOut();
  Future<AppUser?> getPersistedUser();

  /// 계정 및 모든 사용자 데이터를 영구 삭제한다.
  /// 서버 CASCADE 삭제 → 로컬 SecureStorage 초기화 순서로 진행.
  /// Throws [DeleteAccountException] on failure.
  Future<void> deleteAccount(String userId);
}
