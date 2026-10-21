import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/script_text.dart';

class SearchPromptView extends StatelessWidget {
  const SearchPromptView({super.key, required this.onSelectSuggestion});

  final ValueChanged<String> onSelectSuggestion;

  static const _suggestions = [
    'الْحَمْدُ',
    'الْكِتَاب',
    'رَبّ',
    'مُسْلِم',
    'إِيمَان',
    'فِعْل',
    'ضَمِير',
    'جَنَّة',
  ];

  void _handleSuggestionTap(String word) {
    onSelectSuggestion(word);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    final l = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.boxTint,
                shape: BoxShape.circle,
              ),
              child: Icon(SolarIconsOutline.magnifier, size: 42, color: theme.accent),
            ),
            const SizedBox(height: 14),
            Text(
              l.searchPromptTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              l.searchPromptSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Text(
              l.searchSuggested,
              style: TextStyle(
                color: theme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final word in _suggestions)
                  ActionChip(
                    backgroundColor: theme.paper,
                    side: BorderSide(
                      color: theme.border.withValues(alpha: 0.3),
                    ),
                    label: ScriptText(
                      word,
                      size: 13,
                      forceScript: Script.arabic,
                    ),
                    onPressed: () => _handleSuggestionTap(word),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
