import 'package:flutter_test/flutter_test.dart';
import 'package:muallim_ul_quran/models/content_block.dart';

import '../helpers.dart';

/// Volume 2 goes through the same parser as Volume 1; these cover the
/// shapes that only appear in Volume 2.
void main() {
  final book = loadBook(vol2Path);

  Iterable<(int, ContentBlock)> blocks() sync* {
    for (final p in book.pages) {
      for (final b in p.blocks) {
        yield (p.pdfPage, b);
      }
    }
  }

  test('parses all 115 pages with no unknown blocks', () {
    expect(book.title, 'Muallim-Ul-Quran Volume 2');
    expect(book.length, 115);
    expect(book.pages.every((p) => p.blocks.isNotEmpty), isTrue);
    expect([for (final (pg, b) in blocks()) if (b is UnknownBlock) '$pg:${b.type}'], isEmpty);
  });

  test('builds units 4 and 5 from page fields', () {
    expect(book.units.map((u) => u.unit), [4, 5]);
    expect(book.units.every((u) => u.title != null), isTrue);
    expect(book.units[0].lessons.length, 17);
    expect(book.units[1].lessons.length, 23);
    // key_words / quranic_style pages stay inside their lessons.
    final lesson20 = book.units[1].lessons.firstWhere((l) => l.lessonLabel == '20');
    expect(lesson20.pageCount, 4);
  });

  test('quran_verse with an items list keeps every verse', () {
    final verse = blocks().map((e) => e.$2).whereType<QuranVerseBlock>().single;
    expect(verse.allVerses, hasLength(3));
    expect(verse.allVerses.first, contains('ضَلَالٍ'));
  });

  test('unit_summary_box reads its heading from `title`', () {
    final boxes = [
      for (final (_, b) in blocks())
        if (b is TextBlock && b.type == 'unit_summary_box') b,
    ];
    expect(boxes, hasLength(2));
    expect(boxes.every((b) => (b.label ?? b.text).isNotEmpty && b.items.isNotEmpty), isTrue);
    expect(boxes.any((b) => b.label == 'فہم قرآن میں یونٹ 5 کا کردار'), isTrue);
  });

  test('tables whose rows are lists keep all cells, aligned to the printed columns', () {
    final listTables = [
      for (final (_, b) in blocks())
        if (b is TableBlock && b.keys.first.startsWith('#')) b,
    ];
    expect(listTables, hasLength(2));
    for (final t in listTables) {
      expect(t.headers, ['مثال', 'کالم 1', '', 'کالم 2']);
      expect(t.rows, hasLength(3));
      for (final row in t.rows) {
        expect(row.values.every((v) => v != null && v.isNotEmpty), isTrue);
        expect(row.values.elementAt(2), '←');
      }
    }
    expect(listTables.first.rows.first.values, ['مثال 1', 'قَوْلٌ : قول، بات', '←', 'قَوْلًا : قول کے اعتبار سے']);
  });

  test('extra row keys get clean headers', () {
    final tables = [for (final (_, b) in blocks()) if (b is TableBlock) b];
    final pluralNote = tables.firstWhere((t) => t.keys.contains('note'));
    expect(pluralNote.headers, ['واحد', 'جمع', '']);
    // Every table has as many headers as columns of data.
    expect(tables.every((t) => t.headers.length == t.keys.length && t.rows.isNotEmpty), isTrue);
  });

  test('model-paper questions carry their marks', () {
    final marked = [for (final (_, b) in blocks()) if (b is QuestionBlock && b.marks != null) b];
    expect(marked.map((q) => q.marks), [10, 10, 10, 20]);
  });

  test('printed contents rows resolve to pages', () {
    final toc = book.firstPageOfKind('table_of_contents')!;
    final rows = toc.blocks.whereType<TableBlock>().expand((t) => t.rows).toList();
    expect(rows, isNotEmpty);
    // One row in the source has no page number; the app skips such rows.
    for (final r in rows.where((r) => r['صفحہ'] != null)) {
      final i = book.indexForPrintedPage(r['صفحہ']!);
      expect(i, isNotNull, reason: 'printed page ${r['صفحہ']}');
    }
    // "هُوَ + رَسُولٌ" — lesson 1 of unit 4 — is on printed page 2.
    expect(book.pages[book.indexForPrintedPage('2')!].lessonLabel, '1');
  });

  test('every page kind maps to a label', () {
    expect(book.pages.map((p) => p.pageKind).whereType<String>().toSet(),
        {'guidance_notes', 'table_of_contents', 'unit_cover', 'model_paper', 'quranic_style', 'key_words'});
    final modelPaper = book.pages.firstWhere((p) => p.pageKind == 'model_paper');
    expect(book.locationLabel(modelPaper), 'یونٹ 4 · ماڈل پیپر');
  });
}
