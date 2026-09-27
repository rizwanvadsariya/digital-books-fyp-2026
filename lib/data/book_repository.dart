import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/book.dart';

class BookRepository {
  BookRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/data/muallim_ul_quran_vol1_full.json';

  final AssetBundle _bundle;
  Book? _cache;

  /// Loads and parses the book once; later calls return the cached instance.
  Future<Book> load() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString(assetPath, cache: false);
    final json = await compute(_decode, raw);
    return _cache = Book.fromJson(json);
  }
}

Map<String, dynamic> _decode(String raw) => jsonDecode(raw) as Map<String, dynamic>;
