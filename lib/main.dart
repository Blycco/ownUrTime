import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'core/l10n/app_localizations.dart';
import 'core/logging/logger_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  if (supabaseUrl.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  runApp(
    ProviderScope(
      observers: [
        TalkerRiverpodObserver(
          talker: appTalker,
          settings: const TalkerRiverpodLoggerSettings(
            enabled: !bool.fromEnvironment('dart.vm.product'),
            printProviderUpdated: true,
            printProviderFailed: true,
            printProviderAdded: false,
            printProviderDisposed: false,
          ),
        ),
      ],
      child: const OwnUrTimeApp(),
    ),
  );
}

class OwnUrTimeApp extends StatelessWidget {
  const OwnUrTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
