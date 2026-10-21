import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fehm-e-Quran'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get navContents;

  /// No description provided for @navBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get navBookmarks;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReading;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start reading'**
  String get startReading;

  /// No description provided for @readFromStart.
  ///
  /// In en, this message translates to:
  /// **'Read from the beginning'**
  String get readFromStart;

  /// No description provided for @myAnswers.
  ///
  /// In en, this message translates to:
  /// **'My answers'**
  String get myAnswers;

  /// No description provided for @myAnswersCount.
  ///
  /// In en, this message translates to:
  /// **'My answers ({count})'**
  String myAnswersCount(int count);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the book'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @unitN.
  ///
  /// In en, this message translates to:
  /// **'Unit {unit}'**
  String unitN(String unit);

  /// No description provided for @lessonN.
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson}'**
  String lessonN(String lesson);

  /// No description provided for @unitLesson.
  ///
  /// In en, this message translates to:
  /// **'Unit {unit} · Lesson {lesson}'**
  String unitLesson(String unit, String lesson);

  /// No description provided for @unitIntro.
  ///
  /// In en, this message translates to:
  /// **'Unit {unit} · Introduction'**
  String unitIntro(String unit);

  /// No description provided for @unitGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitGeneric;

  /// No description provided for @sampleExam.
  ///
  /// In en, this message translates to:
  /// **'Sample exam'**
  String get sampleExam;

  /// No description provided for @tableOfContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get tableOfContents;

  /// No description provided for @backMatter.
  ///
  /// In en, this message translates to:
  /// **'Closing notes'**
  String get backMatter;

  /// No description provided for @introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introduction;

  /// No description provided for @pageN.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String pageN(String page);

  /// No description provided for @pageShort.
  ///
  /// In en, this message translates to:
  /// **'p. {page}'**
  String pageShort(String page);

  /// No description provided for @pagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pagesCount(int count);

  /// No description provided for @lessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson} other{{count} lessons}}'**
  String lessonsCount(int count);

  /// No description provided for @totalPages.
  ///
  /// In en, this message translates to:
  /// **'{count} pages in total'**
  String totalPages(int count);

  /// No description provided for @chipFront.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get chipFront;

  /// No description provided for @chipExtra.
  ///
  /// In en, this message translates to:
  /// **'Exam & index'**
  String get chipExtra;

  /// No description provided for @chipPrinted.
  ///
  /// In en, this message translates to:
  /// **'Book\'s contents'**
  String get chipPrinted;

  /// No description provided for @sectionFront.
  ///
  /// In en, this message translates to:
  /// **'Introduction & preface'**
  String get sectionFront;

  /// No description provided for @sectionExtra.
  ///
  /// In en, this message translates to:
  /// **'Exam & appendix'**
  String get sectionExtra;

  /// No description provided for @sectionPrinted.
  ///
  /// In en, this message translates to:
  /// **'The book\'s original contents'**
  String get sectionPrinted;

  /// No description provided for @addBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get addBookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @readingSettings.
  ///
  /// In en, this message translates to:
  /// **'Reading settings'**
  String get readingSettings;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @noBookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get noBookmarksTitle;

  /// No description provided for @noBookmarksHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon at the top of any page'**
  String get noBookmarksHint;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Arabic words, verses or Urdu text'**
  String get searchHint;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String searchResults(int count);

  /// No description provided for @searchResultsMax.
  ///
  /// In en, this message translates to:
  /// **'200+ results'**
  String get searchResultsMax;

  /// No description provided for @deleteAllAnswers.
  ///
  /// In en, this message translates to:
  /// **'Delete all answers'**
  String get deleteAllAnswers;

  /// No description provided for @deleteAllAnswersQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete all answers?'**
  String get deleteAllAnswersQuestion;

  /// No description provided for @removeAllBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Remove all bookmarks'**
  String get removeAllBookmarks;

  /// No description provided for @removeAllBookmarksQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove all bookmarks?'**
  String get removeAllBookmarksQuestion;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get cannotBeUndone;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @noAnswersYet.
  ///
  /// In en, this message translates to:
  /// **'No answers saved yet'**
  String get noAnswersYet;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: '**
  String get correctAnswerLabel;

  /// No description provided for @correctShort.
  ///
  /// In en, this message translates to:
  /// **'Correct: {answer}'**
  String correctShort(String answer);

  /// No description provided for @hintMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get hintMeaning;

  /// No description provided for @hintTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get hintTranslation;

  /// No description provided for @hintWriteAnswer.
  ///
  /// In en, this message translates to:
  /// **'Write your answer'**
  String get hintWriteAnswer;

  /// No description provided for @hintWriteArabic.
  ///
  /// In en, this message translates to:
  /// **'Write in Arabic'**
  String get hintWriteArabic;

  /// No description provided for @hintIdentifyPart.
  ///
  /// In en, this message translates to:
  /// **'Write the requested part'**
  String get hintIdentifyPart;

  /// No description provided for @hintNameTheSet.
  ///
  /// In en, this message translates to:
  /// **'List them, separated by commas'**
  String get hintNameTheSet;

  /// No description provided for @hintTapToHighlight.
  ///
  /// In en, this message translates to:
  /// **'Tap the word(s) to highlight'**
  String get hintTapToHighlight;

  /// No description provided for @checkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get checkAnswer;

  /// No description provided for @markAsCorrect.
  ///
  /// In en, this message translates to:
  /// **'Mark as correct'**
  String get markAsCorrect;

  /// No description provided for @showModelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show model answer'**
  String get showModelAnswer;

  /// No description provided for @resetExercise.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetExercise;

  /// No description provided for @scoreFraction.
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total}'**
  String scoreFraction(int correct, int total);

  /// No description provided for @singular.
  ///
  /// In en, this message translates to:
  /// **'Singular'**
  String get singular;

  /// No description provided for @plural.
  ///
  /// In en, this message translates to:
  /// **'Plural'**
  String get plural;

  /// No description provided for @listenRecitation.
  ///
  /// In en, this message translates to:
  /// **'Listen to recitation'**
  String get listenRecitation;

  /// No description provided for @recitationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Recitation audio is coming soon.'**
  String get recitationComingSoon;

  /// No description provided for @keyboardArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get keyboardArabic;

  /// No description provided for @keyboardUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get keyboardUrdu;

  /// No description provided for @useArabicKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Arabic keyboard'**
  String get useArabicKeyboard;

  /// No description provided for @useDeviceKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Use the device keyboard'**
  String get useDeviceKeyboard;

  /// No description provided for @closeKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Close keyboard'**
  String get closeKeyboard;

  /// No description provided for @harakaFatha.
  ///
  /// In en, this message translates to:
  /// **'Fatha (zabar)'**
  String get harakaFatha;

  /// No description provided for @harakaDamma.
  ///
  /// In en, this message translates to:
  /// **'Damma (pesh)'**
  String get harakaDamma;

  /// No description provided for @harakaKasra.
  ///
  /// In en, this message translates to:
  /// **'Kasra (zer)'**
  String get harakaKasra;

  /// No description provided for @harakaFathatan.
  ///
  /// In en, this message translates to:
  /// **'Fathatan'**
  String get harakaFathatan;

  /// No description provided for @harakaDammatan.
  ///
  /// In en, this message translates to:
  /// **'Dammatan'**
  String get harakaDammatan;

  /// No description provided for @harakaKasratan.
  ///
  /// In en, this message translates to:
  /// **'Kasratan'**
  String get harakaKasratan;

  /// No description provided for @harakaShadda.
  ///
  /// In en, this message translates to:
  /// **'Shadda'**
  String get harakaShadda;

  /// No description provided for @harakaSukun.
  ///
  /// In en, this message translates to:
  /// **'Sukun (jazm)'**
  String get harakaSukun;

  /// No description provided for @harakaAlef.
  ///
  /// In en, this message translates to:
  /// **'Superscript alef'**
  String get harakaAlef;

  /// No description provided for @harakaTatweel.
  ///
  /// In en, this message translates to:
  /// **'Tatweel'**
  String get harakaTatweel;

  /// No description provided for @pageColor.
  ///
  /// In en, this message translates to:
  /// **'Page color'**
  String get pageColor;

  /// No description provided for @themePaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get themePaper;

  /// No description provided for @themeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get themeSepia;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get themeDark;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Book text size'**
  String get fontSize;

  /// No description provided for @practiceMode.
  ///
  /// In en, this message translates to:
  /// **'Practice mode'**
  String get practiceMode;

  /// No description provided for @practiceModeHint.
  ///
  /// In en, this message translates to:
  /// **'Hide the book\'s printed meanings and translations and test yourself'**
  String get practiceModeHint;

  /// No description provided for @strictMatching.
  ///
  /// In en, this message translates to:
  /// **'Strict checking'**
  String get strictMatching;

  /// No description provided for @strictMatchingHint.
  ///
  /// In en, this message translates to:
  /// **'Harakat (zabar, zer, pesh) must also match when checking answers'**
  String get strictMatchingHint;

  /// No description provided for @allSettings.
  ///
  /// In en, this message translates to:
  /// **'All settings'**
  String get allSettings;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get sectionLanguage;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'Changes menus, buttons and labels only. The book\'s own text always stays in Urdu and Arabic.'**
  String get languageHint;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @sectionReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get sectionReading;

  /// No description provided for @sectionExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get sectionExercises;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get sectionData;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @answersSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No answers saved} =1{1 answer saved} other{{count} answers saved}}'**
  String answersSaved(int count);

  /// No description provided for @bookmarksSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No bookmarks} =1{1 bookmark} other{{count} bookmarks}}'**
  String bookmarksSaved(int count);

  /// No description provided for @aboutBook.
  ///
  /// In en, this message translates to:
  /// **'Muallim-ul-Quran, Volume 1 — an easy, complete system for understanding the Quran yourself.'**
  String get aboutBook;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @previewCaption.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewCaption;

  /// No description provided for @volumeN.
  ///
  /// In en, this message translates to:
  /// **'Volume {number}'**
  String volumeN(int number);

  /// No description provided for @unitsRange.
  ///
  /// In en, this message translates to:
  /// **'Units {range}'**
  String unitsRange(String range);

  /// No description provided for @modelPaper.
  ///
  /// In en, this message translates to:
  /// **'Model paper'**
  String get modelPaper;

  /// No description provided for @unitModelPaper.
  ///
  /// In en, this message translates to:
  /// **'Unit {unit} · Model paper'**
  String unitModelPaper(String unit);

  /// No description provided for @guidanceNotes.
  ///
  /// In en, this message translates to:
  /// **'Guidance notes'**
  String get guidanceNotes;

  /// No description provided for @sectionDataForVolume.
  ///
  /// In en, this message translates to:
  /// **'Your data · Volume {number}'**
  String sectionDataForVolume(int number);

  /// No description provided for @marksN.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mark} other{{count} marks}}'**
  String marksN(int count);

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgainToExit;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @searchSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested searches'**
  String get searchSuggested;

  /// No description provided for @searchPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Search the book'**
  String get searchPromptTitle;

  /// No description provided for @searchPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find Arabic vocabulary, Quranic verses, translation and topics'**
  String get searchPromptSubtitle;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try searching without diacritics or checking spelling'**
  String get searchNoResultsSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
