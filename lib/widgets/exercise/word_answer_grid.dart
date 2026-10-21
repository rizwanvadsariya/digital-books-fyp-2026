import 'package:flutter/material.dart';

import '../../blocs/answers_cubit.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../../utils/exercise_grading.dart';
import '../common/responsive_grid.dart';
import '../common/script_text.dart';
import '../keyboard/keyboard_layouts.dart';
import 'answer_field.dart';

/// Words listed under a question/instruction ("give the meaning of ..."),
/// each with its own answer blank. When [answers] is given, each blank is
/// graded against it with the rule for [exerciseType].
class WordAnswerGrid extends StatelessWidget {
  const WordAnswerGrid({
    super.key,
    required this.words,
    required this.pdfPage,
    required this.blockIndex,
    this.answers,
    this.exerciseType,
  });

  final List<String> words;
  final int pdfPage;
  final int blockIndex;
  final List<String?>? answers;
  final int? exerciseType;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return ResponsiveGrid(
      minCellWidth: 140,
      children: [
        for (var i = 0; i < words.length; i++)
          Container(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            decoration: BoxDecoration(
              color: book.paperShade.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScriptText(words[i], size: 16, align: TextAlign.center, fallback: Script.arabic),
                _answerField(i),
              ],
            ),
          ),
      ],
    );
  }

  Widget _answerField(int i) {
    final key = i < (answers?.length ?? 0) ? answers![i] : null;
    return AnswerField(
      id: answerId(pdfPage, blockIndex, i),
      language: dominantScript(words[i], fallback: Script.arabic) == Script.arabic
          ? KeyboardLanguage.urdu
          : KeyboardLanguage.arabic,
      answerKey: key,
      customCheck: key == null ? null : (input) => gradeWordAnswer(exerciseType, input, key)!,
      allowSelfMark: exerciseType == 11,
    );
  }
}
