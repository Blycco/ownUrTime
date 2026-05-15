// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day2_return_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(day2ReturnCheck)
final day2ReturnCheckProvider = Day2ReturnCheckProvider._();

final class Day2ReturnCheckProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  Day2ReturnCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'day2ReturnCheckProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$day2ReturnCheckHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return day2ReturnCheck(ref);
  }
}

String _$day2ReturnCheckHash() => r'6f70c61e53c78b064106c1ae8756332f04f4a990';
