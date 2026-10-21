import 'package:flutter/material.dart';

import '../../data/search_index.dart';
import '../../l10n/l10n.dart';
import '../../models/book.dart';
import '../../theme/book_theme.dart';
import 'highlighted_text.dart';

class SearchHitTile extends StatelessWidget {
  const SearchHitTile({
    super.key,
    required this.hit,
    required this.page,
    required this.query,
    required this.onTap,
  });

  final SearchHit hit;
  final BookPage page;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    final l = context.l10n;
    final truncatedText = hit.text.characters.length > 160
        ? '${hit.text.characters.take(160)}…'
        : hit.text;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: HighlightedText(text: truncatedText, query: query),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          pageLocation(l, page),
          style: TextStyle(fontSize: 12, color: theme.muted),
        ),
      ),
      trailing: page.printedPage != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.paperShade.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.pageShort(page.printedPage!),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.muted,
                  fontFamily: arabicFont,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
