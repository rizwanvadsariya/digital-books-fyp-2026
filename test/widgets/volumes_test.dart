import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fehm_e_quran/data/book_repository.dart';
import 'package:fehm_e_quran/data/local_store.dart';
import 'package:fehm_e_quran/data/volumes.dart';
import 'package:fehm_e_quran/main.dart';
import 'package:fehm_e_quran/screens/home_shell.dart';
import 'package:fehm_e_quran/screens/reader_screen.dart';

import '../helpers.dart';

void main() {
  late Map<String, BookRepository> repositories;

  setUpAll(() {
    repositories = {
      for (final v in bookVolumes) v.id: BookRepository(assetPath: v.assetPath),
    };
  });

  Future<void> pumpApp(WidgetTester tester, LocalStore store) async {
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
  }

  testWidgets('switching to Volume 2 loads its book and keeps data separate', (
    tester,
  ) async {
    final store = await freshStore({
      'settings.v1': '{"language":"english"}',
      // Existing Volume 1 data under the original, un-prefixed keys.
      'answers.v1': '{"12_2_0":"حلال"}',
      'progress.lastPage': 20,
    });
    await pumpApp(tester, store);

    expect(find.text('جلد اوّل'), findsOneWidget);
    expect(find.text('Continue reading'), findsOneWidget);

    await tester.tap(find.text('Volume 2'));
    await tester.pumpAndSettle();

    // Volume 2's cover, with no progress yet and no Volume 1 answers.
    expect(find.text('جلد دوم'), findsOneWidget);
    expect(find.text('Continue reading'), findsNothing);
    expect(store.readSelectedVolume(), 'vol2');

    // Open Volume 2 and turn a page: progress is stored in its namespace.
    await tester.tap(find.text('Start reading'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsOneWidget);
    await tester.fling(find.byType(PageView), const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(store.forVolume('vol2.').readLastPage(), 1);
    expect(store.readLastPage(), 20, reason: 'Volume 1 progress untouched');

    await tester.pageBack();
    await tester.pumpAndSettle();

    // Contents are rebuilt for Volume 2: units 4 and 5.
    await tester.tap(find.text('Contents').last);
    await tester.pumpAndSettle();
    expect(find.text('Unit 4'), findsWidgets);
    expect(find.text('Unit 5'), findsWidgets);
    expect(find.text('Unit 1'), findsNothing);

    // Back on Volume 1, its data is still there.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volume 1'));
    await tester.pumpAndSettle();
    expect(find.text('جلد اوّل'), findsOneWidget);
    expect(find.text('Continue reading'), findsOneWidget);
    expect(store.readAnswers(), {'12_2_0': 'حلال'});
    expect(store.forVolume('vol2.').readAnswers(), isEmpty);
  });

  testWidgets(
    'Volume 3 opens with unit 6, its front matter and printed contents',
    (tester) async {
      final store = await freshStore({'settings.v1': '{"language":"english"}'});
      await pumpApp(tester, store);

      // Three volume cards, same style.
      expect(find.text('Volume 1'), findsOneWidget);
      expect(find.text('Volume 2'), findsOneWidget);
      expect(find.text('Volume 3'), findsOneWidget);
      expect(find.text('Unit 6'), findsOneWidget);

      await tester.tap(find.text('Volume 3'));
      await tester.pumpAndSettle();
      expect(find.text('جلد سوم'), findsOneWidget);
      expect(store.readSelectedVolume(), 'vol3');

      await tester.tap(find.text('Contents').last);
      await tester.pumpAndSettle();
      expect(find.text('Unit 6'), findsWidgets);
      expect(
        find.text('Introduction'),
        findsWidgets,
        reason: 'front-matter chip',
      );
      expect(find.text("Book's contents"), findsOneWidget);
      expect(find.text('Unit 5'), findsNothing);
    },
  );

  testWidgets('the selected volume is restored on launch', (tester) async {
    final store = await freshStore({
      'settings.v1': '{"language":"english"}',
      'library.volume': 'vol2',
    });
    await pumpApp(tester, store);
    expect(find.text('جلد دوم'), findsOneWidget);
  });
}
