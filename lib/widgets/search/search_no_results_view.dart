import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';

class SearchNoResultsView extends StatelessWidget {
  const SearchNoResultsView({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(SolarIconsOutline.minimalisticMagnifier, size: 48, color: theme.muted),
            const SizedBox(height: 14),
            Text(
              l.searchNoResultsTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              l.searchNoResultsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
