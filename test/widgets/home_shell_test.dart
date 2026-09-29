import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fehm_e_quran/data/book_repository.dart';
import 'package:fehm_e_quran/data/volumes.dart';
import 'package:fehm_e_quran/main.dart';
import 'package:fehm_e_quran/screens/home_shell.dart';

import '../helpers.dart';

void main() {
  late Map<String, BookRepository> repositories;

  setUpAll(() {
    repositories = {
      for (final v in bookVolumes) v.id: BookRepository(assetPath: v.assetPath),
    };
  });

  testWidgets(
    'back button returns to tab 0 if on another tab, and requires double tap to close',
    (tester) async {
      final store = await freshStore({
        'settings.v1': '{"language":"english"}',
      });

      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      for (final r in repositories.values) {
        await tester.runAsync(r.load);
      }

      await tester.pumpWidget(
        FehmEQuranApp(store: store, repositoryFor: (v) => repositories[v.id]!),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeShell), findsOneWidget);

      // Verify we start at tab 0
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);

      // Switch to tab 1 (Contents)
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Contents'),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 1);

      // 1 pop: should return to index 0
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 0);

      // Track platform messages for SystemNavigator.pop
      var systemPopCalled = false;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'SystemNavigator.pop') {
            systemPopCalled = true;
          }
          return null;
        },
      );

      // First pop on index 0: should show snackbar and not call SystemNavigator.pop
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.text('Press back again to exit'), findsOneWidget);
      expect(systemPopCalled, isFalse);

      // Second pop within 2 seconds: should call SystemNavigator.pop
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(systemPopCalled, isTrue);
    },
  );
}
