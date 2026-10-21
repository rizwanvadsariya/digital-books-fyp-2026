import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../blocs/answers_cubit.dart';
import '../../blocs/settings_cubit.dart';
import '../../l10n/l10n.dart';
import '../../models/content_block.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/responsive_grid.dart';
import '../common/script_text.dart';
import '../exercise/answer_field.dart';
import 'styled_frame.dart';

/// A Quranic verse on a tinted card, with a placeholder recitation button.
class QuranVerseBlockView extends StatelessWidget {
  const QuranVerseBlockView({super.key, required this.block});

  final QuranVerseBlock block;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return StyledFrame(
      style: block.style,
      child: AccentCard(
        accent: book.accent,
        background: book.verseTint,
        padding: const EdgeInsets.fromLTRB(12, 6, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final verse in block.allVerses)
                    ScriptText(verse, size: 18, align: TextAlign.center, forceScript: Script.arabic),
                  if (block.note != null)
                    ScriptText(block.note!, size: 12.5, color: book.muted, align: TextAlign.center),
                ],
              ),
            ),
            RecitationButton(verse: block.allVerses.join('\n')),
          ],
        ),
      ),
    );
  }
}

/// Verses with a translation line under each. A `null` translation is a
/// blank for the learner; printed ones become self-check blanks in practice
/// mode.
class VerseTranslateBlockView extends StatelessWidget {
  const VerseTranslateBlockView({super.key, required this.block, required this.pdfPage, required this.blockIndex});

  final VerseTranslateBlock block;
  final int pdfPage;
  final int blockIndex;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final practice = context.select<SettingsCubit, bool>((c) => c.state.practiceMode);
    return ResponsiveGrid(
      columns: block.columns,
      minCellWidth: 250,
      spacing: 10,
      children: [
        for (var i = 0; i < block.items.length; i++)
          Container(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
            decoration: BoxDecoration(
              color: book.verseTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScriptText(block.items[i].verse, size: 16, align: TextAlign.center, forceScript: Script.arabic),
                if (block.items[i].translation != null && !practice)
                  ScriptText(
                    block.items[i].translation!,
                    size: 13.5,
                    color: book.muted,
                    align: TextAlign.center,
                    forceScript: Script.urdu,
                  )
                else
                  AnswerField(
                    id: answerId(pdfPage, blockIndex, i),
                    answerKey: block.items[i].translation,
                    hint: context.l10n.hintTranslation,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Placeholder for future per-verse audio.
class RecitationButton extends StatelessWidget {
  const RecitationButton({super.key, required this.verse});

  final String verse;

  void _handleRecitation(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(context.l10n.recitationComingSoon),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return IconButton(
      tooltip: context.l10n.listenRecitation,
      visualDensity: VisualDensity.compact,
      icon: Icon(SolarIconsOutline.playCircle, color: book.accent),
      onPressed: () => _handleRecitation(context),
    );
  }
}
