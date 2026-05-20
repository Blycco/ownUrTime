import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ownurtime/features/recovery/domain/entities/distraction.dart';
import 'package:ownurtime/features/recovery/presentation/screens/recovery_screen.dart';
import 'package:ownurtime/features/session/presentation/screens/session_screen.dart';
import 'package:ownurtime/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:ownurtime/features/settings/presentation/screens/settings_screen.dart';
import 'package:ownurtime/features/task/presentation/screens/task_list_screen.dart';
import 'package:ownurtime/features/task/presentation/screens/task_start_screen.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/tasks',
    routes: [
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TaskListScreen(),
        routes: [
          GoRoute(
            path: 'start',
            builder: (context, state) => const TaskStartScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/session',
        builder: (context, state) {
          final extra = state.extra as Map<String, Object?>?;
          return SessionScreen(
            taskId: extra?['taskId'] as String?,
            taskTitle: extra?['taskTitle'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/recovery',
        builder: (context, state) {
          final extra = state.extra as Map<String, Object?>?;
          if (extra == null) return const SizedBox.shrink();
          final distraction = extra['distraction'];
          final elapsedTime = extra['elapsedTime'];
          if (distraction is! Distraction || elapsedTime is! Duration) {
            return const SizedBox.shrink();
          }
          return RecoveryScreen(
            distraction: distraction,
            taskTitle: extra['taskTitle'] as String? ?? '',
            currentStep: extra['currentStep'] as String?,
            elapsedTime: elapsedTime,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  ),
);
