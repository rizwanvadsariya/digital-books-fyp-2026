import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../l10n/l10n.dart';
import '../../models/content_block.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/script_text.dart';

class SingularPluralCard extends StatelessWidget {
  const SingularPluralCard({
    super.key,
    required this.item,
    required this.book,
  });

  final VocabPairItem item;
  final BookTheme book;

  Widget _buildSide(BuildContext context, String? word, String? meaning, String label) => Expanded(
    child: Column(
      children: [
        Text(label, style: uiTextStyle(context, size: 10, color: book.muted)),
        ScriptText(
          word ?? '—',
          size: 15,
          align: TextAlign.center,
          forceScript: Script.arabic,
        ),
        if (meaning != null)
          ScriptText(
            meaning,
            size: 11.5,
            color: book.muted,
            align: TextAlign.center,
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: book.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: book.border.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSide(context, item.singular, item.singularMeaning, context.l10n.singular),
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Icon(SolarIconsOutline.arrowLeft, size: 16, color: book.red),
              ),
              _buildSide(context, item.plural, item.pluralMeaning, context.l10n.plural),
            ],
          ),
          if (item.note != null)
            ScriptText(
              item.note!,
              size: 11.5,
              color: book.muted,
              align: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
