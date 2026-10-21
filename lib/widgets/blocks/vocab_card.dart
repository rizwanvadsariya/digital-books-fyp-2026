import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/script_text.dart';
import '../exercise/answer_field.dart';

class VocabCard extends StatelessWidget {
  const VocabCard({
    super.key,
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
