import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muallim_ul_quran/blocs/answers_cubit.dart';
import 'package:muallim_ul_quran/blocs/book_cubit.dart';
import 'package:muallim_ul_quran/blocs/progress_cubit.dart';
import 'package:muallim_ul_quran/blocs/settings_cubit.dart';
import 'package:muallim_ul_quran/data/book_repository.dart';
import 'package:muallim_ul_quran/data/local_store.dart';
import 'package:muallim_ul_quran/models/reader_settings.dart';
import 'package:muallim_ul_quran/screens/reader_screen.dart';
import 'package:muallim_ul_quran/theme/book_theme.dart';
import 'package:muallim_ul_quran/widgets/keyboard/arabic_keyboard.dart';

import '../helpers.dart';

Future<(LocalStore, ProgressCubit)> pumpReader(WidgetTester tester, int pdfPage) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final store = await freshStore();
  final progress = ProgressCubit(store);
  final bookCubit = BookCubit(BookRepository());
  await tester.runAsync(bookCubit.load);
  await tester.pumpWidget(MultiBlocProvider(
    providers: [
      BlocProvider.value(value: bookCubit),
      BlocProvider(create: (_) => SettingsCubit(store)),
      BlocProvider.value(value: progress),
      BlocProvider(create: (_) => AnswersCubit(store)),
    ],
    child: MaterialApp(
      theme: buildAppTheme(const ReaderSettings()),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: ReaderScreen(initialIndex: bookCubit.state.book!.indexForPdfPage(pdfPage)!),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return (store, progress);
}

void main() {
  testWidgets('tapping a blank inside the reader keeps the page and opens the keyboard', (tester) async {
    final (store, progress) = await pumpReader(tester, 12);
    final start = progress.state.lastPageIndex;

    await tester.tap(find.byType(TextField).at(3));
    await tester.pumpAndSettle();

    // Regression: scrolling the field into view used to nudge the page
    // turner, flipping the page and closing the keyboard.
    expect(progress.state.lastPageIndex, start);
    expect(find.byType(ArabicKeyboard), findsOneWidget);

    await tester.tap(find.text('ب').last);
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    expect(store.readAnswers().values, contains('ب'));
  });

  testWidgets('swiping left-to-right advances the book (RTL)', (tester) async {
    final (_, progress) = await pumpReader(tester, 12);
    final start = progress.state.lastPageIndex!;
    await tester.fling(find.byType(PageView), const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(progress.state.lastPageIndex, start + 1);
  });

  testWidgets('bookmark toggles from the app bar', (tester) async {
    final (store, progress) = await pumpReader(tester, 20);
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pump();
    expect(progress.state.bookmarks, {progress.state.lastPageIndex});
    expect(store.readBookmarks(), {progress.state.lastPageIndex});
  });
}
