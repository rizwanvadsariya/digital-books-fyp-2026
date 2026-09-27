import 'package:flutter/widgets.dart';

import '../models/book.dart';

/// Lets widgets inside a page (e.g. the printed table of contents) jump the
/// reader to another page.
class ReaderNavigation extends InheritedWidget {
  const ReaderNavigation({super.key, required this.book, required this.goToIndex, required super.child});

  final Book book;
  final void Function(int pageIndex) goToIndex;

  static ReaderNavigation? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ReaderNavigation>();

  @override
  bool updateShouldNotify(ReaderNavigation old) => old.book != book || old.goToIndex != goToIndex;
}
