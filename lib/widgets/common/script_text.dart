import 'package:flutter/material.dart';

import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';

/// Renders mixed Arabic/Urdu text, giving each run its proper font: Amiri for
/// vocalised Arabic, Noto Nastaliq for Urdu.
class ScriptText extends StatelessWidget {
  const ScriptText(
    this.text, {
    super.key,
    this.size = 15,
    this.bold = false,
    this.color,
    this.align = TextAlign.start,
    this.fallback = Script.urdu,
    this.forceScript,
  });

  final String text;

  /// Base (Urdu) size before the reader's font scale; Arabic runs are scaled
  /// by [BookTheme.arabicScale].
  final double size;
  final bool bold;
  final Color? color;
  final TextAlign align;

  /// Script assumed for runs with no distinguishing letters.
  final Script fallback;

  /// Skip detection and render everything in one script.
  final Script? forceScript;

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    if (forceScript == null && !_hasArabicScript(text)) {
      // e.g. an English interface label: use the platform font, not Nastaliq.
      return Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: size * theme.fontScale,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color ?? theme.ink,
          // Symbol-only cells (e.g. "←") need the bundled symbols font.
          fontFamilyFallback: const [urduFont, arabicFont, symbolsFont],
        ),
      );
    }
    if (forceScript != null) {
      return Text(
        text,
        textAlign: align,
        textDirection: TextDirection.rtl,
        style: theme.forScript(forceScript!, size: size, bold: bold, color: color),
      );
    }
    final runs = splitScriptRuns(text, fallback: fallback);
    if (runs.length == 1) {
      return Text(
        text,
        textAlign: align,
        textDirection: TextDirection.rtl,
        style: theme.forScript(runs.first.script, size: size, bold: bold, color: color),
      );
    }
    return Text.rich(
      TextSpan(
        style: theme.forScript(fallback, size: size, bold: bold, color: color),
        children: [
          for (final run in runs)
            TextSpan(
              text: run.text,
              style: theme.forScript(run.script, size: size, bold: bold, color: color),
            ),
        ],
      ),
      textAlign: align,
      textDirection: TextDirection.rtl,
    );
  }
}

bool _hasArabicScript(String text) => text.runes.any((r) => r >= 0x0600 && r <= 0x06FF || r >= 0x0750 && r <= 0x077F || r >= 0xFB50 && r <= 0xFEFF);
