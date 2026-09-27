import 'package:flutter/widgets.dart';

import '../models/book.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Whether the app interface (not the book) is currently in Urdu.
  bool get isUrduUi => Localizations.localeOf(this).languageCode == 'ur';
}

/// Localized label for where a page sits in the book, for interface text
/// (app bar, lists). The page's printed badge keeps [Book.locationLabel].
String pageLocation(AppLocalizations l, BookPage page) {
  if (page.isLessonPage) return l.unitLesson('${page.unit}', page.lessonLabel!);
  switch (page.pageKind) {
    case 'unit_cover':
      return page.unit != null ? l.unitN('${page.unit}') : l.unitGeneric;
    case 'pre_lesson':
      return l.unitIntro('${page.unit ?? ''}');
    case 'sample_exam':
      return l.sampleExam;
    case 'table_of_contents':
      return l.tableOfContents;
    case 'back_matter':
      return l.backMatter;
  }
  return l.introduction;
}
