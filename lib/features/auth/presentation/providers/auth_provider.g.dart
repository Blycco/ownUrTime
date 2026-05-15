// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 로그인 프롬프트 해제 상태 — in-memory only (앱 재시작 시 초기화).

@ProviderFor(SignInPromptNotifier)
final signInPromptProvider = SignInPromptNotifierProvider._();

/// 로그인 프롬프트 해제 상태 — in-memory only (앱 재시작 시 초기화).
final class SignInPromptNotifierProvider
    extends $NotifierProvider<SignInPromptNotifier, bool> {
  /// 로그인 프롬프트 해제 상태 — in-memory only (앱 재시작 시 초기화).
  SignInPromptNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInPromptProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInPromptNotifierHash();

  @$internal
  @override
  SignInPromptNotifier create() => SignInPromptNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$signInPromptNotifierHash() =>
    r'435b903cdc752bb0c3cdeb118583458b81a71935';

/// 로그인 프롬프트 해제 상태 — in-memory only (앱 재시작 시 초기화).

abstract class _$SignInPromptNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

final class AuthNotifierProvider
    extends $AsyncNotifierProvider<AuthNotifier, AuthState> {
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();
}

String _$authNotifierHash() => r'13122eac179b33eca88ce9d13464ee2dedd0a17e';

abstract class _$AuthNotifier extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
