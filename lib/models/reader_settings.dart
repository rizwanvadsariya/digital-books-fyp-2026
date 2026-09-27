import 'package:equatable/equatable.dart';

enum ReadingTheme { paper, sepia, dark }

/// Language of the app's own interface (menus, buttons, labels). The book's
/// text is never translated.
enum AppLanguage {
  system(null),
  urdu('ur'),
  english('en');

  const AppLanguage(this.code);

  /// Locale code, or `null` to follow the device.
  final String? code;
}

class ReaderSettings extends Equatable {
  const ReaderSettings({
    this.theme = ReadingTheme.paper,
    this.fontScale = 1.0,
    this.strictMatching = false,
    this.practiceMode = false,
    this.language = AppLanguage.system,
  });

  factory ReaderSettings.fromJson(Map<String, dynamic> json) => ReaderSettings(
        theme: ReadingTheme.values.firstWhere(
          (t) => t.name == json['theme'],
          orElse: () => ReadingTheme.paper,
        ),
        fontScale: ((json['fontScale'] as num?)?.toDouble() ?? 1.0).clamp(minFontScale, maxFontScale),
        strictMatching: json['strictMatching'] == true,
        practiceMode: json['practiceMode'] == true,
        language: AppLanguage.values.firstWhere(
          (l) => l.name == json['language'],
          orElse: () => AppLanguage.system,
        ),
      );

  static const minFontScale = 0.8;
  static const maxFontScale = 1.6;

  final ReadingTheme theme;
  final double fontScale;

  /// Require exact harakat when checking answers.
  final bool strictMatching;

  /// Hide meanings/translations printed in the book and turn them into
  /// self-check exercises.
  final bool practiceMode;

  final AppLanguage language;

  ReaderSettings copyWith({
    ReadingTheme? theme,
    double? fontScale,
    bool? strictMatching,
    bool? practiceMode,
    AppLanguage? language,
  }) =>
      ReaderSettings(
        theme: theme ?? this.theme,
        fontScale: fontScale ?? this.fontScale,
        strictMatching: strictMatching ?? this.strictMatching,
        practiceMode: practiceMode ?? this.practiceMode,
        language: language ?? this.language,
      );

  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'fontScale': fontScale,
        'strictMatching': strictMatching,
        'practiceMode': practiceMode,
        'language': language.name,
      };

  @override
  List<Object?> get props => [theme, fontScale, strictMatching, practiceMode, language];
}
