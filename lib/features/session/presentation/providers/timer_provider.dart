import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ownurtime/features/session/data/providers/session_providers.dart';
import 'package:ownurtime/features/session/domain/entities/session.dart';
import 'package:ownurtime/features/session/domain/entities/timer_state.dart';
import 'package:ownurtime/features/session/domain/usecases/complete_session_usecase.dart';
import 'package:ownurtime/features/session/domain/usecases/start_session_usecase.dart';

part 'timer_provider.g.dart';

const String _guestUserId = 'guest';

@Riverpod(keepAlive: true)
class TimerNotifier extends _$TimerNotifier {
  Timer? _ticker;
  Duration? _targetDuration;
  Session? _activeSession;
  bool _manualWorkMode = false;
  bool _adaptiveCheckInDisabled = false;
  int _sessionCount = 0;
  int _currentDistractionCount = 0;
  int _currentResetCount = 0;

  @override
  TimerState build() {
    ref.onDispose(_cancelTicker);
    return const TimerState.idle();
  }

  Duration? get targetDuration => _targetDuration;

  Future<void> start(
    Duration duration, {
    String? taskId,
    bool manualWorkMode = false,
  }) async {
    _cancelTicker();
    _targetDuration = duration;
    _manualWorkMode = manualWorkMode;
    _currentDistractionCount = 0;
    _currentResetCount = 0;

    final repo = ref.read(sessionRepositoryProvider);
    final session = await StartSessionUseCase(repo)(
      userId: _guestUserId,
      taskId: taskId,
      targetDurationMinutes: duration.inMinutes,
      manualWorkMode: manualWorkMode,
    );
    _activeSession = session;

    state = TimerState.running(
      remaining: duration,
      distractionCount: 0,
      resetCount: 0,
    );
    _startTicker();
  }

  void pause() {
    final current = state;
    if (current is! TimerRunning) return;
    _cancelTicker();
    state = TimerState.paused(remaining: current.remaining);
  }

  void resume() {
    final current = state;
    if (current is! TimerPaused) return;
    state = TimerState.running(
      remaining: current.remaining,
      distractionCount: _currentDistractionCount,
      resetCount: _currentResetCount,
    );
    _startTicker();
  }

  void reset() {
    final current = state;
    if (current is! TimerRunning) return;
    if (current.resetCount >= 3) return;
    final target = _targetDuration;
    if (target == null) return;
    _cancelTicker();
    _currentResetCount = current.resetCount + 1;
    state = TimerState.running(
      remaining: target,
      distractionCount: current.distractionCount,
      resetCount: _currentResetCount,
    );
    _startTicker();
    final session = _activeSession;
    if (session != null) {
      final repo = ref.read(sessionRepositoryProvider);
      repo
          .updateSession(session.copyWith(resetCount: _currentResetCount))
          .ignore();
    }
  }

  void extend() {
    final current = state;
    if (current is! TimerRunning) return;
    state = current.copyWith(
      remaining: current.remaining + const Duration(minutes: 1),
    );
  }

  Future<void> declareDistraction() async {
    final current = state;
    if (current is! TimerRunning) return;
    _cancelTicker();

    _currentDistractionCount = current.distractionCount + 1;
    // 타이머 중단 후 paused 상태로 전환 (Recovery flow는 Task 04에서 연결)
    state = TimerState.paused(remaining: current.remaining);

    final session = _activeSession;
    if (session != null) {
      final repo = ref.read(sessionRepositoryProvider);
      _activeSession = await repo.updateSession(
        session.copyWith(distractionCount: _currentDistractionCount),
      );
    }
  }

  Future<void> dismissAdaptiveCheckIn({required bool focused}) async {
    final current = state;
    if (current is TimerRunning) {
      state = current.copyWith(adaptiveCheckInVisible: false);
    }
    if (focused) {
      _sessionCount++;
      if (_sessionCount >= 3) _adaptiveCheckInDisabled = true;
    } else {
      await declareDistraction();
    }
  }

  void _complete() {
    _cancelTicker();
    state = const TimerState.completed();
    final session = _activeSession;
    if (session != null) {
      final repo = ref.read(sessionRepositoryProvider);
      CompleteSessionUseCase(repo)(session.id).ignore();
    }
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    final current = state;
    if (current is! TimerRunning) return;

    final newRemaining = current.remaining - const Duration(seconds: 1);
    if (newRemaining <= Duration.zero) {
      _complete();
      return;
    }

    state = current.copyWith(remaining: newRemaining);
    _checkAdaptive(newRemaining);
  }

  void _checkAdaptive(Duration remaining) {
    if (_manualWorkMode || _adaptiveCheckInDisabled) return;
    if (_sessionCount >= 3) return;
    final target = _targetDuration;
    if (target == null || target <= const Duration(minutes: 5)) return;
    final fiveMinMark = target - const Duration(minutes: 5);
    if (remaining <= fiveMinMark &&
        remaining > fiveMinMark - const Duration(seconds: 1)) {
      final current = state;
      if (current is TimerRunning && !current.adaptiveCheckInVisible) {
        state = current.copyWith(adaptiveCheckInVisible: true);
      }
    }
  }
}
