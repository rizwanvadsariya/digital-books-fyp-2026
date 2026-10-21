/// Grading rules for the 14 `question` exercise types in Volume 1's answer
/// key data. Types 3 (open-ended) and 14 (explanation) are ungraded and
/// never call into this file.
library;

import 'arabic_text.dart';

/// Grades a text answer for exercise types 1, 2, 4, 5, 6, 8, 9, 10, 11 and 12.
/// [key] is the book's printed answer; `null` means no key is available.
///
/// Type 5 (add diacritics) compares strictly, including harakat. Type 10
/// (singular/plural mix) carries a parenthesised hint ("أَقْلَام (جمع)") that
/// isn't part of the expected answer. Every other type compares leniently,
/// ignoring diacritics and orthographic letter variants, and accepts any
/// one of the book's comma/slash-separated alternatives.
bool? gradeWordAnswer(int? exerciseType, String input, String? key) {
  if (key == null) return null;
  if (exerciseType == 5) {
    return answerMatches(input, key, strict: true);
  }
  if (exerciseType == 10) {
    final arabic = key.split('(').first.trim();
    return answerMatches(input, arabic, strict: false);
  }
  return answerMatches(input, key, strict: false);
}

/// Exercise type 7: the learner taps one or more words in a verse.
/// [expected] lists the required span(s), several joined by "، ".
bool gradeHighlightSelection(Set<String> selected, String expected) {
  final required = expected.split('، ').map(normalizeForSearch).where((s) => s.isNotEmpty).toSet();
  final given = selected.map(normalizeForSearch).where((s) => s.isNotEmpty).toSet();
  return required.isNotEmpty && required.length == given.length && required.containsAll(given);
}

/// Exercise type 13: the learner names every item of a set (e.g. everything
/// sworn by in a verse), typed separated by commas.
bool gradeWordSet(String input, List<String> expected) {
  final required = expected.map(normalizeForSearch).where((s) => s.isNotEmpty).toSet();
  final given = input
      .split(RegExp(r'[,،]'))
      .map(normalizeForSearch)
      .where((s) => s.isNotEmpty)
      .toSet();
  return required.isNotEmpty && required.length == given.length && required.containsAll(given);
}
