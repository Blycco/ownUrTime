import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:ownurtime/features/auth/domain/entities/app_user.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.guest({@Default(0) int sessionCompletionCount}) =
      AuthGuest;

  const factory AuthState.authenticated({required AppUser user}) =
      AuthAuthenticated;
}

extension AuthStateX on AuthState {
  bool get isGuest => this is AuthGuest;

  String get userId => switch (this) {
    AuthGuest() => 'guest',
    AuthAuthenticated(:final user) => user.id,
  };

  int get sessionCompletionCount => switch (this) {
    AuthGuest(:final sessionCompletionCount) => sessionCompletionCount,
    AuthAuthenticated() => 0, // authenticated users don't use the guest counter
  };
}
