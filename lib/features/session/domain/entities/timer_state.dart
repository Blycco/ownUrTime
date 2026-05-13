import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

@freezed
sealed class TimerState with _$TimerState {
  const factory TimerState.idle() = TimerIdle;
  const factory TimerState.running({
    required Duration remaining,
    required int distractionCount,
    required int resetCount,
    @Default(false) bool adaptiveCheckInVisible,
  }) = TimerRunning;
  const factory TimerState.paused({required Duration remaining}) = TimerPaused;
  const factory TimerState.completed() = TimerCompleted;
}
