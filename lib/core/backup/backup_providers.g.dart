// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(iCloudBackupService)
final iCloudBackupServiceProvider = ICloudBackupServiceProvider._();

final class ICloudBackupServiceProvider
    extends
        $FunctionalProvider<
          ICloudBackupService,
          ICloudBackupService,
          ICloudBackupService
        >
    with $Provider<ICloudBackupService> {
  ICloudBackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iCloudBackupServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iCloudBackupServiceHash();

  @$internal
  @override
  $ProviderElement<ICloudBackupService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ICloudBackupService create(Ref ref) {
    return iCloudBackupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ICloudBackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ICloudBackupService>(value),
    );
  }
}

String _$iCloudBackupServiceHash() =>
    r'90804b83a441e67123878b291c7cec739aa101bc';
