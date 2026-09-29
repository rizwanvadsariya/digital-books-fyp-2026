import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fehm_e_quran/data/book_repository.dart';
import 'package:fehm_e_quran/data/local_store.dart';
import 'package:fehm_e_quran/data/volumes.dart';
import 'package:fehm_e_quran/main.dart';
import 'package:fehm_e_quran/models/reader_settings.dart';
import 'package:fehm_e_quran/screens/home_shell.dart';

import '../helpers.dart';

void main() {
  Future<LocalStore> pumpApp(
    WidgetTester tester,
    Map<String, Object> prefs,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final store = await freshStore(prefs);
    // Warm each volume's cache outside fake time.
    final repositories = {
      for (final v in bookVolumes) v.id: BookRepository(assetPath: v.assetPath),
    };
    for (final r in repositories.values) {
      await tester.runAsync(r.load);
    }
    await tester.pumpWidget(
      FehmEQuranApp(store: store, repositoryFor: (v) => repositories[v.id]!),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    return store;
  }

  testWidgets(
    'switching the app language changes interface text and persists',
    (tester) async {
      final store = await pumpApp(tester, {
        'settings.v1': '{"language":"urdu"}',
      });
      expect(find.text('ہوم'), findsOneWidget);

      await tester.tap(find.text('ترتیبات'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // The settings screen itself switches immediately.
      expect(find.text('App language'), findsOneWidget);
      // The book preview is book content and stays Urdu/Arabic.
      expect(
        find.text('اور اللہ بخشنے والا، رحم کرنے والا ہے'),
        findsOneWidget,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Contents'), findsWidgets);

      expect(store.readSettings().language, AppLanguage.english);
    },
  );

  testWidgets('saved English setting is applied at startup', (tester) async {
    await pumpApp(tester, {'settings.v1': '{"language":"english"}'});
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    // Book cover title is book content, not translated.
    expect(find.text('مُعَلِّمُ الْقُرْآن'), findsOneWidget);
  });
}
