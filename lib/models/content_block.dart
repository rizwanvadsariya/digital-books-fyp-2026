import 'block_style.dart';

/// Every `type` string emitted by the extraction that maps to a [TextBlock].
const textBlockTypes = {
  'book_title',
  'title',
  'unit_title',
  'section_heading',
  'heading',
  'subheading',
  'section_marker',
  'unit_marker',
  'lesson_marker',
  'tagline',
  'paragraph',
  'instruction',
  'translation_line',
  'list_item',
  'note',
  'note_box',
  'highlight',
  'unit_summary_box',
  'copyright_notice',
  'signature_block',
};

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

int? _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

List<String> _strList(dynamic v) {
  if (v is! List) return const [];
  return [for (final e in v) if (e != null) e.toString()];
}

List<Map<String, dynamic>> _mapList(dynamic v) {
  if (v is! List) return const [];
  return [for (final e in v) if (e is Map) Map<String, dynamic>.from(e)];
}

/// One typed content block from a page's `blocks` array.
///
/// [ContentBlock.fromJson] never throws on unexpected input: unknown types (or
/// known types with unexpected shapes) become an [UnknownBlock] that renders
/// whatever text it can find.
sealed class ContentBlock {
  const ContentBlock({required this.type, required this.style, this.highlight = false});

  final String type;
  final BlockStyle style;
  final bool highlight;

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final type = _str(json['type']) ?? 'unknown';
    final style = BlockStyle.parse(_str(json['style']));
    final highlight = json['highlight'] == true;
    try {
      switch (type) {
        case 'vocab_list':
          return VocabListBlock(
            type: type,
            style: style,
            highlight: highlight,
            columns: _int(json['columns']),
            items: [
              for (final m in (json['items'] is List ? json['items'] as List : const []))
                if (m is Map)
                  VocabItem(
                    arabic: _str(m['arabic']) ?? '',
                    note: _str(m['note']),
                    note2: _str(m['note2']),
                  )
                // Volume 3 lists bare phrases: a word with no printed meaning.
                else if (m is String && m.trim().isNotEmpty)
                  VocabItem(arabic: m),
            ],
          );
        case 'vocab_pair_list':
          return VocabPairListBlock(
            type: type,
            style: style,
            highlight: highlight,
            columns: _int(json['columns']),
            items: [
              for (final m in _mapList(json['items']))
                VocabPairItem(
                  pair: _str(m['pair']),
                  singular: _str(m['singular']),
                  plural: _str(m['plural']),
                  singularMeaning: _str(m['singular_meaning']),
                  pluralMeaning: _str(m['plural_meaning']),
                  note: _str(m['note']),
                ),
            ],
          );
        case 'quran_verse_translate':
          return VerseTranslateBlock(
            type: type,
            style: style,
            highlight: highlight,
            columns: _int(json['columns']),
            items: [
              for (final m in _mapList(json['items']))
                VerseTranslation(
                  verse: _str(m['verse']) ?? '',
                  translation: _str(m['translation']),
                ),
            ],
          );
        case 'table':
          return TableBlock.fromJson(json, style: style, highlight: highlight);
        case 'question':
          return QuestionBlock.fromJson(json, type: type, style: style, highlight: highlight);
        case 'quran_verse':
          return QuranVerseBlock(
            type: type,
            style: style,
            highlight: highlight,
            text: _str(json['text']) ?? '',
            note: _str(json['note']),
            // Volume 2 groups several verses in one block as `items`.
            verses: _strList(json['items']),
          );
        case 'bullet_list':
          return BulletListBlock(
            type: type,
            style: style,
            highlight: highlight,
            items: _strList(json['items']),
          );
      }
      if (textBlockTypes.contains(type)) {
        return TextBlock(
          type: type,
          style: style,
          highlight: highlight,
          text: _str(json['text']) ?? '',
          number: _int(json['number']),
          // Volume 2's unit_summary_box names its heading `title`.
          label: _str(json['label']) ?? _str(json['title']),
          date: _str(json['date']),
          bullet: json['bullet'] == true,
          items: _strList(json['items']),
        );
      }
    } catch (_) {
      // Fall through to the generic renderer below.
    }
    return UnknownBlock(type: type, style: style, highlight: highlight, raw: json);
  }
}

/// Any block whose content is primarily a single run of text: titles,
/// headings, markers, paragraphs, notes, boxes, etc. The widget layer decides
/// presentation from [type] and [style].
class TextBlock extends ContentBlock {
  const TextBlock({
    required super.type,
    required super.style,
    super.highlight,
    required this.text,
    this.number,
    this.label,
    this.date,
    this.bullet = false,
    this.items = const [],
  });

  final String text;
  final int? number;
  final String? label;
  final String? date;
  final bool bullet;

  /// Sub-items (e.g. the words listed under an `instruction`, or the
  /// paragraphs of a `unit_summary_box`).
  final List<String> items;
}

class VocabItem {
  const VocabItem({required this.arabic, this.note, this.note2});

  final String arabic;
  final String? note;
  final String? note2;

  /// In the source data `"red"` marks the word as newly introduced (printed in
  /// red); it is a formatting flag, not a meaning.
  bool get isRedMarker => note == 'red';

  /// The Urdu meaning printed in the book, if any.
  String? get meaning => isRedMarker ? null : note;
}

class VocabListBlock extends ContentBlock {
  const VocabListBlock({
    required super.type,
    required super.style,
    super.highlight,
    this.columns,
    required this.items,
  });

  final int? columns;
  final List<VocabItem> items;
}

/// Either a singular/plural pair or an Arabic phrase with its Urdu meaning.
class VocabPairItem {
  const VocabPairItem({
    this.pair,
    this.singular,
    this.plural,
    this.singularMeaning,
    this.pluralMeaning,
    this.note,
  });

  final String? pair;
  final String? singular;
  final String? plural;
  final String? singularMeaning;
  final String? pluralMeaning;
  final String? note;

  bool get isSingularPlural => singular != null || plural != null;
}

class VocabPairListBlock extends ContentBlock {
  const VocabPairListBlock({
    required super.type,
    required super.style,
    super.highlight,
    this.columns,
    required this.items,
  });

  final int? columns;
  final List<VocabPairItem> items;
}

class VerseTranslation {
  const VerseTranslation({required this.verse, this.translation});

  final String verse;

  /// `null` means the book leaves this line blank for the student.
  final String? translation;
}

class VerseTranslateBlock extends ContentBlock {
  const VerseTranslateBlock({
    required super.type,
    required super.style,
    super.highlight,
    this.columns,
    required this.items,
  });

  final int? columns;
  final List<VerseTranslation> items;
}

/// A table whose rows are keyed by column header text.
///
/// The printed `columns` list can repeat a header (e.g. two `مطلب` columns),
/// while row keys are disambiguated (`مطلب`, `مطلب ۲`), and some tables have
/// no `columns` at all. [keys] is the authoritative column order taken from
/// the rows; [headers] are display labels aligned with [keys].
class TableBlock extends ContentBlock {
  const TableBlock({
    required super.type,
    required super.style,
    super.highlight,
    required this.keys,
    required this.headers,
    required this.rows,
    this.caption,
    this.name,
    this.showHeader = true,
  });

  factory TableBlock.fromJson(
    Map<String, dynamic> json, {
    required BlockStyle style,
    required bool highlight,
  }) {
    final columns = [
      for (final c in (json['columns'] is List ? json['columns'] as List : const [])) c?.toString() ?? '',
    ];
    // Rows are usually maps keyed by header; some (Volumes 2–3) are plain
    // lists matched to `columns` by position. Positional keys keep blank or
    // repeated headers distinct.
    final rowsJson = json['rows'] is List ? json['rows'] as List : const [];
    final rawRows = <Map<String, dynamic>>[
      for (final r in rowsJson)
        if (r is Map)
          Map<String, dynamic>.from(r)
        else if (r is List)
          {for (var i = 0; i < r.length; i++) '#$i': r[i]},
    ];
    final keys = <String>[];
    for (final r in rawRows) {
      for (final k in r.keys) {
        if (!keys.contains(k)) keys.add(k);
      }
    }
    // Volume 3 list rows often start with an unheaded row label ("مثال 1"):
    // one more cell than headers. Shift the headers past that label column.
    final listRowWidth = rowsJson.whereType<List>().fold<int>(0, (w, r) => r.length > w ? r.length : w);
    final labelOffset = listRowWidth == columns.length + 1 ? 1 : 0;
    final headers = [
      for (var i = 0; i < keys.length; i++)
        columns.length == keys.length && labelOffset == 0
            ? columns[i]
            : _headerFor(keys[i], keys, columns, labelOffset),
    ];
    final isLabelText = keys.length == 2 && keys.contains('label') && keys.contains('text');
    return TableBlock(
      type: 'table',
      style: style,
      highlight: highlight,
      keys: keys,
      headers: headers,
      rows: [
        for (final r in rawRows) {for (final k in keys) k: _str(r[k])},
      ],
      caption: _str(json['caption']),
      name: _str(json['name']),
      showHeader: !isLabelText,
    );
  }

  /// Display header for a row key when `columns` doesn't line up with the
  /// keys: positional keys use the printed column (after any unheaded row
  /// label column, which gets a blank header), a disambiguated duplicate
  /// (`مطلب2`, `مطلب ۲`) shows its base header, and `note` shows no header.
  static String _headerFor(String key, List<String> keys, List<String> columns, int labelOffset) {
    if (key.startsWith('#')) {
      final i = int.tryParse(key.substring(1));
      if (i == null) return '';
      final c = i - labelOffset;
      return c >= 0 && c < columns.length ? columns[c] : '';
    }
    if (key == 'note') return '';
    final base = key.replaceFirst(RegExp(r'\s*[0-9۰-۹٠-٩]+$'), '');
    if (base != key && keys.contains(base)) return base;
    return key;
  }

  final List<String> keys;
  final List<String> headers;
  final List<Map<String, String?>> rows;

  /// Row key of the column printed under [header], whether rows are keyed
  /// by header text or by position.
  String? keyForHeader(String header) {
    final i = headers.indexOf(header);
    return i < 0 ? null : keys[i];
  }
  final String? caption;
  final String? name;
  final bool showHeader;
}

class QuestionBlock extends ContentBlock {
  const QuestionBlock({
    required super.type,
    required super.style,
    super.highlight,
    this.number,
    required this.text,
    this.items = const [],
    this.verses = const [],
    this.marks,
    this.exerciseType,
    this.gradable,
    this.answers,
    this.answerWords,
    this.answerWordSets,
  });

  factory QuestionBlock.fromJson(
    Map<String, dynamic> json, {
    required String type,
    required BlockStyle style,
    required bool highlight,
  }) {
    // `answer_words` is either one expected span per verse (exercise 7, a
    // plain string, "، "-joined when several spans are required) or one set
    // of required words per verse (exercise 13, a list) — never mixed within
    // a block.
    final rawAnswerWords = json['answer_words'];
    List<String?>? answerWords;
    List<List<String>?>? answerWordSets;
    if (rawAnswerWords is List) {
      if (rawAnswerWords.any((e) => e is List)) {
        answerWordSets = [
          for (final e in rawAnswerWords) e is List ? [for (final w in e) w.toString()] : null,
        ];
      } else {
        answerWords = [for (final e in rawAnswerWords) _str(e)];
      }
    }
    final rawAnswers = json['answers'];
    final answers = rawAnswers is List ? [for (final e in rawAnswers) _str(e)] : null;
    return QuestionBlock(
      type: type,
      style: style,
      highlight: highlight,
      number: _int(json['number']),
      text: _str(json['text']) ?? '',
      items: _strList(json['items']),
      verses: _strList(json['verses']),
      marks: _int(json['marks']),
      exerciseType: _int(json['exercise_type']),
      gradable: json['gradable'] is bool ? json['gradable'] as bool : null,
      answers: answers,
      answerWords: answerWords,
      answerWordSets: answerWordSets,
    );
  }

  final int? number;
  final String text;

  /// Marks awarded, on model-paper questions.
  final int? marks;

  /// Words/phrases the student answers about (usually translate orally).
  final List<String> items;

  /// Quranic snippets in which the student identifies/highlights a part.
  final List<String> verses;

  /// One of the 14 graded exercise shapes (see the data model notes), or
  /// `null` for a question with no answer key at all.
  final int? exerciseType;

  /// Whether this exercise has a right/wrong answer. `false` for open-ended
  /// discussion (type 3) and reference-only explanations (type 14).
  final bool? gradable;

  /// Answer key parallel to [items]. A `null` entry means no key is
  /// available for that item (show it ungraded, never mark it wrong).
  final List<String?>? answers;

  /// Exercise 7 (highlight): the expected span parallel to [verses], one or
  /// more words joined by "، " when several words must be selected.
  final List<String?>? answerWords;

  /// Exercise 13 (oath): the expected set of words parallel to [verses].
  final List<List<String>?>? answerWordSets;

  /// Whether item/verse [i] has an answer key to grade against.
  bool hasKeyAt(int i) {
    if (gradable == false) return false;
    if (answers != null) return i < answers!.length && answers![i] != null;
    if (answerWords != null) return i < answerWords!.length && answerWords![i] != null;
    if (answerWordSets != null) return i < answerWordSets!.length && answerWordSets![i] != null;
    return false;
  }
}

class QuranVerseBlock extends ContentBlock {
  const QuranVerseBlock({
    required super.type,
    required super.style,
    super.highlight,
    required this.text,
    this.note,
    this.verses = const [],
  });

  final String text;
  final String? note;

  /// Several verses in one block (Volume 2 uses `items` for this).
  final List<String> verses;

  /// Every verse in the block, whichever form the data used.
  List<String> get allVerses => [if (text.isNotEmpty) text, ...verses];
}

class BulletListBlock extends ContentBlock {
  const BulletListBlock({
    required super.type,
    required super.style,
    super.highlight,
    required this.items,
  });

  final List<String> items;
}

/// Fallback for block types this app version doesn't know about.
class UnknownBlock extends ContentBlock {
  const UnknownBlock({
    required super.type,
    required super.style,
    super.highlight,
    required this.raw,
  });

  final Map<String, dynamic> raw;

  /// Every string found anywhere in the block, in document order.
  List<String> get texts {
    final out = <String>[];
    void walk(dynamic v, String? key) {
      if (key == 'type' || key == 'style') return;
      if (v is String && v.isNotEmpty) {
        out.add(v);
      } else if (v is Map) {
        v.forEach((k, e) => walk(e, k.toString()));
      } else if (v is List) {
        for (final e in v) {
          walk(e, null);
        }
      }
    }

    walk(raw, null);
    return out;
  }
}
