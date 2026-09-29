import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fehm_e_quran/models/book.dart';
import 'package:fehm_e_quran/models/content_block.dart';
import 'package:fehm_e_quran/theme/book_theme.dart';
import 'package:fehm_e_quran/widgets/blocks/block_renderer.dart';
import 'package:fehm_e_quran/widgets/blocks/styled_frame.dart';
import 'package:fehm_e_quran/widgets/reader_navigation.dart';

import '../helpers.dart';

/// Volume 3 blocks render through the shared widgets: RTL text, highlight
/// styles, and the table/vocab shapes specific to this volume.
void main() {
  final book = loadBook(vol3Path);

  Future<void> pumpBlock(
    WidgetTester tester,
    BookPage page,
    int index, {
    void Function(int)? onJump,
  }) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      harness(
        ReaderNavigation(
          book: book,
          goToIndex: onJump ?? (_) {},
          child: SingleChildScrollView(
            child: BlockRenderer(
              block: page.blocks[index],
              pdfPage: page.pdfPage,
              blockIndex: index,
            ),
          ),
        ),
        store: await freshStore(),
      ),
    );
    expect(tester.takeException(), isNull);
  }

  List<(BookPage, int)> where(bool Function(ContentBlock b) test) => [
    for (final p in book.pages)
      for (var i = 0; i < p.blocks.length; i++)
        if (test(p.blocks[i])) (p, i),
  ];

  /// Text styles of every visible text span under the block.
  List<TextStyle> spanStyles(WidgetTester tester) {
    final styles = <TextStyle>[];
    for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
      void walk(InlineSpan span, TextStyle? inherited) {
        final style = inherited?.merge(span.style) ?? span.style;
        if (span is TextSpan) {
          if ((span.text ?? '').trim().isNotEmpty && style != null) {
            styles.add(style);
          }
          for (final c in span.children ?? const <InlineSpan>[]) {
            walk(c, style);
          }
        }
      }

      walk(rich.text, null);
    }
    return styles;
  }

  testWidgets('every highlighted red style renders red text', (tester) async {
    final red = where((b) => b.highlight && b.style.red);
    expect(red, isNotEmpty);
    for (final (page, i) in red) {
      await pumpBlock(tester, page, i);
      expect(
        spanStyles(tester).any((s) => s.color == BookTheme.paperTheme.red),
        isTrue,
        reason: 'pdf ${page.pdfPage} block $i (${page.blocks[i].style.raw})',
      );
    }
  });

  testWidgets('red_bold_large_centered titles are bold, large and centered', (
    tester,
  ) async {
    final titles = where((b) => b.style.raw == 'red_bold_large_centered');
    expect(titles, hasLength(33));
    final (page, i) = titles.first;
    await pumpBlock(tester, page, i);
    final rich = tester.widget<RichText>(find.byType(RichText).first);
    expect(rich.textAlign, TextAlign.center);
    final style = spanStyles(tester).first;
    expect(style.fontWeight, FontWeight.w700);
    expect(style.fontSize, greaterThan(20));
  });

  testWidgets('badge and ornamental styles get their frames', (tester) async {
    Future<void> expectFrame(String raw, Finder frame) async {
      final (page, i) = where((b) => b.style.raw == raw).first;
      await pumpBlock(tester, page, i);
      expect(frame, findsWidgets, reason: raw);
    }

    await expectFrame(
      'black_badge',
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color ==
                BookTheme.paperTheme.badgeBg,
      ),
    );
    await expectFrame(
      'circle_badge',
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle,
      ),
    );
    await expectFrame(
      'boxed_ornamental',
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is OrnamentalFramePainter,
      ),
    );
    await expectFrame('ornamental_badge', find.byType(CustomPaint));
  });

  testWidgets('Urdu and Arabic text is laid out right-to-left', (tester) async {
    final (page, i) = where((b) => b is TextBlock && b.type == 'paragraph')
        .first;
    await pumpBlock(tester, page, i);
    for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
      expect(rich.textDirection, TextDirection.rtl);
    }
  });

  testWidgets('row-label tables line headers up with their cells', (
    tester,
  ) async {
    final (page, i) = where((b) => b is TableBlock && b.headers.first.isEmpty)
        .first;
    final table = page.blocks[i] as TableBlock;
    await pumpBlock(tester, page, i);
    for (var c = 1; c < table.headers.length; c++) {
      final header = tester.getCenter(find.text(table.headers[c]).first).dx;
      final cell = tester
          .getCenter(find.text(table.rows.first[table.keys[c]]!).first)
          .dx;
      expect(
        (header - cell).abs(),
        lessThan(2),
        reason: 'column "${table.headers[c]}"',
      );
    }
    // The label column holds "مثال 1" etc.
    expect(find.text('مثال 1'), findsOneWidget);
  });

  testWidgets('plain-string vocab list renders a card and blank per phrase', (
    tester,
  ) async {
    final (page, i) = where((b) => b is VocabListBlock).single;
    await pumpBlock(tester, page, i);
    expect(find.text('رَبِّي يَعْلَمُ الْقَوْلَ'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(15));
  });

  testWidgets('tapping a row of the "index" contents page jumps to that page', (
    tester,
  ) async {
    final page = book.contentsPages.first;
    final i = page.blocks.indexWhere((b) => b is TableBlock);
    int? jumped;
    await pumpBlock(tester, page, i, onJump: (index) => jumped = index);
    await tester.tap(find.text('(اہم قرآنی افعال)'));
    expect(jumped, isNotNull);
    expect(book.pages[jumped!].lessonLabel, '1');
  });
}
