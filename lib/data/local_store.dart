import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reader_settings.dart';

/// All on-device persistence: answers, reading progress, bookmarks and
/// reader settings, stored in shared_preferences.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const _answersKey = 'answers.v1';
  static const _lastPageKey = 'progress.lastPage';
  static const _bookmarksKey = 'progress.bookmarks';
  static const _settingsKey = 'settings.v1';

  Map<String, String> readAnswers() {
    final raw = _prefs.getString(_answersKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> writeAnswers(Map<String, String> answers) =>
      _prefs.setString(_answersKey, jsonEncode(answers));

  int? readLastPage() => _prefs.getInt(_lastPageKey);

  Future<void> writeLastPage(int index) => _prefs.setInt(_lastPageKey, index);

  Set<int> readBookmarks() =>
      (_prefs.getStringList(_bookmarksKey) ?? const [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();

  Future<void> writeBookmarks(Set<int> pages) =>
      _prefs.setStringList(_bookmarksKey, [for (final p in pages) '$p']);

  ReaderSettings readSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return const ReaderSettings();
    try {
      return ReaderSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const ReaderSettings();
    }
  }

  Future<void> writeSettings(ReaderSettings s) =>
      _prefs.setString(_settingsKey, jsonEncode(s.toJson()));
}
