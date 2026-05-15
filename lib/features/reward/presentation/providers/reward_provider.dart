import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reward_provider.g.dart';

@riverpod
class RewardNotifier extends _$RewardNotifier {
  @override
  bool build() => false;

  void show() {
    state = true;
  }

  void hide() {
    state = false;
  }
}
