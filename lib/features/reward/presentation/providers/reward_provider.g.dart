// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RewardNotifier)
final rewardProvider = RewardNotifierProvider._();

final class RewardNotifierProvider
    extends $NotifierProvider<RewardNotifier, bool> {
  RewardNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rewardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rewardNotifierHash();

  @$internal
  @override
  RewardNotifier create() => RewardNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$rewardNotifierHash() => r'1fb6fb72d7d9a93eb9076e794d4136155bf1f691';

abstract class _$RewardNotifier extends $Notifier<bool> {
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
