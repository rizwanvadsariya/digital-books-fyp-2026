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
  for (final path in [vol1Path, vol2Path]) {
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
          void collect() {
            for (final element in find.byType(BlockRenderer).evaluate()) {
              final block = element.widget as BlockRenderer;
              rendered.add(block.blockIndex);
              final hasText = find
                  .descendant(of: find.byWidget(block), matching: find.byType(RichText))
                  .evaluate()
                  .any((e) => (e.widget as RichText).text.toPlainText().trim().isNotEmpty);
              if (hasText) withContent.add(block.blockIndex);
            }
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
