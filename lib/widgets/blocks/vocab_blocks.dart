import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/answers_cubit.dart';
import '../../blocs/settings_cubit.dart';
import '../../l10n/l10n.dart';
import '../../models/content_block.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/responsive_grid.dart';
import '../common/script_text.dart';
import '../exercise/answer_field.dart';

/// Grid of Arabic words with their Urdu meaning. Words without a printed
/// meaning get an answer blank; in practice mode printed meanings are hidden
/// and become self-check blanks too.
class VocabListBlockView extends StatelessWidget {
  const VocabListBlockView({
    super.key,
    required this.block,
    required this.pdfPage,
    required this.blockIndex,
  });

  final VocabListBlock block;
  final int pdfPage;
  final int blockIndex;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final practice = context.select<SettingsCubit, bool>(
      (c) => c.state.practiceMode,
    );
    return ResponsiveGrid(
      columns: block.columns,
      minCellWidth: 104,
      children: [
        for (var i = 0; i < block.items.length; i++)
          _VocabCard(
            arabic: block.items[i].arabic,
            arabicColor: block.items[i].isRedMarker ? book.red : null,
            meaning: block.items[i].meaning,
            extra: block.items[i].note2,
            id: answerId(pdfPage, blockIndex, i),
            practice: practice,
          ),
      ],
    );
  }
}

/// Singular/plural pairs, or Arabic phrases with their meaning.
class VocabPairListBlockView extends StatelessWidget {
  const VocabPairListBlockView({
    super.key,
    required this.block,
    required this.pdfPage,
    required this.blockIndex,
  });

  final VocabPairListBlock block;
  final int pdfPage;
  final int blockIndex;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final practice = context.select<SettingsCubit, bool>(
      (c) => c.state.practiceMode,
    );
    return ResponsiveGrid(
      columns: block.columns,
      minCellWidth: 130,
      children: [
        for (var i = 0; i < block.items.length; i++)
          if (block.items[i].isSingularPlural)
            _SingularPluralCard(item: block.items[i], book: book)
          else
            _VocabCard(
              arabic: block.items[i].pair ?? '',
              meaning: block.items[i].note,
              id: answerId(pdfPage, blockIndex, i),
              practice: practice,
              // Volumes 2–3 pairs can carry an inline Urdu gloss
              // ("یَعْبُدُ : وہ عبادت کرتا ہے"); give each part its font.
              mixedScript: true,
            ),
      ],
    );
  }
}

class _VocabCard extends StatelessWidget {
  const _VocabCard({
    required this.arabic,
    required this.meaning,
    required this.id,
    required this.practice,
    this.arabicColor,
    this.extra,
    this.mixedScript = false,
  });

  final String arabic;

  /// Detect Arabic/Urdu runs instead of forcing the Arabic font.
  final bool mixedScript;
  final String? meaning;
  final String? extra;
  final String id;
  final bool practice;
  final Color? arabicColor;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final showMeaning = meaning != null && !practice;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
      decoration: BoxDecoration(
        color: book.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: book.border.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ScriptText(
            arabic,
            size: 16,
            align: TextAlign.center,
            color: arabicColor,
            forceScript: mixedScript ? null : Script.arabic,
            fallback: Script.arabic,
          ),
          if (showMeaning)
            ScriptText(
              meaning!,
              size: 12.5,
              align: TextAlign.center,
              color: book.muted,
              forceScript: Script.urdu,
            )
          else
            AnswerField(
              id: id,
              answerKey: meaning,
              hint: context.l10n.hintMeaning,
            ),
          if (extra != null)
            ScriptText(
              extra!,
              size: 11.5,
              align: TextAlign.center,
              color: book.muted,
            ),
        ],
      ),
    );
  }
}

class _SingularPluralCard extends StatelessWidget {
  const _SingularPluralCard({required this.item, required this.book});

  final VocabPairItem item;
  final BookTheme book;

  @override
  Widget build(BuildContext context) {
    Widget side(String? word, String? meaning, String label) => Expanded(
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
              side(item.singular, item.singularMeaning, context.l10n.singular),
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Icon(Icons.arrow_forward, size: 16, color: book.red),
              ),
              side(item.plural, item.pluralMeaning, context.l10n.plural),
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
