import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.deleteAccountDialogTitle),
      content: Text(l10n.deleteAccountDialogBody),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => context.pop(),
          child: Text(l10n.deleteAccountDialogCancel),
        ),
        TextButton(
          onPressed: _loading ? null : _onDelete,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.deleteAccountDialogConfirm),
        ),
      ],
    );
  }

  Future<void> _onDelete() async {
    setState(() => _loading = true);

    try {
      await ref.read(authProvider.notifier).deleteAccount();
      if (!mounted || !context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.deleteAccountSuccess)),
      );
      context.go('/tasks');
    } catch (e) {
      if (!mounted || !context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context);
      final message = e.toString().contains('network_error')
          ? l10n.deleteAccountErrorNetwork
          : l10n.deleteAccountErrorServer;
      setState(() => _loading = false);
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
