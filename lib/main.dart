import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';
import 'package:ownurtime/core/logging/logger_service.dart';
import 'package:ownurtime/core/router/app_router.dart';
import 'package:ownurtime/core/supabase/supabase_config.dart';
import 'package:ownurtime/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.url.isNotEmpty) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } else {
    throw StateError(
      'SUPABASE_URL not set — run with --dart-define-from-file=.env',
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
            printStateFullData: false,
            printFailFullData: false,
          ),
        ),
      ],
      child: const OwnUrTimeApp(),
    ),
  );
}

class OwnUrTimeApp extends ConsumerWidget {
  const OwnUrTimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
