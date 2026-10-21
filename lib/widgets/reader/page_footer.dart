import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../theme/book_theme.dart';

class PageFooter extends StatelessWidget {
  const PageFooter({
    super.key,
    required this.page,
    required this.total,
  });

  final BookPage page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.border.withValues(alpha: 0.35)))),
      alignment: Alignment.center,
      child: Text(
        page.printedPage != null ? '— ${page.printedPage} —' : '— ${page.index + 1} / $total —',
        // Numbers read left-to-right even on an RTL page ("43 / 115").
        textDirection: TextDirection.ltr,
        style: TextStyle(color: theme.muted, fontSize: 12, fontFamily: arabicFont),
      ),
    );
  }
}
