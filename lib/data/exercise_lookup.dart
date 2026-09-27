import '../blocs/answers_cubit.dart';
import '../models/book.dart';
import '../models/content_block.dart';

class ExerciseInfo {
  const ExerciseInfo({required this.page, required this.prompt, this.question, this.answerKey});

  final BookPage page;

  /// The word/verse/row the answer belongs to.
  final String prompt;

  /// The question or instruction text the exercise sits under, if any.
  final String? question;

  /// The book's own answer, when it prints one.
  final String? answerKey;
}

/// Resolves a saved answer ID back to what it answers.
ExerciseInfo? describeAnswer(Book book, String id) {
  final parts = AnswerIdParts.parse(id);
  if (parts == null) return null;
  final index = book.indexForPdfPage(parts.pdfPage);
  if (index == null) return null;
  final page = book.pages[index];
  if (parts.blockIndex >= page.blocks.length) return null;
  final block = page.blocks[parts.blockIndex];
  final item = int.tryParse(parts.item);

  T? at<T>(List<T> list, int? i) => i != null && i >= 0 && i < list.length ? list[i] : null;

  switch (block) {
    case QuestionBlock b:
      final prompt = at(b.items, item) ?? at(b.verses, item) ?? b.text;
      return ExerciseInfo(page: page, prompt: prompt, question: b.text);
    case TextBlock b:
      return ExerciseInfo(page: page, prompt: at(b.items, item) ?? b.text, question: b.text);
    case VocabListBlock b:
      final v = at(b.items, item);
      if (v == null) return null;
      return ExerciseInfo(page: page, prompt: v.arabic, answerKey: v.meaning);
    case VocabPairListBlock b:
      final v = at(b.items, item);
      if (v == null) return null;
      return ExerciseInfo(page: page, prompt: v.pair ?? v.singular ?? '', answerKey: v.note);
    case VerseTranslateBlock b:
      final v = at(b.items, item);
      if (v == null) return null;
      return ExerciseInfo(page: page, prompt: v.verse, answerKey: v.translation);
    case TableBlock b:
      final rc = parts.item.split('-').map(int.tryParse).toList();
      if (rc.length != 2 || rc.contains(null)) return null;
      final row = at(b.rows, rc[0]);
      if (row == null || rc[1]! >= b.keys.length) return null;
      final prompt = [
        for (var c = 0; c < b.keys.length; c++)
          if (c != rc[1] && row[b.keys[c]] != null && !b.headers[c].startsWith('مثال')) row[b.keys[c]]!,
      ].join(' · ');
      return ExerciseInfo(page: page, prompt: prompt, question: b.headers[rc[1]!], answerKey: row[b.keys[rc[1]!]]);
    default:
      return ExerciseInfo(page: page, prompt: '');
  }
}
