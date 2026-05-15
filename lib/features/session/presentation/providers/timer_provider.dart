import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ownurtime/core/analytics/analytics_providers.dart';
import 'package:ownurtime/features/auth/domain/entities/auth_state.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';
import 'package:ownurtime/features/recovery/data/providers/distraction_providers.dart';
import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';
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
  DateTime? _lastDistractionAt;

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
    final userId = ref.read(authProvider).value?.userId ?? _guestUserId;
    final session = await StartSessionUseCase(repo)(
      userId: userId,
      taskId: taskId,
      targetDurationMinutes: duration.inMinutes,
      manualWorkMode: manualWorkMode,
    );
    _activeSession = session;

    ref
        .read(analyticsServiceProvider)
        .track(
          'initiation_conversion',
          properties: {
            'task_linked': taskId != null,
            'duration_minutes': duration.inMinutes,
            'manual_work_mode': manualWorkMode,
          },
        )
        .ignore();

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

  Future<Distraction?> declareDistraction() async {
    final current = state;
    if (current is! TimerRunning) return null;
    _cancelTicker();

    _currentDistractionCount = current.distractionCount + 1;
    _lastDistractionAt = DateTime.now();
    state = TimerState.paused(remaining: current.remaining);

    final target = _targetDuration;
    final elapsed = target != null
        ? target.inSeconds - current.remaining.inSeconds
        : 0;
    ref
        .read(analyticsServiceProvider)
        .track(
          'session_distracted',
          properties: {
            'distraction_type': DistractionType.impulsive.name,
            'minutes_into_session': elapsed ~/ 60,
            'session_target_minutes': target?.inMinutes ?? 0,
          },
        )
        .ignore();

    Distraction? distraction;
    try {
      distraction = await ref.read(logDistractionUseCaseProvider)(
        sessionId: _activeSession?.id ?? _guestUserId,
        type: DistractionType.impulsive,
        userId: ref.read(authProvider).value?.userId ?? _guestUserId,
      );
    } on Exception {
      // 로깅 실패 시 타이머 pause 유지, recovery 화면은 계속 표시
    }

    final session = _activeSession;
    if (session != null) {
      try {
        final repo = ref.read(sessionRepositoryProvider);
        _activeSession = await repo.updateSession(
          session.copyWith(distractionCount: _currentDistractionCount),
        );
      } on Exception {
        // 세션 업데이트 실패 시 무시 — 타이머 상태는 이미 반영됨
      }
    }

    return distraction;
  }

  void resumeFromDistraction() {
    final current = state;
    if (current is! TimerPaused) return;
    final distractionTime = _lastDistractionAt;
    final recoverySeconds = distractionTime != null
        ? DateTime.now().difference(distractionTime).inSeconds
        : 0;
    _lastDistractionAt = null;
    ref
        .read(analyticsServiceProvider)
        .track(
          'recovery_returned',
          properties: {
            'distraction_type': DistractionType.impulsive.name,
            'recovery_seconds': recoverySeconds,
          },
        )
        .ignore();
    state = TimerState.running(
      remaining: current.remaining,
      distractionCount: _currentDistractionCount,
      resetCount: _currentResetCount,
    );
    _startTicker();
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
    ref.read(authProvider.notifier).incrementSessionCompletionCount().ignore();
    ref
        .read(analyticsServiceProvider)
        .track(
          'session_completed',
          properties: {
            'duration_minutes': _targetDuration?.inMinutes ?? 0,
            'distraction_count': _currentDistractionCount,
            'reset_count': _currentResetCount,
          },
        )
        .ignore();
    ref.read(analyticsServiceProvider).recordFirstSessionDate().ignore();
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
