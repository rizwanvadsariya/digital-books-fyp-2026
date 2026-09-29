// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'فہم القرآن';

  @override
  String get navHome => 'ہوم';

  @override
  String get navContents => 'فہرست';

  @override
  String get navBookmarks => 'بک مارکس';

  @override
  String get navSearch => 'تلاش';

  @override
  String get continueReading => 'پڑھنا جاری رکھیں';

  @override
  String get startReading => 'پڑھنا شروع کریں';

  @override
  String get readFromStart => 'شروع سے پڑھیں';

  @override
  String get myAnswers => 'میرے جوابات';

  @override
  String myAnswersCount(int count) {
    return 'میرے جوابات ($count)';
  }

  @override
  String get settings => 'ترتیبات';

  @override
  String get loadFailed => 'کتاب لوڈ نہیں ہو سکی';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String unitN(String unit) {
    return 'یونٹ $unit';
  }

  @override
  String lessonN(String lesson) {
    return 'سبق $lesson';
  }

  @override
  String unitLesson(String unit, String lesson) {
    return 'یونٹ $unit · سبق $lesson';
  }

  @override
  String unitIntro(String unit) {
    return 'یونٹ $unit · تعارف';
  }

  @override
  String get unitGeneric => 'یونٹ';

  @override
  String get sampleExam => 'نمونہ امتحان';

  @override
  String get tableOfContents => 'فہرست';

  @override
  String get backMatter => 'اختتامیہ';

  @override
  String get introduction => 'مقدمہ';

  @override
  String pageN(String page) {
    return 'صفحہ $page';
  }

  @override
  String pageShort(String page) {
    return 'ص $page';
  }

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحات',
      one: '1 صفحہ',
    );
    return '$_temp0';
  }

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اسباق',
      one: '1 سبق',
    );
    return '$_temp0';
  }

  @override
  String totalPages(int count) {
    return 'کُل $count صفحات';
  }

  @override
  String get chipFront => 'مقدمہ';

  @override
  String get chipExtra => 'امتحان و فہرست';

  @override
  String get chipPrinted => 'کتاب کی فہرست';

  @override
  String get sectionFront => 'مقدمہ اور تعارف';

  @override
  String get sectionExtra => 'امتحان اور ضمیمہ';

  @override
  String get sectionPrinted => 'کتاب کی اصل فہرست';

  @override
  String get addBookmark => 'بک مارک لگائیں';

  @override
  String get removeBookmark => 'بک مارک ہٹائیں';

  @override
  String get readingSettings => 'پڑھنے کی ترتیبات';

  @override
  String get previousPage => 'پچھلا صفحہ';

  @override
  String get nextPage => 'اگلا صفحہ';

  @override
  String get noBookmarksTitle => 'ابھی کوئی بک مارک نہیں';

  @override
  String get noBookmarksHint => 'کسی صفحے پر اوپر بک مارک کا نشان دبائیں';

  @override
  String get searchHint => 'عربی لفظ، آیت یا اردو متن تلاش کریں';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتائج',
      zero: 'کوئی نتیجہ نہیں',
    );
    return '$_temp0';
  }

  @override
  String get searchResultsMax => '200+ نتائج';

  @override
  String get deleteAllAnswers => 'سب جوابات مٹائیں';

  @override
  String get deleteAllAnswersQuestion => 'سب جوابات مٹائیں؟';

  @override
  String get removeAllBookmarks => 'سب بک مارک ہٹائیں';

  @override
  String get removeAllBookmarksQuestion => 'سب بک مارک ہٹائیں؟';

  @override
  String get cannotBeUndone => 'یہ عمل واپس نہیں ہو سکتا۔';

  @override
  String get cancel => 'منسوخ';

  @override
  String get delete => 'مٹائیں';

  @override
  String get remove => 'ہٹائیں';

  @override
  String get open => 'کھولیں';

  @override
  String get noAnswersYet => 'ابھی کوئی جواب محفوظ نہیں ہوا';

  @override
  String get correctAnswerLabel => 'درست جواب: ';

  @override
  String correctShort(String answer) {
    return 'درست: $answer';
  }

  @override
  String get hintMeaning => 'مطلب';

  @override
  String get hintTranslation => 'ترجمہ';

  @override
  String get hintWriteAnswer => 'یہاں جواب لکھیں';

  @override
  String get hintWriteArabic => 'یہاں عربی لکھیں';

  @override
  String get hintIdentifyPart => 'مطلوبہ حصہ یہاں لکھیں';

  @override
  String get checkAnswer => 'جواب چیک کریں';

  @override
  String get singular => 'واحد';

  @override
  String get plural => 'جمع';

  @override
  String get listenRecitation => 'تلاوت سنیں';

  @override
  String get recitationComingSoon => 'تلاوت کی آڈیو جلد شامل کی جائے گی۔';

  @override
  String get keyboardArabic => 'عربی';

  @override
  String get keyboardUrdu => 'اردو';

  @override
  String get useArabicKeyboard => 'عربی کی بورڈ';

  @override
  String get useDeviceKeyboard => 'فون کا کی بورڈ استعمال کریں';

  @override
  String get closeKeyboard => 'کی بورڈ بند کریں';

  @override
  String get harakaFatha => 'زبر';

  @override
  String get harakaDamma => 'پیش';

  @override
  String get harakaKasra => 'زیر';

  @override
  String get harakaFathatan => 'دو زبر';

  @override
  String get harakaDammatan => 'دو پیش';

  @override
  String get harakaKasratan => 'دو زیر';

  @override
  String get harakaShadda => 'شد';

  @override
  String get harakaSukun => 'جزم';

  @override
  String get harakaAlef => 'کھڑا زبر';

  @override
  String get harakaTatweel => 'کشیدہ';

  @override
  String get pageColor => 'صفحے کا رنگ';

  @override
  String get themePaper => 'کاغذ';

  @override
  String get themeSepia => 'سیپیا';

  @override
  String get themeDark => 'رات';

  @override
  String get fontSize => 'کتاب کے حروف کا سائز';

  @override
  String get practiceMode => 'مشق موڈ';

  @override
  String get practiceModeHint =>
      'کتاب میں لکھے معانی اور ترجمے چھپا کر خود جانچیں';

  @override
  String get strictMatching => 'سخت جانچ';

  @override
  String get strictMatchingHint =>
      'جواب چیک کرتے وقت اعراب (زبر، زیر، پیش) بھی ملائیں';

  @override
  String get allSettings => 'تمام ترتیبات';

  @override
  String get sectionLanguage => 'ایپ کی زبان';

  @override
  String get languageHint =>
      'صرف مینو، بٹن اور لیبل بدلیں گے۔ کتاب کا اپنا متن ہمیشہ اردو اور عربی میں رہے گا۔';

  @override
  String get languageSystem => 'سسٹم کے مطابق';

  @override
  String get sectionReading => 'مطالعہ';

  @override
  String get sectionExercises => 'مشقیں';

  @override
  String get sectionData => 'آپ کا ڈیٹا';

  @override
  String get sectionAbout => 'ایپ کے بارے میں';

  @override
  String answersSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جوابات محفوظ',
      zero: 'کوئی جواب محفوظ نہیں',
    );
    return '$_temp0';
  }

  @override
  String bookmarksSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بک مارکس',
      zero: 'کوئی بک مارک نہیں',
    );
    return '$_temp0';
  }

  @override
  String get aboutBook =>
      'معلم القرآن، جلد اوّل — قرآن کریم خود سمجھنے کا ایک آسان انداز اور جامع نظام۔';

  @override
  String get licenses => 'لائسنس';

  @override
  String get previewCaption => 'نمونہ';

  @override
  String volumeN(int number) {
    return 'جلد $number';
  }

  @override
  String unitsRange(String range) {
    return 'یونٹ $range';
  }

  @override
  String get modelPaper => 'ماڈل پیپر';

  @override
  String unitModelPaper(String unit) {
    return 'یونٹ $unit · ماڈل پیپر';
  }

  @override
  String get guidanceNotes => 'ہدایات';

  @override
  String sectionDataForVolume(int number) {
    return 'آپ کا ڈیٹا · جلد $number';
  }

  @override
  String marksN(int count) {
    return '$count نمبر';
  }
}
