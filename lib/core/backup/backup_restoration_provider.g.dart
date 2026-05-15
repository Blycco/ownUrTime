// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_restoration_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupRestoration)
final backupRestorationProvider = BackupRestorationProvider._();

final class BackupRestorationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  BackupRestorationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupRestorationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupRestorationHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return backupRestoration(ref);
  }
}

String _$backupRestorationHash() => r'3fc27dc46ac09ce3411bac252c44c348b5b4c039';

@ProviderFor(BackupTriggerNotifier)
final backupTriggerProvider = BackupTriggerNotifierProvider._();

final class BackupTriggerNotifierProvider
    extends $NotifierProvider<BackupTriggerNotifier, bool> {
  BackupTriggerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupTriggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupTriggerNotifierHash();

  @$internal
  @override
  BackupTriggerNotifier create() => BackupTriggerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$backupTriggerNotifierHash() =>
    r'557f158871b4c125c47aa0f57726efd105750156';

abstract class _$BackupTriggerNotifier extends $Notifier<bool> {
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
