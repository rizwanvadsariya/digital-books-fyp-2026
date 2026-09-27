// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Muallim-ul-Quran';

  @override
  String get navHome => 'Home';

  @override
  String get navContents => 'Contents';

  @override
  String get navBookmarks => 'Bookmarks';

  @override
  String get navSearch => 'Search';

  @override
  String get continueReading => 'Continue reading';

  @override
  String get startReading => 'Start reading';

  @override
  String get readFromStart => 'Read from the beginning';

  @override
  String get myAnswers => 'My answers';

  @override
  String myAnswersCount(int count) {
    return 'My answers ($count)';
  }

  @override
  String get settings => 'Settings';

  @override
  String get loadFailed => 'Couldn\'t load the book';

  @override
  String get retry => 'Try again';

  @override
  String unitN(String unit) {
    return 'Unit $unit';
  }

  @override
  String lessonN(String lesson) {
    return 'Lesson $lesson';
  }

  @override
  String unitLesson(String unit, String lesson) {
    return 'Unit $unit · Lesson $lesson';
  }

  @override
  String unitIntro(String unit) {
    return 'Unit $unit · Introduction';
  }

  @override
  String get unitGeneric => 'Unit';

  @override
  String get sampleExam => 'Sample exam';

  @override
  String get tableOfContents => 'Contents';

  @override
  String get backMatter => 'Closing notes';

  @override
  String get introduction => 'Introduction';

  @override
  String pageN(String page) {
    return 'Page $page';
  }

  @override
  String pageShort(String page) {
    return 'p. $page';
  }

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$_temp0';
  }

  @override
  String totalPages(int count) {
    return '$count pages in total';
  }

  @override
  String get chipFront => 'Introduction';

  @override
  String get chipExtra => 'Exam & index';

  @override
  String get chipPrinted => 'Book\'s contents';

  @override
  String get sectionFront => 'Introduction & preface';

  @override
  String get sectionExtra => 'Exam & appendix';

  @override
  String get sectionPrinted => 'The book\'s original contents';

  @override
  String get addBookmark => 'Add bookmark';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get readingSettings => 'Reading settings';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String get noBookmarksTitle => 'No bookmarks yet';

  @override
  String get noBookmarksHint => 'Tap the bookmark icon at the top of any page';

  @override
  String get searchHint => 'Search Arabic words, verses or Urdu text';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get searchResultsMax => '200+ results';

  @override
  String get deleteAllAnswers => 'Delete all answers';

  @override
  String get deleteAllAnswersQuestion => 'Delete all answers?';

  @override
  String get removeAllBookmarks => 'Remove all bookmarks';

  @override
  String get removeAllBookmarksQuestion => 'Remove all bookmarks?';

  @override
  String get cannotBeUndone => 'This can\'t be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String get open => 'Open';

  @override
  String get noAnswersYet => 'No answers saved yet';

  @override
  String get correctAnswerLabel => 'Correct answer: ';

  @override
  String correctShort(String answer) {
    return 'Correct: $answer';
  }

  @override
  String get hintMeaning => 'Meaning';

  @override
  String get hintTranslation => 'Translation';

  @override
  String get hintWriteAnswer => 'Write your answer';

  @override
  String get hintWriteArabic => 'Write in Arabic';

  @override
  String get hintIdentifyPart => 'Write the requested part';

  @override
  String get checkAnswer => 'Check answer';

  @override
  String get singular => 'Singular';

  @override
  String get plural => 'Plural';

  @override
  String get listenRecitation => 'Listen to recitation';

  @override
  String get recitationComingSoon => 'Recitation audio is coming soon.';

  @override
  String get keyboardArabic => 'Arabic';

  @override
  String get keyboardUrdu => 'Urdu';

  @override
  String get useArabicKeyboard => 'Arabic keyboard';

  @override
  String get useDeviceKeyboard => 'Use the device keyboard';

  @override
  String get closeKeyboard => 'Close keyboard';

  @override
  String get harakaFatha => 'Fatha (zabar)';

  @override
  String get harakaDamma => 'Damma (pesh)';

  @override
  String get harakaKasra => 'Kasra (zer)';

  @override
  String get harakaFathatan => 'Fathatan';

  @override
  String get harakaDammatan => 'Dammatan';

  @override
  String get harakaKasratan => 'Kasratan';

  @override
  String get harakaShadda => 'Shadda';

  @override
  String get harakaSukun => 'Sukun (jazm)';

  @override
  String get harakaAlef => 'Superscript alef';

  @override
  String get harakaTatweel => 'Tatweel';

  @override
  String get pageColor => 'Page color';

  @override
  String get themePaper => 'Paper';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get themeDark => 'Night';

  @override
  String get fontSize => 'Book text size';

  @override
  String get practiceMode => 'Practice mode';

  @override
  String get practiceModeHint =>
      'Hide the book\'s printed meanings and translations and test yourself';

  @override
  String get strictMatching => 'Strict checking';

  @override
  String get strictMatchingHint =>
      'Harakat (zabar, zer, pesh) must also match when checking answers';

  @override
  String get allSettings => 'All settings';

  @override
  String get sectionLanguage => 'App language';

  @override
  String get languageHint =>
      'Changes menus, buttons and labels only. The book\'s own text always stays in Urdu and Arabic.';

  @override
  String get languageSystem => 'System default';

  @override
  String get sectionReading => 'Reading';

  @override
  String get sectionExercises => 'Exercises';

  @override
  String get sectionData => 'Your data';

  @override
  String get sectionAbout => 'About';

  @override
  String answersSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers saved',
      one: '1 answer saved',
      zero: 'No answers saved',
    );
    return '$_temp0';
  }

  @override
  String bookmarksSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookmarks',
      one: '1 bookmark',
      zero: 'No bookmarks',
    );
    return '$_temp0';
  }

  @override
  String get aboutBook =>
      'Muallim-ul-Quran, Volume 1 — an easy, complete system for understanding the Quran yourself.';

  @override
  String get licenses => 'Licenses';

  @override
  String get previewCaption => 'Preview';

  @override
  String volumeN(int number) {
    return 'Volume $number';
  }

  @override
  String unitsRange(String range) {
    return 'Units $range';
  }

  @override
  String get modelPaper => 'Model paper';

  @override
  String unitModelPaper(String unit) {
    return 'Unit $unit · Model paper';
  }

  @override
  String get guidanceNotes => 'Guidance notes';

  @override
  String sectionDataForVolume(int number) {
    return 'Your data · Volume $number';
  }

  @override
  String marksN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marks',
      one: '1 mark',
    );
    return '$_temp0';
  }
}
