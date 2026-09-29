import 'package:flutter/material.dart';

import '../../models/block_style.dart';
import '../../models/content_block.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/script_text.dart';
import '../exercise/word_answer_grid.dart';
import 'styled_frame.dart';

Color _textColor(BookTheme book, TextBlock b, {Color? fallback}) {
  if (b.style.blackBadge) return book.badgeFg;
  if (b.style.circleBadge) return Colors.white;
  if (b.style.red || b.highlight && b.style.raw == null) return book.red;
  return fallback ?? book.ink;
}

/// book_title, title, unit_title, section_heading, heading, subheading,
/// section_marker.
class HeadingBlockView extends StatelessWidget {
  const HeadingBlockView({super.key, required this.block});

  final TextBlock block;

  static const _sizes = {
    'book_title': 30.0,
    'title': 24.0,
    'unit_title': 26.0,
    'section_heading': 20.0,
    'heading': 20.0,
    'subheading': 17.0,
    'section_marker': 17.0,
  };

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final b = block;
    var size = _sizes[b.type] ?? 18;
    if (b.style.large) size *= 1.12;
    final centered = b.style.centered || b.type != 'subheading';
    final text = b.number != null ? '${b.number}. ${b.text}' : b.text;
    if (b.style.circleBadge && text.trim().length > 3) {
      final numMatch = RegExp(r'^(\d+|[\u0660-\u0669]+)')
          .firstMatch(text.trim());
      if (numMatch != null) {
        final numberStr = numMatch.group(1)!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: book.red,
                  boxShadow: [
                    BoxShadow(
                      color: book.red.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: ScriptText(
                    numberStr,
                    size: 18,
                    bold: true,
                    color: Colors.white,
                    align: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ScriptText(
                text,
                size: size,
                bold: true,
                color: book.red,
                align: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    return StyledFrame(
      style: b.style,
      child: ScriptText(
        text,
        size: size,
        bold: true,
        color: _textColor(
          book,
          b,
          fallback: b.type == 'subheading' ? book.red : null,
        ),
        align: centered ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}

/// lesson_marker / unit_marker: the badge naming the unit or lesson.
class MarkerBlockView extends StatelessWidget {
  const MarkerBlockView({super.key, required this.block});

  final TextBlock block;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final style = block.style.raw == null
        ? BlockStylePresets.blackBadge
        : block.style;
    return StyledFrame(
      style: style,
      child: ScriptText(
        block.text,
        size: block.type == 'unit_marker' ? 18 : 14,
        bold: true,
        color: style.blackBadge
            ? book.badgeFg
            : (style.red ? book.red : book.ink),
        align: TextAlign.center,
      ),
    );
  }
}

/// paragraph, translation_line, list_item, tagline, signature_block,
/// copyright_notice.
class ProseBlockView extends StatelessWidget {
  const ProseBlockView({super.key, required this.block});

  final TextBlock block;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final b = block;
    switch (b.type) {
      case 'tagline':
        return ScriptText(
          b.text,
          size: 14,
          color: book.muted,
          align: TextAlign.center,
        );
      case 'translation_line':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ScriptText('— ${b.text}', size: 14, color: book.muted),
        );
      case 'list_item':
        return _Bulleted(
          marker: b.number != null ? '${b.number}.' : null,
          child: ScriptText(b.text, size: 15, align: TextAlign.justify),
        );
      case 'signature_block':
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ScriptText(b.text, size: 15, bold: true),
              if (b.date != null)
                ScriptText(b.date!, size: 13, color: book.muted),
            ],
          ),
        );
      case 'copyright_notice':
        return StyledFrame(
          style: b.style,
          child: ScriptText(
            b.text,
            size: 12,
            color: book.muted,
            align: TextAlign.center,
          ),
        );
    }
    return StyledFrame(
      style: b.style,
      child: ScriptText(
        b.text,
        size: 15,
        bold: b.style.bold,
        color: b.style.red ? book.red : null,
        align: b.style.centered ? TextAlign.center : TextAlign.justify,
      ),
    );
  }
}

/// note, note_box, highlight, unit_summary_box, instruction.
class NoteBlockView extends StatelessWidget {
  const NoteBlockView({
    super.key,
    required this.block,
    required this.pdfPage,
    required this.blockIndex,
  });

  final TextBlock block;
  final int pdfPage;
  final int blockIndex;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final b = block;
    switch (b.type) {
      case 'note':
        final text = ScriptText(
          b.text,
          size: 14.5,
          bold: b.style.bold,
          color: b.style.red ? book.red : null,
          align: TextAlign.justify,
        );
        return b.bullet
            ? _Bulleted(marker: '•', child: text)
            : StyledFrame(style: b.style, child: text);

      case 'note_box':
        return AccentCard(
          accent: b.style.red ? book.red : book.accent,
          background: book.boxTint,
          outline: book.accent.withValues(alpha: 0.4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8, top: 8),
                child: Icon(
                  b.style.exclamation
                      ? Icons.error_outline
                      : Icons.lightbulb_outline,
                  size: 20,
                  color: b.style.red ? book.red : book.accent,
                ),
              ),
              Expanded(
                child: ScriptText(
                  b.text,
                  size: 14,
                  bold: b.style.bold,
                  color: b.style.red ? book.red : null,
                  align: TextAlign.justify,
                ),
              ),
            ],
          ),
        );

      case 'highlight':
        return _LabelledBox(
          label: b.label,
          color: b.style.red || b.style.raw == null ? book.red : book.border,
          child: ScriptText(
            b.text,
            size: 15,
            bold: dominantScript(b.text) == Script.urdu,
            color: dominantScript(b.text) == Script.urdu ? book.red : null,
            align: TextAlign.center,
          ),
        );

      case 'unit_summary_box':
        return _LabelledBox(
          label: b.label,
          color: book.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (b.text.isNotEmpty)
                ScriptText(b.text, size: 14.5, align: TextAlign.justify),
              for (final item in b.items)
                _Bulleted(
                  marker: null,
                  child: ScriptText(item, size: 14.5, align: TextAlign.justify),
                ),
            ],
          ),
        );

      case 'instruction':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StyledFrame(
              style: b.style,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6, top: 9),
                    child: Icon(Icons.edit_note, size: 20, color: book.red),
                  ),
                  Expanded(
                    child: ScriptText(
                      b.text,
                      size: 15,
                      bold: true,
                      color: b.style.red || b.highlight ? book.red : null,
                    ),
                  ),
                ],
              ),
            ),
            if (b.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              WordAnswerGrid(
                words: b.items,
                pdfPage: pdfPage,
                blockIndex: blockIndex,
              ),
            ],
          ],
        );
    }
    return ScriptText(b.text);
  }
}

class _Bulleted extends StatelessWidget {
  const _Bulleted({required this.marker, required this.child});

  /// Text marker (e.g. "3." or "•"); `null` draws a red diamond. The diamond
  /// is painted rather than typed because the book fonts lack a ◆ glyph.
  final String? marker;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: marker != null
                ? Text(
                    marker!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: book.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Center(
                      child: Transform.rotate(
                        angle: 0.785398,
                        child: Container(width: 7, height: 7, color: book.red),
                      ),
                    ),
                  ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _LabelledBox extends StatelessWidget {
  const _LabelledBox({
    required this.label,
    required this.color,
    required this.child,
  });

  final String? label;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: book.boxTint,
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(8),
                    bottomEnd: Radius.circular(10),
                  ),
                ),
                child: ScriptText(
                  label!,
                  size: 13,
                  bold: true,
                  color: Colors.white,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: child,
          ),
        ],
      ),
    );
  }
}
