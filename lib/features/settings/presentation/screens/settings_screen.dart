import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/features/settings/presentation/widgets/delete_account_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.settingsPrivacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/privacy-policy'),
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.settingsDeleteAccount,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => const DeleteAccountDialog(),
            ),
          ),
        ],
      ),
    );
  }
}
