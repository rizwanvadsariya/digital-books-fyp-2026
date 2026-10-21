import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reader_settings.dart';

/// All on-device persistence, stored in shared_preferences.
///
/// Answers, reading progress and bookmarks belong to one volume and are
/// stored under that volume's [namespace] (see [forVolume]). Settings and the
/// selected volume are app-wide.
class LocalStore {
  LocalStore(this._prefs, {this.namespace = ''});

  final SharedPreferences _prefs;
  final String namespace;

  /// A store for one volume's data, sharing the same preferences.
  LocalStore forVolume(String namespace) => LocalStore(_prefs, namespace: namespace);

  String get _answersKey => '${namespace}answers.v1';
  String get _checksKey => '${namespace}checks.v1';
  String get _lastPageKey => '${namespace}progress.lastPage';
  String get _bookmarksKey => '${namespace}progress.bookmarks';
  static const _settingsKey = 'settings.v1';
  static const _volumeKey = 'library.volume';

  String? readSelectedVolume() => _prefs.getString(_volumeKey);

  Future<void> writeSelectedVolume(String id) => _prefs.setString(_volumeKey, id);

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

  Map<String, bool> readChecks() {
    final raw = _prefs.getString(_checksKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v == true));
    } catch (_) {
      return {};
    }
  }

  Future<void> writeChecks(Map<String, bool> checks) =>
      _prefs.setString(_checksKey, jsonEncode(checks));

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
