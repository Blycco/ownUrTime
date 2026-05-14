import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AuthLocalDataSource {
  Future<int> getSessionCompletionCount();
  Future<void> saveSessionCompletionCount(int count);
  Future<void> clearAll();
}

class SecureStorageAuthDataSource implements AuthLocalDataSource {
  SecureStorageAuthDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _sessionCompletionCountKey =
      'auth_session_completion_count';

  final FlutterSecureStorage _storage;

  @override
  Future<int> getSessionCompletionCount() async {
    final stored = await _storage.read(key: _sessionCompletionCountKey);
    if (stored == null) {
      return 0;
    }
    return int.tryParse(stored) ?? 0;
  }

  @override
  Future<void> saveSessionCompletionCount(int count) {
    return _storage.write(
      key: _sessionCompletionCountKey,
      value: count.toString(),
    );
  }

  @override
  Future<void> clearAll() => _storage.delete(key: _sessionCompletionCountKey);
}
