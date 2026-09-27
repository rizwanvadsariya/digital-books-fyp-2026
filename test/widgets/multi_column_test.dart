import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muallim_ul_quran/models/book.dart';
import 'package:muallim_ul_quran/models/content_block.dart';
import 'package:muallim_ul_quran/widgets/blocks/block_renderer.dart';
import 'package:muallim_ul_quran/widgets/common/responsive_grid.dart';

import '../helpers.dart';

/// Multi-column blocks from Volume 2 use the book's `columns` hint, dropping
/// columns only when the screen is too narrow.
void main() {
  final book = loadBook(vol2Path);

  (BookPage, int) firstBlock(bool Function(ContentBlock b) test) {
    for (final p in book.pages) {
      for (var i = 0; i < p.blocks.length; i++) {
        if (test(p.blocks[i])) return (p, i);
      }
    }
    throw StateError('no such block');
  }

  Future<void> pumpBlock(WidgetTester tester, BookPage page, int index, double width) async {
    tester.view.physicalSize = Size(width, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(harness(
      SingleChildScrollView(
        child: BlockRenderer(block: page.blocks[index], pdfPage: page.pdfPage, blockIndex: index),
      ),
      store: await freshStore(),
    ));
    expect(tester.takeException(), isNull);
  }

  /// Number of grid cells laid out on the first row.
  int firstRowCount(WidgetTester tester) {
    final grid = find.byType(ResponsiveGrid).first;
    final cells = find.descendant(of: grid, matching: find.byType(SizedBox)).evaluate().where((e) {
      final parent = (e.findAncestorWidgetOfExactType<Wrap>());
      return parent != null && (e.widget as SizedBox).width != null && (e.widget as SizedBox).width! > 60;
    }).toList();
    final firstTop = tester.getTopLeft(find.byWidget(cells.first.widget)).dy;
    return cells.where((e) => tester.getTopLeft(find.byWidget(e.widget)).dy == firstTop).length;
  }

  for (final columns in [2, 3, 4]) {
    testWidgets('vocab_pair_list with $columns columns: all $columns on a tablet, fewer on a phone', (tester) async {
      final (page, i) = firstBlock((b) => b is VocabPairListBlock && b.columns == columns && b.items.length > columns);
      await pumpBlock(tester, page, i, 1000);
      expect(firstRowCount(tester), columns);
      await pumpBlock(tester, page, i, 360);
      expect(firstRowCount(tester), lessThanOrEqualTo(columns));
      expect(firstRowCount(tester), greaterThanOrEqualTo(1));
    });
  }

  testWidgets('quran_verse_translate with 2 columns lays out side by side on a tablet', (tester) async {
    final (page, i) = firstBlock((b) => b is VerseTranslateBlock && b.columns == 2 && b.items.length > 2);
    await pumpBlock(tester, page, i, 1000);
    expect(firstRowCount(tester), 2);
    await pumpBlock(tester, page, i, 360);
    expect(firstRowCount(tester), 1);
  });

  testWidgets('five-column table keeps every header, ordered right-to-left', (tester) async {
    final (page, i) = firstBlock((b) => b is TableBlock && b.headers.length == 5);
    final table = page.blocks[i] as TableBlock;
    await pumpBlock(tester, page, i, 390);
    final xs = [for (final h in table.headers) tester.getCenter(find.text(h).first).dx];
    for (var c = 1; c < xs.length; c++) {
      expect(xs[c], lessThan(xs[c - 1]), reason: 'column $c should sit left of column ${c - 1}');
    }
  });

  testWidgets('table with list rows renders all four cells per row', (tester) async {
    final (page, i) = firstBlock((b) => b is TableBlock && b.keys.first.startsWith('#'));
    await pumpBlock(tester, page, i, 390);
    expect(find.text('←'), findsNWidgets(3));
    expect(find.text('قَوْلٌ : قول، بات'), findsOneWidget);
    final table = tester.widget<Table>(find.byType(Table));
    expect(table.children.every((row) => row.children.length == 4), isTrue);
  });
}
