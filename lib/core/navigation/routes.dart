import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/answers_review_screen.dart';
import '../../screens/home_shell.dart';
import '../../screens/reader_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/table_of_contents_screen.dart';
import 'route_enums.dart';

export 'route_enums.dart';

/// Helper function to wrap screens and apply transitions
Page<T> wrapperPage<T>({
  required Widget child,
  required GoRouterState state,
  bool noTransition = false,
}) {
  if (noTransition) {
    return NoTransitionPage<T>(key: state.pageKey, child: child);
  }
  return CupertinoPage<T>(key: state.pageKey, child: child);
}

class AppNavigationRoutes {
  static final routes = [
    GoRoute(
      path: AppRoutes.splash.path,
      name: AppRoutes.splash.name,
      pageBuilder: (context, state) => wrapperPage(
        state: state,
        noTransition: true,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home.path,
      name: AppRoutes.home.name,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: AppRoutes.reader.path,
      name: AppRoutes.reader.name,
      pageBuilder: (context, state) {
        final pageIndexStr = state.pathParameters['pageIndex'];
        final pageIndex =
            pageIndexStr != null ? int.tryParse(pageIndexStr) ?? 0 : 0;
        return wrapperPage(
          state: state,
          child: ReaderScreen(initialIndex: pageIndex),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.contents.path,
      name: AppRoutes.contents.name,
      pageBuilder: (context, state) {
        final index = state.extra as int?;
        return wrapperPage(
          state: state,
          child: TableOfContentsScreen(currentIndex: index),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.answersReview.path,
      name: AppRoutes.answersReview.name,
      pageBuilder: (context, state) => wrapperPage(
        state: state,
        child: const AnswersReviewScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings.path,
      name: AppRoutes.settings.name,
      pageBuilder: (context, state) => wrapperPage(
        state: state,
        child: const SettingsScreen(),
      ),
    ),
  ];
}
