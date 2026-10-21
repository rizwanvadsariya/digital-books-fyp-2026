import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/answers_cubit.dart';
import '../../blocs/settings_cubit.dart';
import '../../models/content_block.dart';
import '../../theme/book_theme.dart';
import '../common/responsive_grid.dart';
import 'singular_plural_card.dart';
import 'vocab_card.dart';

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
          VocabCard(
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
            SingularPluralCard(item: block.items[i], book: book)
          else
            VocabCard(
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
