import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../data/exercise_lookup.dart';
import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/script_text.dart';

class AnswerRow extends StatelessWidget {
  const AnswerRow({
    super.key,
    required this.answer,
    required this.info,
    required this.strict,
  });

  final String answer;
  final ExerciseInfo info;
  final bool strict;

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    final key = info.answerKey;
    final correct = key == null ? null : answerMatches(answer, key, strict: strict);
    return ListTile(
      dense: true,
      title: ScriptText(info.prompt, size: 14, fallback: Script.arabic),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScriptText(answer, size: 13.5, color: theme.accent),
          if (correct == false)
            Text.rich(TextSpan(children: [
              TextSpan(text: context.l10n.correctAnswerLabel, style: TextStyle(fontSize: 12, color: theme.muted)),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: ScriptText(key!, size: 12, color: theme.correct),
              ),
            ])),
        ],
      ),
      trailing: switch (correct) {
        true => Icon(SolarIconsBold.checkCircle, color: theme.correct),
        false => Icon(SolarIconsBold.closeCircle, color: theme.incorrect),
        null => null,
      },
    );
  }
}
