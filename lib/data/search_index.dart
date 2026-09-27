import '../models/book.dart';
import '../models/content_block.dart';
import '../utils/arabic_text.dart';

class SearchHit {
  const SearchHit({required this.pageIndex, required this.text});

  final int pageIndex;
  final String text;
}

/// Full-text search over every text, Arabic word and verse in the book.
/// Matching ignores harakat and Arabic/Urdu spelling variants, so typing
/// `الكتاب` finds `الْكِتَابُ`.
class SearchIndex {
  SearchIndex(Book book) {
    for (final page in book.pages) {
      for (final block in page.blocks) {
        for (final text in _textsOf(block)) {
          final t = text.trim();
          if (t.isEmpty) continue;
          _entries.add((page.index, t, normalizeForSearch(t)));
        }
      }
    }
  }

  final _entries = <(int, String, String)>[];

  List<SearchHit> search(String query, {int limit = 200}) {
    final q = normalizeForSearch(query);
    if (q.isEmpty) return const [];
    final hits = <SearchHit>[];
    final seen = <String>{};
    for (final (page, text, norm) in _entries) {
      if (!norm.contains(q)) continue;
      if (!seen.add('$page|$text')) continue;
      hits.add(SearchHit(pageIndex: page, text: text));
      if (hits.length >= limit) break;
    }
    return hits;
  }

  static Iterable<String> _textsOf(ContentBlock block) sync* {
    switch (block) {
      case TextBlock b:
        yield b.text;
        if (b.label != null) yield b.label!;
        yield* b.items;
      case VocabListBlock b:
        for (final i in b.items) {
          yield i.meaning == null ? i.arabic : '${i.arabic} — ${i.meaning}';
        }
      case VocabPairListBlock b:
        for (final i in b.items) {
          yield [i.pair, i.singular, i.plural, i.note].whereType<String>().join(' — ');
        }
      case VerseTranslateBlock b:
        for (final i in b.items) {
          yield i.translation == null ? i.verse : '${i.verse} — ${i.translation}';
        }
      case TableBlock b:
        for (final row in b.rows) {
          yield row.values.whereType<String>().join(' · ');
        }
      case QuestionBlock b:
        yield b.text;
        yield* b.items;
        yield* b.verses;
      case QuranVerseBlock b:
        yield* b.allVerses;
        if (b.note != null) yield b.note!;
      case BulletListBlock b:
        yield* b.items;
      case UnknownBlock b:
        yield* b.texts;
    }
  }
}
