import 'package:flutter/material.dart';

import '../../blocs/answers_cubit.dart';
import '../../l10n/l10n.dart';
import '../../models/content_block.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/script_text.dart';
import '../exercise/answer_field.dart';
import '../exercise/word_answer_grid.dart';
import '../keyboard/keyboard_layouts.dart';

/// A numbered exercise. Depending on its shape the learner:
/// - writes the meaning of each listed word (`items`),
/// - writes out the part of each verse the question asks them to identify
///   (`verses`), or
/// - writes a single free answer.
class QuestionBlockView extends StatelessWidget {
  const QuestionBlockView({super.key, required this.block, required this.pdfPage, required this.blockIndex});

  final QuestionBlock block;
  final int pdfPage;
  final int blockIndex;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: book.border.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (block.number != null)
                Container(
                  margin: const EdgeInsetsDirectional.only(end: 8, top: 6),
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: book.red, shape: BoxShape.circle),
                  child: Text(
                    '${block.number}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              Expanded(child: ScriptText(block.text, size: 15, bold: true)),
              if (block.marks != null)
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 8, top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: book.red),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.marksN(block.marks!),
                    style: uiTextStyle(context, size: 11, color: book.red),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (block.items.isNotEmpty)
            WordAnswerGrid(words: block.items, pdfPage: pdfPage, blockIndex: blockIndex)
          else if (block.verses.isNotEmpty)
            for (var i = 0; i < block.verses.length; i++)
              _VerseExercise(
                index: i,
                verse: block.verses[i],
                id: answerId(pdfPage, blockIndex, i),
              )
          else
            AnswerField(id: answerId(pdfPage, blockIndex, 0)),
        ],
      ),
    );
  }
}

class _VerseExercise extends StatelessWidget {
  const _VerseExercise({required this.index, required this.verse, required this.id});

  final int index;
  final String verse;
  final String id;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
      decoration: BoxDecoration(
        color: book.verseTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6, top: 10),
                child: Text('${index + 1}.', style: TextStyle(color: book.muted, fontSize: 12)),
              ),
              Expanded(child: ScriptText(verse, size: 16, forceScript: Script.arabic)),
            ],
          ),
          AnswerField(id: id, language: KeyboardLanguage.arabic, hint: context.l10n.hintIdentifyPart),
        ],
      ),
    );
  }
}
