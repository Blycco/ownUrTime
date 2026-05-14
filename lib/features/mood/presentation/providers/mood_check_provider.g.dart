// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_check_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MoodCheckNotifier)
final moodCheckProvider = MoodCheckNotifierProvider._();

final class MoodCheckNotifierProvider
    extends $NotifierProvider<MoodCheckNotifier, MoodCheckState> {
  MoodCheckNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moodCheckProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moodCheckNotifierHash();

  @$internal
  @override
  MoodCheckNotifier create() => MoodCheckNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoodCheckState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoodCheckState>(value),
    );
  }
}

String _$moodCheckNotifierHash() => r'd30fcc6ec83931f506df78f02c8817853b3fcb9f';

abstract class _$MoodCheckNotifier extends $Notifier<MoodCheckState> {
  MoodCheckState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MoodCheckState, MoodCheckState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MoodCheckState, MoodCheckState>,
              MoodCheckState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
