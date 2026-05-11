import 'package:flutter/material.dart';

class AppRouter {
  AppRouter._();

  static final RouterConfig<Object> config = RouterConfig<Object>(
    routerDelegate: _AppRouterDelegate(),
    routeInformationParser: _AppRouteInformationParser(),
    routeInformationProvider: PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: Uri.parse('/')),
    ),
  );
}

class _AppRouteInformationParser extends RouteInformationParser<Object> {
  @override
  Future<Object> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return Object();
  }
}

class _AppRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: const <Page<void>>[
        MaterialPage<void>(child: _BootstrapScreen()),
      ],
      onDidRemovePage: (Page<Object?> page) {},
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('OwnUrTime Bootstrap Ready'),
      ),
    );
  }
}
