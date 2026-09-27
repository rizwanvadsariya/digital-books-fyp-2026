import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muallim_ul_quran/theme/book_theme.dart';
import 'package:muallim_ul_quran/widgets/common/script_text.dart';

import '../helpers.dart';

/// The book fonts lack ← / ↔ (used 268 times across both volumes); every
/// text path must fall back to the bundled symbols font.
void main() {
  for (final text in ['←', 'بَيْتُهَا ← اسکا گھر', 'قَوْلٌ ↔ قَوْلًا']) {
    testWidgets('"$text" can fall back to the symbols font', (tester) async {
      await tester.pumpWidget(harness(ScriptText(text), store: await freshStore()));
      final rich = tester.widget<RichText>(find.byType(RichText).first);
      // Style of every span that holds text, inheriting from its parent.
      final styles = <TextStyle>[];
      void walk(InlineSpan span, TextStyle? inherited) {
        final style = inherited?.merge(span.style) ?? span.style;
        if (span is TextSpan) {
          if ((span.text ?? '').isNotEmpty && style != null) styles.add(style);
          for (final child in span.children ?? const <InlineSpan>[]) {
            walk(child, style);
          }
        }
      }

      walk(rich.text, null);
      expect(styles, isNotEmpty);
      expect(styles.every((s) => s.fontFamilyFallback?.contains(symbolsFont) ?? false), isTrue);
    });
  }
}
