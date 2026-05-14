import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/recovery/data/providers/distraction_providers.dart';
import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';
import 'package:ownurtime/features/recovery/domain/usecases/recover_session_usecase.dart';
import 'package:ownurtime/features/recovery/presentation/widgets/context_restore_card.dart';
import 'package:ownurtime/features/session/presentation/providers/timer_provider.dart';

class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({
    required this.distraction,
    required this.taskTitle,
    required this.currentStep,
    required this.elapsedTime,
    super.key,
  });

  final Distraction distraction;
  final String taskTitle;
  final String? currentStep;
  final Duration elapsedTime;

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  DistractionType? _selectedType;
  AsyncValue<RecoveryContext?> _recoveryState = const AsyncValue.data(null);
  bool _isSelecting = false;

  Future<void> _selectType(DistractionType type) async {
    if (_isSelecting) return;
    setState(() {
      _isSelecting = true;
      _selectedType = type;
      _recoveryState = const AsyncValue.loading();
    });

    final useCase = ref.read(recoverSessionUseCaseProvider);
    final updated = widget.distraction.copyWith(type: type);
    final result = await AsyncValue.guard<RecoveryContext>(
      () => useCase(
        distraction: updated,
        taskTitle: widget.taskTitle,
        currentStep: widget.currentStep,
        elapsedTime: widget.elapsedTime,
      ),
    );

    if (mounted) {
      setState(() {
        _isSelecting = false;
        _recoveryState = result;
      });
    }
  }

  void _resume() {
    ref.read(timerProvider.notifier).resumeFromDistraction();
    Navigator.of(context).maybePop();
  }

  String _typeLabel(AppLocalizations l10n, DistractionType type) {
    switch (type) {
      case DistractionType.urgent:
        return l10n.recoveryTypeUrgent;
      case DistractionType.impulsive:
        return l10n.recoveryTypeImpulsive;
      case DistractionType.rest:
        return l10n.recoveryTypeRest;
    }
  }

  String _message(AppLocalizations l10n, DistractionType type) {
    switch (type) {
      case DistractionType.urgent:
        return l10n.recoveryUrgentMessage;
      case DistractionType.impulsive:
        return l10n.recoveryImpulsiveMessage;
      case DistractionType.rest:
        return l10n.recoveryRestMessage;
    }
  }

  String _cta(AppLocalizations l10n, DistractionType type) {
    switch (type) {
      case DistractionType.urgent:
        return l10n.recoveryUrgentCta;
      case DistractionType.impulsive:
        return l10n.recoveryImpulsiveCta;
      case DistractionType.rest:
        return l10n.recoveryRestCta;
    }
  }

  String _resumeLabel(AppLocalizations l10n, DistractionType type) {
    switch (type) {
      case DistractionType.rest:
        return l10n.recoveryRestResumeButton;
      case DistractionType.urgent:
      case DistractionType.impulsive:
        return l10n.recoveryResumeButton;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedType = _selectedType;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final type in DistractionType.values) ...[
                FilledButton(
                  onPressed: _isSelecting ? null : () => _selectType(type),
                  child: Text(_typeLabel(l10n, type)),
                ),
                const SizedBox(height: 8),
              ],
              if (selectedType != null) ...[
                const SizedBox(height: 12),
                _recoveryState.when(
                  data: (ctx) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (ctx != null) ...[
                        Text(
                          _message(l10n, selectedType),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(_cta(l10n, selectedType)),
                        const SizedBox(height: 16),
                      ],
                      ContextRestoreCard(
                        taskTitle: widget.taskTitle,
                        currentStep: widget.currentStep,
                        elapsedTime: widget.elapsedTime,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: ctx != null ? _resume : null,
                        child: Text(_resumeLabel(l10n, selectedType)),
                      ),
                    ],
                  ),
                  // Error: 로깅 실패해도 타이머 복귀는 항상 허용 (RULE 07)
                  error: (_, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ContextRestoreCard(
                        taskTitle: widget.taskTitle,
                        currentStep: widget.currentStep,
                        elapsedTime: widget.elapsedTime,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _resume,
                        child: Text(_resumeLabel(l10n, selectedType)),
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
