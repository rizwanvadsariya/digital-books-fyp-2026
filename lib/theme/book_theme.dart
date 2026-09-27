import 'package:flutter/material.dart';

import '../models/reader_settings.dart';
import '../utils/arabic_text.dart';

const arabicFont = 'Amiri';
const urduFont = 'NotoNastaliqUrdu';

/// Colours and typography for rendering book pages. Installed as a
/// [ThemeExtension] so every block widget can read it with [BookTheme.of].
@immutable
class BookTheme extends ThemeExtension<BookTheme> {
  const BookTheme({
    required this.paper,
    required this.paperShade,
    required this.ink,
    required this.muted,
    required this.red,
    required this.border,
    required this.verseTint,
    required this.boxTint,
    required this.accent,
    required this.badgeBg,
    required this.badgeFg,
    required this.correct,
    required this.incorrect,
    required this.fieldLine,
    this.fontScale = 1.0,
  });

  factory BookTheme.forSettings(ReaderSettings s) {
    final base = switch (s.theme) {
      ReadingTheme.paper => paperTheme,
      ReadingTheme.sepia => sepiaTheme,
      ReadingTheme.dark => darkTheme,
    };
    return base.copyWith(fontScale: s.fontScale);
  }

  static const paperTheme = BookTheme(
    paper: Color(0xFFFBF6EA),
    paperShade: Color(0xFFEDE3CC),
    ink: Color(0xFF2B2118),
    muted: Color(0xFF7A6D5E),
    red: Color(0xFFC0392B),
    border: Color(0xFF8C6D46),
    verseTint: Color(0xFFF3EAD3),
    boxTint: Color(0xFFFFF4E0),
    accent: Color(0xFFD08A1E),
    badgeBg: Color(0xFF1F1A15),
    badgeFg: Color(0xFFFFFFFF),
    correct: Color(0xFF2E7D32),
    incorrect: Color(0xFFC62828),
    fieldLine: Color(0xFFAA9A80),
  );

  static const sepiaTheme = BookTheme(
    paper: Color(0xFFF1E3C6),
    paperShade: Color(0xFFDCC8A2),
    ink: Color(0xFF3B2A17),
    muted: Color(0xFF7D6446),
    red: Color(0xFFA93226),
    border: Color(0xFF7A5A33),
    verseTint: Color(0xFFE8D6B1),
    boxTint: Color(0xFFF6E6C4),
    accent: Color(0xFFB9731A),
    badgeBg: Color(0xFF2D2014),
    badgeFg: Color(0xFFF8EEDB),
    correct: Color(0xFF2E6B2F),
    incorrect: Color(0xFFB0281F),
    fieldLine: Color(0xFF9C8460),
  );

  static const darkTheme = BookTheme(
    paper: Color(0xFF1E1B17),
    paperShade: Color(0xFF12100D),
    ink: Color(0xFFE9E1D0),
    muted: Color(0xFFA3978A),
    red: Color(0xFFEF7A6A),
    border: Color(0xFFA88A60),
    verseTint: Color(0xFF2A251F),
    boxTint: Color(0xFF2E2619),
    accent: Color(0xFFE0A447),
    badgeBg: Color(0xFFE9E1D0),
    badgeFg: Color(0xFF1E1B17),
    correct: Color(0xFF81C784),
    incorrect: Color(0xFFEF8A80),
    fieldLine: Color(0xFF6E6254),
  );

  final Color paper;
  final Color paperShade;
  final Color ink;
  final Color muted;
  final Color red;
  final Color border;
  final Color verseTint;
  final Color boxTint;
  final Color accent;
  final Color badgeBg;
  final Color badgeFg;
  final Color correct;
  final Color incorrect;
  final Color fieldLine;
  final double fontScale;

  static BookTheme of(BuildContext context) =>
      Theme.of(context).extension<BookTheme>() ?? paperTheme;

  /// Quranic / vocalised Arabic. Amiri renders stacked harakat correctly.
  TextStyle arabic({
    double size = 22,
    bool bold = false,
    Color? color,
    double height = 1.9,
  }) => TextStyle(
    fontFamily: arabicFont,
    fontFamilyFallback: const [urduFont],
    fontSize: size * fontScale,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    color: color ?? ink,
    height: height,
  );

  /// Urdu prose in Nastaliq. The font is variable, so weight is set through
  /// the `wght` axis as well as [FontWeight].
  TextStyle urdu({
    double size = 15,
    bool bold = false,
    Color? color,
    double height = 2.15,
  }) => TextStyle(
    fontFamily: urduFont,
    fontFamilyFallback: const [arabicFont],
    fontSize: size * fontScale,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    fontVariations: [FontVariation('wght', bold ? 700 : 400)],
    color: color ?? ink,
    height: height,
  );

  /// Arabic runs are set larger than Urdu runs of the same "size" because
  /// Naskh reads smaller than Nastaliq at equal point size.
  TextStyle forScript(
    Script script, {
    double size = 15,
    bool bold = false,
    Color? color,
  }) => script == Script.arabic
      ? arabic(size: size * arabicScale, bold: bold, color: color)
      : urdu(size: size, bold: bold, color: color);

  static const arabicScale = 1.3;

  @override
  BookTheme copyWith({
    Color? paper,
    Color? paperShade,
    Color? ink,
    Color? muted,
    Color? red,
    Color? border,
    Color? verseTint,
    Color? boxTint,
    Color? accent,
    Color? badgeBg,
    Color? badgeFg,
    Color? correct,
    Color? incorrect,
    Color? fieldLine,
    double? fontScale,
  }) => BookTheme(
    paper: paper ?? this.paper,
    paperShade: paperShade ?? this.paperShade,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    red: red ?? this.red,
    border: border ?? this.border,
    verseTint: verseTint ?? this.verseTint,
    boxTint: boxTint ?? this.boxTint,
    accent: accent ?? this.accent,
    badgeBg: badgeBg ?? this.badgeBg,
    badgeFg: badgeFg ?? this.badgeFg,
    correct: correct ?? this.correct,
    incorrect: incorrect ?? this.incorrect,
    fieldLine: fieldLine ?? this.fieldLine,
    fontScale: fontScale ?? this.fontScale,
  );

  @override
  BookTheme lerp(BookTheme? other, double t) {
    if (other == null) return this;
    return BookTheme(
      paper: Color.lerp(paper, other.paper, t)!,
      paperShade: Color.lerp(paperShade, other.paperShade, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      red: Color.lerp(red, other.red, t)!,
      border: Color.lerp(border, other.border, t)!,
      verseTint: Color.lerp(verseTint, other.verseTint, t)!,
      boxTint: Color.lerp(boxTint, other.boxTint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      badgeBg: Color.lerp(badgeBg, other.badgeBg, t)!,
      badgeFg: Color.lerp(badgeFg, other.badgeFg, t)!,
      correct: Color.lerp(correct, other.correct, t)!,
      incorrect: Color.lerp(incorrect, other.incorrect, t)!,
      fieldLine: Color.lerp(fieldLine, other.fieldLine, t)!,
      fontScale: fontScale + (other.fontScale - fontScale) * t,
    );
  }
}

ThemeData buildAppTheme(ReaderSettings settings) {
  final book = BookTheme.forSettings(settings);
  final dark = settings.theme == ReadingTheme.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF8C3B2B),
    brightness: dark ? Brightness.dark : Brightness.light,
    surface: dark ? const Color(0xFF171512) : const Color(0xFFF7F1E3),
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [book],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
  );
}

/// Interface text in Urdu uses Nastaliq; English uses the platform font,
/// falling back to Nastaliq for any Urdu (e.g. lesson titles) inside it.
/// Book pages set their own fonts through [BookTheme] and are unaffected.
ThemeData withUiFont(ThemeData theme, {required bool urdu}) {
  TextTheme apply(TextTheme t) => urdu
      ? t.apply(fontFamily: urduFont, fontFamilyFallback: const [arabicFont])
      : t.apply(fontFamilyFallback: const [urduFont, arabicFont]);
  return theme.copyWith(
    textTheme: apply(theme.textTheme),
    primaryTextTheme: apply(theme.primaryTextTheme),
  );
}

/// Style for interface text shown on a book page (hints, labels), in the
/// interface font rather than the book's.
TextStyle uiTextStyle(BuildContext context, {double size = 12, Color? color}) {
  final base = Theme.of(context).textTheme.bodyMedium!;
  return TextStyle(
    fontFamily: base.fontFamily,
    fontFamilyFallback: base.fontFamilyFallback,
    fontSize: size * BookTheme.of(context).fontScale,
    color: color,
    height: base.fontFamily == urduFont ? 1.7 : 1.2,
  );
}
