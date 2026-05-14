import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';

class SignInPromptSheet extends ConsumerWidget {
  const SignInPromptSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    Future<void> signInWithApple() async {
      try {
        await authNotifier.signInWithApple();
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop();
      } on Exception catch (_) {
        if (!context.mounted) {
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(SnackBar(content: Text(l10n.authSignInError)));
      }
    }

    final isLoading = authState is AsyncLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.authPromptTitle, style: textTheme.titleMedium),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: signInWithApple,
                icon: const Icon(Icons.apple),
                label: Text(l10n.authSignInWithApple),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.read(signInPromptProvider.notifier).dismiss();
              Navigator.of(context).pop();
            },
            child: Text(l10n.authMaybeLater),
          ),
        ],
      ),
    );
  }
}
