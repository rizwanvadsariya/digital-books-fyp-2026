import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/script_text.dart';
import '../exercise/answer_field.dart';
import '../keyboard/keyboard_layouts.dart';

class VerseExercise extends StatelessWidget {
  const VerseExercise({
    super.key,
    required this.index,
    required this.verse,
    required this.id,
  });

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
