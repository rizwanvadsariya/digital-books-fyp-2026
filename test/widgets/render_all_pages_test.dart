import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muallim_ul_quran/blocs/settings_cubit.dart';
import 'package:muallim_ul_quran/widgets/book_page.dart';

import '../helpers.dart';

/// Renders every page of the real book (in normal and practice mode) and
/// fails on any build/layout exception, e.g. overflow or unbounded
/// constraints from an unusual block shape.
void main() {
  final book = loadBook();

  for (final practice in [false, true]) {
    testWidgets('all ${book.length} pages render (practice mode: $practice)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final store = await freshStore();
      final settings = SettingsCubit(store)..setPracticeMode(practice);
      for (final page in book.pages) {
        await tester.pumpWidget(harness(
          BookPageView(key: ValueKey(page.index), book: book, page: page),
          store: store,
          settings: settings,
        ));
        // Scroll through the whole page so lazily built blocks get laid out.
        final scrollable = find.byType(Scrollable).first;
        for (var i = 0; i < 40; i++) {
          final state = tester.state<ScrollableState>(scrollable);
          if (state.position.pixels >= state.position.maxScrollExtent) break;
          state.position.jumpTo(state.position.pixels + 600);
          await tester.pump();
        }
        expect(tester.takeException(), isNull, reason: 'pdf page ${page.pdfPage}');
      }
    });
  }
}
