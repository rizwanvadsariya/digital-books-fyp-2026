enum KeyboardLanguage { arabic, urdu }

/// Diacritics row shown on both layouts: fatha, damma, kasra, fathatan,
/// dammatan, kasratan, shadda, sukun, superscript alef, and tatweel.
const harakatKeys = [
  'َ', // fatha
  'ُ', // damma
  'ِ', // kasra
  'ً', // fathatan
  'ٌ', // dammatan
  'ٍ', // kasratan
  'ّ', // shadda
  'ْ', // sukun
  'ٰ', // superscript alef
  'ـ', // tatweel
];

const harakatNames = {
  'َ': 'زبر',
  'ُ': 'پیش',
  'ِ': 'زیر',
  'ً': 'دو زبر',
  'ٌ': 'دو پیش',
  'ٍ': 'دو زیر',
  'ّ': 'شد',
  'ْ': 'جزم',
  'ٰ': 'کھڑا زبر',
  'ـ': 'کشیدہ',
};

/// Standard Arabic (101) letter layout, right-to-left per row.
const arabicRows = [
  ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج'],
  ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ط'],
  ['ذ', 'ء', 'ؤ', 'ر', 'ى', 'ة', 'و', 'ز', 'ظ', 'د'],
  ['أ', 'إ', 'آ', 'ٱ', 'ئ', 'لا'],
];

/// Urdu layout (phonetic arrangement), covering every Urdu letter.
const urduRows = [
  ['ق', 'و', 'ع', 'ر', 'ت', 'ے', 'ء', 'ی', 'ہ', 'پ'],
  ['ا', 'س', 'د', 'ف', 'گ', 'ح', 'ج', 'ک', 'ل', 'ٹ'],
  ['ز', 'ش', 'چ', 'ط', 'ب', 'ن', 'م', 'ں', 'ڈ', 'ڑ'],
  ['آ', 'ص', 'ض', 'ذ', 'ث', 'ظ', 'خ', 'غ', 'ژ', 'ھ', 'ۓ'],
];

List<List<String>> symbolRows(KeyboardLanguage language) => [
      language == KeyboardLanguage.urdu
          ? ['۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', '۰']
          : ['١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '٠'],
      ['(', ')', '/', '-', ':', '؛', '«', '»', '"', '!'],
      ['ئ', 'ؤ', 'ۃ', 'ۀ', 'ة', 'ي', 'ك', 'ه', 'ى'],
      ['ﷲ', 'ﷺ', '۔', '.', '؟'],
    ];

List<List<String>> letterRows(KeyboardLanguage language) =>
    language == KeyboardLanguage.urdu ? urduRows : arabicRows;
