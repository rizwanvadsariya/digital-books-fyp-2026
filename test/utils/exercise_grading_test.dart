import 'package:flutter_test/flutter_test.dart';
import 'package:fehm_e_quran/utils/exercise_grading.dart';

void main() {
  group('gradeWordAnswer', () {
    test('no key is ungraded', () {
      expect(gradeWordAnswer(1, 'anything', null), isNull);
    });

    test('type 1 (meaning): accepts any comma-separated alternative', () {
      expect(gradeWordAnswer(1, 'ایک مؤمن', 'ایک مؤمن'), isTrue);
      expect(gradeWordAnswer(1, 'حسن', 'جمال، حسن'), isTrue);
      expect(gradeWordAnswer(1, 'جمال', 'جمال، حسن'), isTrue);
      expect(gradeWordAnswer(1, 'کچھ اور', 'جمال، حسن'), isFalse);
    });

    test('type 2/4/6/8/9/12 (word forms): ignores diacritics', () {
      expect(gradeWordAnswer(2, 'الشرك', 'الشِّرْك'), isTrue);
      expect(gradeWordAnswer(8, 'اقلام', 'أَقْلَام'), isTrue);
      expect(gradeWordAnswer(12, 'لا علم', 'لَا عِلْمَ'), isTrue);
      expect(gradeWordAnswer(12, 'لا رزق', 'لَا عِلْمَ'), isFalse);
    });

    test('type 5 (diacritics): requires exact harakat', () {
      expect(gradeWordAnswer(5, 'الْكَعْبَة', 'الْكَعْبَة'), isTrue);
      expect(gradeWordAnswer(5, 'الكعبة', 'الْكَعْبَة'), isFalse);
    });

    test('type 10 (singular/plural mix): ignores the parenthesised hint', () {
      expect(gradeWordAnswer(10, 'اقلام', 'أَقْلَام (جمع)'), isTrue);
      expect(gradeWordAnswer(10, 'قبر', 'قَبْر (مفرد)'), isTrue);
      expect(gradeWordAnswer(10, '(جمع)', 'أَقْلَام (جمع)'), isFalse);
    });

    test('type 11 (phrase translation): lenient like other types', () {
      expect(gradeWordAnswer(11, 'الكتاب والحكمة', 'الْكِتَابُ وَالْحِكْمَةُ'), isTrue);
    });
  });

  group('gradeHighlightSelection', () {
    test('single expected word', () {
      expect(gradeHighlightSelection({'اللهُ'}, 'اللهُ'), isTrue);
      expect(gradeHighlightSelection({'الْبَيْت'}, 'اللهُ'), isFalse);
    });

    test('several required spans must all be selected', () {
      const expected = 'غَفُورٌ، رَّحِيمٌ';
      expect(gradeHighlightSelection({'غَفُورٌ', 'رَّحِيمٌ'}, expected), isTrue);
      expect(gradeHighlightSelection({'غَفُورٌ'}, expected), isFalse);
      expect(gradeHighlightSelection({'غَفُورٌ', 'رَّحِيمٌ', 'شَكُورٌ'}, expected), isFalse);
    });

    test('ignores diacritics', () {
      expect(gradeHighlightSelection({'الشرك'}, 'الشِّرْك'), isTrue);
    });
  });

  group('gradeWordSet', () {
    test('matches the full set regardless of order', () {
      final expected = ['الْقَمَر', 'اللَّيْل', 'الصُّبْح'];
      expect(gradeWordSet('الصبح، الليل، القمر', expected), isTrue);
      expect(gradeWordSet('القمر، الليل', expected), isFalse);
      expect(gradeWordSet('القمر، الليل، الصبح، شیء اضافی', expected), isFalse);
    });

    test('single-item set', () {
      expect(gradeWordSet('السماء', ['السَّمَاء']), isTrue);
      expect(gradeWordSet('الارض', ['السَّمَاء']), isFalse);
    });
  });
}
