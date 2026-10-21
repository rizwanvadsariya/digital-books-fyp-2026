import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:fehm_e_quran/blocs/answers_cubit.dart';
import 'package:fehm_e_quran/blocs/book_cubit.dart';
import 'package:fehm_e_quran/blocs/progress_cubit.dart';
import 'package:fehm_e_quran/blocs/settings_cubit.dart';
import 'package:fehm_e_quran/data/book_repository.dart';
import 'package:fehm_e_quran/data/local_store.dart';
import 'package:fehm_e_quran/l10n/app_localizations.dart';
import 'package:fehm_e_quran/models/reader_settings.dart';
import 'package:fehm_e_quran/screens/reader_screen.dart';
import 'package:fehm_e_quran/theme/book_theme.dart';
import 'package:fehm_e_quran/widgets/keyboard/arabic_keyboard.dart';

import '../helpers.dart';

Future<(LocalStore, ProgressCubit)> pumpReader(
  WidgetTester tester,
  int pdfPage, {
  Locale locale = const Locale('ur'),
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final store = await freshStore();
  final progress = ProgressCubit(store);
  final bookCubit = BookCubit(BookRepository());
  await tester.runAsync(bookCubit.load);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: bookCubit),
        BlocProvider(create: (_) => SettingsCubit(store)),
        BlocProvider.value(value: progress),
        BlocProvider(create: (_) => AnswersCubit(store)),
      ],
      child: MaterialApp(
        theme: buildAppTheme(const ReaderSettings()),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ReaderScreen(
          initialIndex: bookCubit.state.book!.indexForPdfPage(pdfPage)!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (store, progress);
}

void main() {
  testWidgets(
    'tapping a blank inside the reader keeps the page and opens the keyboard',
    (tester) async {
      final (store, progress) = await pumpReader(tester, 12);
      final start = progress.state.lastPageIndex;

      await tester.tap(find.byType(TextField).at(3));
      await tester.pumpAndSettle();

      // Regression: scrolling the field into view used to nudge the page
      // turner, flipping the page and closing the keyboard.
      expect(progress.state.lastPageIndex, start);
      expect(find.byType(ArabicKeyboard), findsOneWidget);

      await tester.tap(find.text('ب').last);
      await tester.tap(find.byIcon(SolarIconsOutline.checkSquare));
      await tester.pumpAndSettle();
      expect(store.readAnswers().values, contains('ب'));
    },
  );

  testWidgets('swiping left-to-right advances the book (RTL)', (tester) async {
    final (_, progress) = await pumpReader(tester, 12);
    final start = progress.state.lastPageIndex!;
    await tester.fling(find.byType(PageView), const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(progress.state.lastPageIndex, start + 1);
  });

  testWidgets('English interface keeps the book right-to-left and in Urdu', (
    tester,
  ) async {
    final (_, progress) = await pumpReader(
      tester,
      12,
      locale: const Locale('en'),
    );
    final start = progress.state.lastPageIndex!;

    // Interface text is English and laid out left-to-right…
    expect(find.text('Unit 1 · Lesson 1'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(AppBar))),
      TextDirection.ltr,
    );
    // …while the page keeps the book's own Urdu badge, text and direction.
    expect(find.text('یونٹ 1 · سبق 1'), findsOneWidget);
    expect(find.text('درج ذیل سوالات کے زبانی جواب دیجئے'), findsOneWidget);
    final pageText = find.text('درج ذیل سوالات کے زبانی جواب دیجئے');
    expect(Directionality.of(tester.element(pageText)), TextDirection.rtl);
    expect(find.text('Write your answer'), findsWidgets);

    // Swiping left-to-right still advances the book.
    await tester.fling(find.byType(PageView), const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(progress.state.lastPageIndex, start + 1);
  });

  testWidgets('bookmark toggles from the app bar', (tester) async {
    final (store, progress) = await pumpReader(tester, 20);
    await tester.tap(find.byIcon(SolarIconsOutline.bookmark));
    await tester.pump();
    expect(progress.state.bookmarks, {progress.state.lastPageIndex});
    expect(store.readBookmarks(), {progress.state.lastPageIndex});
  });
}
