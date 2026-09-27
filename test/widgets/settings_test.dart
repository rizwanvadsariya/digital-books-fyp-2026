import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muallim_ul_quran/data/book_repository.dart';
import 'package:muallim_ul_quran/data/local_store.dart';
import 'package:muallim_ul_quran/main.dart';
import 'package:muallim_ul_quran/models/reader_settings.dart';
import 'package:muallim_ul_quran/screens/home_shell.dart';

import '../helpers.dart';

void main() {
  Future<LocalStore> pumpApp(WidgetTester tester, Map<String, Object> prefs) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final store = await freshStore(prefs);
    final repository = BookRepository();
    await tester.runAsync(repository.load); // warm the cache outside fake time
    await tester.pumpWidget(MuallimApp(store: store, repository: repository));
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    return store;
  }

  testWidgets('switching the app language changes interface text and persists', (tester) async {
    final store = await pumpApp(tester, {'settings.v1': '{"language":"urdu"}'});
    expect(find.text('ہوم'), findsOneWidget);

    await tester.tap(find.text('ترتیبات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // The settings screen itself switches immediately.
    expect(find.text('App language'), findsOneWidget);
    // The book preview is book content and stays Urdu/Arabic.
    expect(find.text('اور اللہ بخشنے والا، رحم کرنے والا ہے'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Contents'), findsWidgets);

    expect(store.readSettings().language, AppLanguage.english);
  });

  testWidgets('saved English setting is applied at startup', (tester) async {
    await pumpApp(tester, {'settings.v1': '{"language":"english"}'});
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    // Book cover title is book content, not translated.
    expect(find.text('مُعَلِّمُ الْقُرْآن'), findsOneWidget);
  });
}
