import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'context_utility.dart';
import 'routes.dart';

export 'context_utility.dart';
export 'route_enums.dart';
export 'routes.dart';

final GoRouter appRouter = createAppRouter();

GoRouter createAppRouter({
  String initialLocation = '/',
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    navigatorKey: navigatorKey ?? ContextUtility.navigatorKey,
    routes: AppNavigationRoutes.routes,
  );
}
