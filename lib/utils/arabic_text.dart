/// Text helpers for mixed Arabic / Urdu content.
library;

/// Harakat, Quranic annotation marks, superscript alef and tatweel.
final _diacritics = RegExp(
  '[ؐ-ًؚ-ٰٟۖ-ۭـ]',
);

final _punctuation = RegExp(r'''[،؛؟۔.,;:!?()\[\]{}"'«»\-–—_…]''');
final _spaces = RegExp(r'\s+');

String stripDiacritics(String s) => s.replaceAll(_diacritics, '');

/// Folds spelling variants that differ between Arabic and Urdu orthography
/// (ي/ی, ك/ک, ه/ہ, alef forms, ...) so a learner's answer typed on either
/// layout compares equal to the book's text.
String normalizeForSearch(String s) {
  var out = stripDiacritics(s);
  const map = {
    'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
    'ي': 'ی', 'ى': 'ی', 'ې': 'ی', 'ئ': 'ی', 'ے': 'ی', 'ۓ': 'ی',
    'ك': 'ک',
    'ه': 'ہ', 'ة': 'ہ', 'ۃ': 'ہ', 'ھ': 'ہ', 'ۀ': 'ہ',
    'ؤ': 'و',
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
    '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  };
  final buf = StringBuffer();
  for (final rune in out.runes) {
    final ch = String.fromCharCode(rune);
    buf.write(map[ch] ?? ch);
  }
  out = buf.toString().replaceAll('‌', '').replaceAll('‍', '');
  return out.replaceAll(_punctuation, ' ').replaceAll(_spaces, ' ').trim().toLowerCase();
}

/// Compares a learner's [input] with the book's [key].
///
/// Strict mode requires the same letters *and* harakat (ignoring surrounding
/// whitespace). Lenient mode ignores harakat and orthographic variants, and
/// accepts any one of the alternatives the book separates with `/` or `،`
/// (e.g. "ایمان پر/ایمان سے/ایمان کو").
bool answerMatches(String input, String key, {required bool strict}) {
  if (strict) {
    String squash(String s) => s.replaceAll(_spaces, ' ').trim();
    return squash(input) == squash(key);
  }
  final given = normalizeForSearch(input);
  if (given.isEmpty) return false;
  if (given == normalizeForSearch(key)) return true;
  final alternatives = key.split(RegExp(r'[/،,]'));
  return alternatives.any((alt) => normalizeForSearch(alt) == given);
}

enum Script { arabic, urdu, neutral }

const _urduOnly = 'ٹڈڑںھہےۓیکگپچژۃۀ';
const _arabicOnly = 'يكهةىٱإأؤئ';

/// Classifies a single word. Quranic Arabic in this book is fully vocalised
/// and uses Arabic letter forms (ي ك ه ة), while Urdu uses its own forms
/// (ی ک ہ ے). Words with neither signal are [Script.neutral].
Script classifyWord(String word) {
  var urdu = 0;
  var arabic = 0;
  for (final rune in word.runes) {
    final ch = String.fromCharCode(rune);
    if (_urduOnly.contains(ch)) urdu++;
    if (_arabicOnly.contains(ch)) arabic++;
    if ((rune >= 0x064B && rune <= 0x0652) || rune == 0x0670) arabic++;
  }
  if (urdu == 0 && arabic == 0) return Script.neutral;
  return arabic > urdu ? Script.arabic : Script.urdu;
}

class ScriptRun {
  const ScriptRun(this.text, this.script);
  final String text;
  final Script script;
}

/// Splits [text] into maximal runs of the same script. Neutral words (plain
/// letters, digits, punctuation, whitespace) join the preceding run, or the
/// [fallback] script at the start.
List<ScriptRun> splitScriptRuns(String text, {Script fallback = Script.urdu}) {
  final parts = RegExp(r'\S+|\s+').allMatches(text).map((m) => m.group(0)!);
  final runs = <ScriptRun>[];
  var current = StringBuffer();
  Script? currentScript;
  for (final part in parts) {
    var script = part.trim().isEmpty ? Script.neutral : classifyWord(part);
    if (script == Script.neutral) script = currentScript ?? fallback;
    if (currentScript != null && script != currentScript) {
      runs.add(ScriptRun(current.toString(), currentScript));
      current = StringBuffer();
    }
    currentScript = script;
    current.write(part);
  }
  if (currentScript != null && current.isNotEmpty) {
    runs.add(ScriptRun(current.toString(), currentScript));
  }
  return runs;
}

/// Script of a whole string, used to pick a block's primary font.
Script dominantScript(String text, {Script fallback = Script.urdu}) {
  var urdu = 0;
  var arabic = 0;
  for (final w in text.split(_spaces)) {
    switch (classifyWord(w)) {
      case Script.arabic:
        arabic++;
      case Script.urdu:
        urdu++;
      case Script.neutral:
        break;
    }
  }
  if (urdu == 0 && arabic == 0) return fallback;
  return arabic >= urdu ? Script.arabic : Script.urdu;
}
