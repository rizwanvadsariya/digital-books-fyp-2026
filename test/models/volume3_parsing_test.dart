import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muallim_ul_quran/models/content_block.dart';

import '../helpers.dart';

/// Volume 3 goes through the same parser as Volumes 1–2; these cover the
/// shapes that only appear in Volume 3.
void main() {
  final book = loadBook(vol3Path);

  Iterable<(int, ContentBlock)> blocks() sync* {
    for (final p in book.pages) {
      for (final b in p.blocks) {
        yield (p.pdfPage, b);
      }
    }
  }

  test('uses no block type or style that Volumes 1–2 lack', () {
    Set<String> field(String path, String name) {
      final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      return {
        for (final p in json['pages'] as List)
          for (final b in (p as Map)['blocks'] as List)
            if ((b as Map)[name] != null) b[name] as String,
      };
    }

    for (final name in ['type', 'style']) {
      final known = field(vol1Path, name).union(field(vol2Path, name));
      expect(field(vol3Path, name).difference(known), isEmpty, reason: 'new $name values');
    }
  });

  test('parses all 86 pages with no unknown or empty blocks', () {
    expect(book.length, 86);
    expect(book.pages.every((p) => p.blocks.isNotEmpty), isTrue);
    expect([for (final (pg, b) in blocks()) if (b is UnknownBlock) '$pg:${b.type}'], isEmpty);
    expect([for (final (pg, b) in blocks()) if (b is VocabListBlock && b.items.isEmpty) pg], isEmpty);
    expect([for (final (pg, b) in blocks()) if (b is TableBlock && b.rows.isEmpty) pg], isEmpty);
  });

  test('builds unit 6 with 21 lessons, cover attached', () {
    expect(book.units.map((u) => u.unit), [6]);
    final unit = book.units.single;
    expect(unit.lessons.map((l) => l.lessonLabel), [for (var i = 1; i <= 21; i++) '$i']);
    expect(book.pages[unit.coverPageIndex].pageKind, 'unit_cover');
    expect(unit.title, isNotNull);
  });

  test('vocab_list of plain strings becomes words without meanings', () {
    final list = blocks().map((e) => e.$2).whereType<VocabListBlock>().single;
    expect(list.items, hasLength(15));
    expect(list.items.first.arabic, 'رَبِّي يَعْلَمُ الْقَوْلَ');
    expect(list.items.every((i) => i.meaning == null), isTrue);
  });

  test('an unheaded row-label column shifts the headers into place', () {
    final t = [for (final (pg, b) in blocks()) if (pg == 30 && b is TableBlock) b].single;
    expect(t.headers, ['', 'کالم 1', 'کالم 2']);
    expect(t.rows.first[t.keyForHeader('کالم 1')], 'یَعْبُدُ : وہ عبادت کرتا ہے');
    // Tables whose rows match their headers are left alone.
    final aligned = [for (final (pg, b) in blocks()) if (pg == 59 && b is TableBlock) b].single;
    expect(aligned.headers, ['فعل', 'اس کا مطلب', 'آخر میں اضافہ', 'مطلب']);
    // Every table ends up with one header per column.
    final tables = [for (final (_, b) in blocks()) if (b is TableBlock) b];
    expect(tables, hasLength(21));
    expect(tables.every((t) => t.headers.length == t.keys.length), isTrue);
  });

  test('the "index" pages are the printed contents and their rows resolve', () {
    expect(book.contentsPages.map((p) => p.pdfPage), [3, 4]);
    var resolved = 0;
    for (final page in book.contentsPages) {
      for (final t in page.blocks.whereType<TableBlock>()) {
        final pageKey = t.keyForHeader('صفحہ')!;
        for (final r in t.rows) {
          final printed = r[pageKey];
          if (printed == null) continue;
          expect(book.indexForPrintedPage(printed), isNotNull, reason: 'printed page $printed');
          resolved++;
        }
      }
    }
    expect(resolved, greaterThan(20));
    // "02" (zero-padded) is lesson 1.
    expect(book.pages[book.indexForPrintedPage('02')!].lessonLabel, '1');
  });

  test('front matter is decided by position, not by a missing unit', () {
    expect(book.frontMatter.map((p) => p.pageKind), ['preface', 'instructions']);
    final index = book.contentsPages.first;
    expect(book.locationLabel(index), 'فہرست');
    expect(book.locationLabel(book.frontMatter[1]), 'ہدایات');
  });

  test('earlier volumes keep the same front matter and contents', () {
    final v1 = loadBook(vol1Path);
    final v2 = loadBook(vol2Path);
    expect(v1.frontMatter.map((p) => p.pdfPage), [for (var i = 1; i <= 9; i++) i]);
    expect(v1.contentsPages.map((p) => p.pageKind), ['table_of_contents']);
    expect(v2.frontMatter.map((p) => p.pageKind), ['guidance_notes']);
    expect(v2.contentsPages.map((p) => p.pdfPage), [2]);
  });
}
