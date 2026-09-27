import 'package:flutter/material.dart';

import '../../models/content_block.dart';
import '../../theme/book_theme.dart';
import '../common/script_text.dart';
import 'question_block.dart';
import 'table_block.dart';
import 'text_blocks.dart';
import 'verse_blocks.dart';
import 'vocab_blocks.dart';

/// Maps a [ContentBlock] to its widget.
class BlockRenderer extends StatelessWidget {
  const BlockRenderer({super.key, required this.block, required this.pdfPage, required this.blockIndex});

  final ContentBlock block;
  final int pdfPage;

  /// Position of the block in its page's `blocks` array (part of answer IDs).
  final int blockIndex;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      final TextBlock b => switch (b.type) {
          'lesson_marker' || 'unit_marker' => MarkerBlockView(block: b),
          'book_title' ||
          'title' ||
          'unit_title' ||
          'section_heading' ||
          'heading' ||
          'subheading' ||
          'section_marker' =>
            HeadingBlockView(block: b),
          'note' || 'note_box' || 'highlight' || 'unit_summary_box' || 'instruction' =>
            NoteBlockView(block: b, pdfPage: pdfPage, blockIndex: blockIndex),
          _ => ProseBlockView(block: b),
        },
      final VocabListBlock b => VocabListBlockView(block: b, pdfPage: pdfPage, blockIndex: blockIndex),
      final VocabPairListBlock b => VocabPairListBlockView(block: b, pdfPage: pdfPage, blockIndex: blockIndex),
      final TableBlock b => TableBlockView(block: b, pdfPage: pdfPage, blockIndex: blockIndex),
      final QuestionBlock b => QuestionBlockView(block: b, pdfPage: pdfPage, blockIndex: blockIndex),
      final QuranVerseBlock b => QuranVerseBlockView(block: b),
      final VerseTranslateBlock b => VerseTranslateBlockView(block: b, pdfPage: pdfPage, blockIndex: blockIndex),
      final BulletListBlock b => BulletListBlockView(block: b),
      final UnknownBlock b => UnknownBlockView(block: b),
    };
  }
}

class BulletListBlockView extends StatelessWidget {
  const BulletListBlockView({super.key, required this.block});

  final BulletListBlock block;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in block.items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8, top: 12),
                child: Container(width: 7, height: 7, decoration: BoxDecoration(color: book.red, shape: BoxShape.circle)),
              ),
              Expanded(child: ScriptText(item, size: 14.5, align: TextAlign.justify)),
            ],
          ),
      ],
    );
  }
}

/// Generic fallback so content types added to the JSON later still show up.
class UnknownBlockView extends StatelessWidget {
  const UnknownBlockView({super.key, required this.block});

  final UnknownBlock block;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final texts = block.texts;
    if (texts.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: book.muted.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final t in texts) ScriptText(t, size: 14)],
      ),
    );
  }
}
