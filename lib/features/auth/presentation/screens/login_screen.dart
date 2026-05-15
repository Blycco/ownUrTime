import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

    Future<void> signInWithApple() async {
      try {
        await ref.read(authProvider.notifier).signInWithApple();
        if (!context.mounted) {
          return;
        }
        context.go('/tasks');
      } on Exception catch (_) {
        if (!context.mounted) {
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(SnackBar(content: Text(l10n.authSignInError)));
      }
    }

    final bool isLoading = authState is AsyncLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.appName),
              const SizedBox(height: 24),
              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: signInWithApple,
                  icon: const Icon(Icons.apple),
                  label: Text(l10n.authSignInWithApple),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/tasks'),
                child: Text(l10n.authContinueAsGuest),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
