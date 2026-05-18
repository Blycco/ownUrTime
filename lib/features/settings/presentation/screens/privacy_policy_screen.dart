import 'package:flutter/material.dart';
import 'package:ownurtime/core/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicyTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.privacyPolicyBody),
      ),
    );
  }
}
