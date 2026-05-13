// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskListNotifier)
final taskListProvider = TaskListNotifierProvider._();

final class TaskListNotifierProvider
    extends $AsyncNotifierProvider<TaskListNotifier, List<Task>> {
  TaskListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskListNotifierHash();

  @$internal
  @override
  TaskListNotifier create() => TaskListNotifier();
}

String _$taskListNotifierHash() => r'226ada08998d0c22bcce5cb4859f87784811f4c1';

abstract class _$TaskListNotifier extends $AsyncNotifier<List<Task>> {
  FutureOr<List<Task>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Task>>, List<Task>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Task>>, List<Task>>,
              AsyncValue<List<Task>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DecomposeTaskNotifier)
final decomposeTaskProvider = DecomposeTaskNotifierProvider._();

final class DecomposeTaskNotifierProvider
    extends
        $NotifierProvider<
          DecomposeTaskNotifier,
          AsyncValue<({int remainingToday, List<String> steps})?>
        > {
  DecomposeTaskNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'decomposeTaskProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$decomposeTaskNotifierHash();

  @$internal
  @override
  DecomposeTaskNotifier create() => DecomposeTaskNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    AsyncValue<({int remainingToday, List<String> steps})?> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            AsyncValue<({int remainingToday, List<String> steps})?>
          >(value),
    );
  }
}

String _$decomposeTaskNotifierHash() =>
    r'4e1fe04218d247e7947eb50dce56c92b2f7978e6';

abstract class _$DecomposeTaskNotifier
    extends $Notifier<AsyncValue<({int remainingToday, List<String> steps})?>> {
  AsyncValue<({int remainingToday, List<String> steps})?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<({int remainingToday, List<String> steps})?>,
              AsyncValue<({int remainingToday, List<String> steps})?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<({int remainingToday, List<String> steps})?>,
                AsyncValue<({int remainingToday, List<String> steps})?>
              >,
              AsyncValue<({int remainingToday, List<String> steps})?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
