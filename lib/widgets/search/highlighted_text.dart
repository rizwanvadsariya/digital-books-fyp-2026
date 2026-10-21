import 'package:flutter/material.dart';

import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/script_text.dart';

class HighlightedText extends StatelessWidget {
  const HighlightedText({super.key, required this.text, required this.query});

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final normQuery = normalizeForSearch(query);
    if (normQuery.isEmpty) {
      return ScriptText(text, size: 14);
    }

    final words = text.split(' ');
    final spans = <TextSpan>[];

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final normWord = normalizeForSearch(word);
      final isMatch = normWord.isNotEmpty && normWord.contains(normQuery);

      final style = book.forScript(
        dominantScript(word),
        size: 14,
        bold: isMatch,
        color: isMatch ? book.red : book.ink,
      );

      spans.add(
        TextSpan(
          text: i < words.length - 1 ? '$word ' : word,
          style: isMatch
              ? style.copyWith(
                  backgroundColor: book.red.withValues(alpha: 0.12),
                )
              : style,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
    );
  }
}
