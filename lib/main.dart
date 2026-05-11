import 'package:flutter/material.dart';
import 'package:ownurtime/core/router/app_router.dart';
import 'package:ownurtime/core/theme/app_theme.dart';

void main() {
  runApp(const OwnUrTimeApp());
}

class OwnUrTimeApp extends StatelessWidget {
  const OwnUrTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OwnUrTime',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.config,
    );
  }
}
