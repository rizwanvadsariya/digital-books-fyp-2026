import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:fehm_e_quran/data/book_repository.dart';
import 'package:fehm_e_quran/data/volumes.dart';
import 'package:fehm_e_quran/main.dart';
import 'package:fehm_e_quran/screens/search_screen.dart';

import '../helpers.dart';

void main() {
  late Map<String, BookRepository> repositories;

  setUpAll(() {
    repositories = {
      for (final v in bookVolumes) v.id: BookRepository(assetPath: v.assetPath),
    };
  });

  Future<void> pumpSearchScreen(WidgetTester tester) async {
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

    // Switch to Search tab
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Search'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
  }

  testWidgets('search screen shows prompt, suggestions, and reactive clear button', (
    tester,
  ) async {
    await pumpSearchScreen(tester);

    // Initial state: search prompt and suggestion chips are visible
    expect(find.byType(SearchBar), findsOneWidget);
    expect(find.text('Search the book'), findsOneWidget);
    expect(find.text('Suggested searches'), findsOneWidget);
    expect(find.text('الْكِتَاب'), findsOneWidget);

    // Tap on a suggestion chip
    await tester.tap(find.text('الْكِتَاب'));
    await tester.pumpAndSettle();

    // Query is populated and results are shown
    expect(find.byType(ListTile), findsWidgets);
    expect(find.byIcon(SolarIconsBold.closeCircle), findsOneWidget);

    // Clear search using clear button
    await tester.tap(find.byIcon(SolarIconsBold.closeCircle));
    await tester.pumpAndSettle();

    // Prompt is shown again
    expect(find.text('Search the book'), findsOneWidget);
    expect(find.byIcon(SolarIconsBold.closeCircle), findsNothing);

    // Search for non-existent text
    final searchBar = find.byType(SearchBar);
    await tester.enterText(searchBar, 'xyznonexistentterm123');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // No results view is shown
    expect(find.text('No matches found'), findsOneWidget);
  });
}
