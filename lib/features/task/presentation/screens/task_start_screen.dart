import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/task/domain/exceptions/task_exceptions.dart';
import 'package:ownurtime/features/task/presentation/providers/task_provider.dart';
import 'package:ownurtime/features/task/presentation/widgets/ai_limit_indicator.dart';
import 'package:ownurtime/features/task/presentation/widgets/micro_start_button.dart';

class TaskStartScreen extends ConsumerStatefulWidget {
  const TaskStartScreen({super.key});

  @override
  ConsumerState<TaskStartScreen> createState() => _TaskStartScreenState();
}

class _TaskStartScreenState extends ConsumerState<TaskStartScreen> {
  final _titleController = TextEditingController();
  String _pendingTaskId = '';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    final effectiveTitle = title.isEmpty ? l10n.taskStartDefaultTitle : title;
    await ref.read(taskListProvider.notifier).createTask(effectiveTitle);
    if (mounted) context.pop();
  }

  Future<void> _decompose() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final id = _pendingTaskId.isEmpty
        ? 'pending_${DateTime.now().millisecondsSinceEpoch}'
        : _pendingTaskId;
    setState(() => _pendingTaskId = id);
    await ref.read(decomposeTaskProvider.notifier).decompose(id, title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decomposeAsync = ref.watch(decomposeTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskStartTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: l10n.taskStartHint,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  ref.read(decomposeTaskProvider.notifier).reset();
                  setState(() => _pendingTaskId = '');
                },
              ),
              const SizedBox(height: 12),
              _DecomposeSection(
                onDecompose: _decompose,
                decomposeAsync: decomposeAsync,
              ),
              const Spacer(),
              MicroStartButton(onPressed: _start),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecomposeSection extends StatelessWidget {
  const _DecomposeSection({
    required this.onDecompose,
    required this.decomposeAsync,
  });

  final VoidCallback onDecompose;
  final AsyncValue<({List<String> steps, int remainingToday})?> decomposeAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return decomposeAsync.when(
      data: (result) {
        if (result == null) {
          return TextButton.icon(
            onPressed: onDecompose,
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.taskStartAiButton),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AiLimitIndicator(remaining: result.remainingToday),
            ...result.steps.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(radius: 12, child: Text('${e.key + 1}')),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e.value)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(),
      ),
      error: (e, s) => Text(
        e is DailyLimitException
            ? l10n.taskStartAiLimitReached
            : l10n.taskStartError,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
