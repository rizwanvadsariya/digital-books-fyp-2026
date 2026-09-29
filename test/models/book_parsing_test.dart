import 'package:flutter_test/flutter_test.dart';
import 'package:fehm_e_quran/models/content_block.dart';

import '../helpers.dart';

void main() {
  final book = loadBook();

  test('parses every page and block of the real book', () {
    expect(book.length, 102);
    final unknown = [
      for (final p in book.pages)
        for (final b in p.blocks)
          if (b is UnknownBlock) '${p.pdfPage}:${b.type}',
    ];
    expect(
      unknown,
      isEmpty,
      reason: 'every block type in the data should have a typed model',
    );
  });

  test('unknown block types fall back instead of throwing', () {
    final b = ContentBlock.fromJson({
      'type': 'future_widget',
      'text': 'hello',
      'extra': {'nested': 'world'},
    });
    expect(b, isA<UnknownBlock>());
    expect((b as UnknownBlock).texts, ['hello', 'world']);
  });

  test('known type with a malformed shape falls back', () {
    final b = ContentBlock.fromJson({
      'type': 'vocab_list',
      'items': 'not a list',
    });
    expect(b, isA<VocabListBlock>());
    expect((b as VocabListBlock).items, isEmpty);
  });

  test('builds the unit → lesson structure from page fields', () {
    expect(book.units.map((u) => u.unit), [1, 2, 3]);
    final unit1 = book.units.first;
    expect(unit1.title, isNotNull);
    expect(unit1.lessons.first.lessonLabel, '1');
    expect(unit1.lessons.any((l) => l.lessonLabel == '15-16'), isTrue);
    for (final unit in book.units) {
      for (final l in unit.lessons) {
        expect(book.pages[l.firstPageIndex].unit, unit.unit);
      }
    }
  });

  test('tables keep repeated headers but use disambiguated row keys', () {
    final table = book.pages[book.indexForPdfPage(35)!].blocks
        .whereType<TableBlock>()
        .first;
    expect(table.headers.where((h) => h == 'مطلب').length, 2);
    expect(table.keys, contains('مطلب ۲'));
    expect(table.rows.first['مطلب ۲'], isNotNull);
  });

  test('"red" vocab note is a marker, not a meaning', () {
    final items = [
      for (final p in book.pages)
        for (final b in p.blocks.whereType<VocabListBlock>()) ...b.items,
    ];
    final red = items.where((i) => i.isRedMarker);
    expect(red, isNotEmpty);
    expect(red.every((i) => i.meaning == null), isTrue);
  });

  test('printed page numbers map back to pages', () {
    final p = book.pages[20];
    expect(book.indexForPrintedPage(p.printedPage!), 20);
  });
}
