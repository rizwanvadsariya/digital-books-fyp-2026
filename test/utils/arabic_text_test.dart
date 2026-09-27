import 'package:flutter_test/flutter_test.dart';
import 'package:muallim_ul_quran/utils/arabic_text.dart';

void main() {
  group('answerMatches', () {
    test('lenient ignores harakat and Arabic/Urdu letter variants', () {
      expect(answerMatches('الكتاب', 'الْكِتَابُ', strict: false), isTrue);
      expect(answerMatches('یہ حلال ہے', 'يه حلال هے', strict: false), isTrue);
      expect(answerMatches('  کتاب ', 'کتاب', strict: false), isTrue);
    });

    test('lenient accepts any printed alternative', () {
      const key = 'ایمان پر/ایمان سے/ایمان کو';
      expect(answerMatches('ایمان سے', key, strict: false), isTrue);
      expect(answerMatches('ایمان میں', key, strict: false), isFalse);
    });

    test('strict requires identical harakat', () {
      expect(answerMatches('الْكِتَابُ', 'الْكِتَابُ', strict: true), isTrue);
      expect(answerMatches('الكتاب', 'الْكِتَابُ', strict: true), isFalse);
    });

    test('empty answer never matches', () {
      expect(answerMatches('', 'کتاب', strict: false), isFalse);
    });
  });

  test('stripDiacritics removes harakat but keeps letters', () {
    expect(stripDiacritics('مُحَمَّدٌ'), 'محمد');
  });

  test('splits mixed Urdu prose and vocalised Arabic into runs', () {
    final runs = splitScriptRuns('انہی الفاظ کے شروع میں (إِنَّ، مِنْ) سے');
    expect(runs.map((r) => r.script), [Script.urdu, Script.arabic, Script.urdu]);
    expect(runs.map((r) => r.text).join(), 'انہی الفاظ کے شروع میں (إِنَّ، مِنْ) سے');
  });

  test('classifies whole strings', () {
    expect(dominantScript('وَاللَّهُ غَفُورٌ'), Script.arabic);
    expect(dominantScript('اور اللہ غفور ہے'), Script.urdu);
  });
}
