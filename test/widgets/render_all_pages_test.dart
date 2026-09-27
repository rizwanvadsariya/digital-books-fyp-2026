import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muallim_ul_quran/blocs/settings_cubit.dart';
import 'package:muallim_ul_quran/widgets/blocks/block_renderer.dart';
import 'package:muallim_ul_quran/widgets/book_page.dart';

import '../helpers.dart';

/// Renders every page of every volume (in normal and practice mode) and
/// fails on any build/layout exception — e.g. overflow or unbounded
/// constraints from an unusual block shape — or on a block that renders no
/// text at all.
void main() {
  for (final path in [vol1Path, vol2Path, vol3Path]) {
    final book = loadBook(path);
    for (final practice in [false, true]) {
      testWidgets('${book.title}: all ${book.length} pages render with content (practice: $practice)', (tester) async {
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

          final withContent = <int>{};
          final rendered = <int>{};
          // One walk of the element tree per scroll step (searching the tree
          // once per block is quadratic on long pages).
          void collect() {
            void visit(Element e, int? block) {
              final w = e.widget;
              if (w is BlockRenderer) {
                block = w.blockIndex;
                rendered.add(block);
              } else if (block != null && w is RichText && w.text.toPlainText().trim().isNotEmpty) {
                withContent.add(block);
              }
              e.visitChildElements((c) => visit(c, block));
            }

            visit(tester.binding.rootElement!, null);
          }

          // Scroll through the whole page so lazily built blocks get laid out.
          final scrollable = find.byType(Scrollable).first;
          collect();
          for (var i = 0; i < 60; i++) {
            final state = tester.state<ScrollableState>(scrollable);
            if (state.position.pixels >= state.position.maxScrollExtent) break;
            state.position.jumpTo(state.position.pixels + 500);
            await tester.pump();
            collect();
          }
          final where = '${book.title} pdf page ${page.pdfPage}';
          expect(tester.takeException(), isNull, reason: where);
          expect(rendered, isNotEmpty, reason: '$where rendered no blocks');
          expect(rendered.difference(withContent), isEmpty, reason: '$where: blocks rendered without text');
        }
      });
    }
  }
}
