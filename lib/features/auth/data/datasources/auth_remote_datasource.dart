import 'dart:async';

import 'package:ownurtime/features/auth/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<AppUser> signInWithApple();
  Future<void> signOut();
  Future<AppUser?> getPersistedUser();
}

class SupabaseAuthDataSource implements AuthRemoteDataSource {
  const SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<AppUser> signInWithApple() async {
    // signInWithOAuth opens the browser and returns before the OAuth callback
    // arrives. Subscribe to onAuthStateChange first, then launch the flow.
    final completer = Completer<AppUser>();
    StreamSubscription<AuthState>? sub;

    sub = _client.auth.onAuthStateChange.listen(
      (data) {
        if (completer.isCompleted) return;
        if (data.event == AuthChangeEvent.signedIn) {
          final user = data.session?.user;
          if (user != null) {
            completer.complete(AppUser(id: user.id, email: user.email));
          }
        }
      },
      onError: (Object error, StackTrace st) {
        if (!completer.isCompleted) completer.completeError(error, st);
      },
      cancelOnError: true,
    );

    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.ownurtime.app://login-callback',
      );
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw const AuthException('Apple sign in timed out'),
      );
    } finally {
      await sub.cancel();
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<AppUser?> getPersistedUser() {
    final user = _client.auth.currentUser;
    if (user == null) return Future<AppUser?>.value();
    return Future<AppUser?>.value(AppUser(id: user.id, email: user.email));
  }
}
