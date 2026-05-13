import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    ],
  ),
);
