import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/answers_cubit.dart';
import '../../blocs/settings_cubit.dart';
import '../../models/content_block.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/script_text.dart';
import '../exercise/answer_field.dart';
import '../keyboard/keyboard_layouts.dart';
import '../reader_navigation.dart';

/// Bordered table built from the block's column keys and rows. Empty cells
/// are blanks to fill in; in practice mode, "meaning" (مطلب) cells become
/// self-check blanks. A table with a `صفحہ` column (the printed contents)
/// jumps to that page when a row is tapped.
class TableBlockView extends StatelessWidget {
  const TableBlockView({super.key, required this.block, required this.pdfPage, required this.blockIndex});

  final TableBlock block;
  final int pdfPage;
  final int blockIndex;

  static const _pageColumn = 'صفحہ';

  void _handleJump(ReaderNavigation nav, String? printed) {
    if (printed == null) return;
    final index = nav.book.indexForPrintedPage(printed);
    if (index != null) nav.goToIndex(index);
  }

  Widget _buildCell(
    BuildContext context, {
    required int row,
    required int col,
    required BookTheme book,
    required bool practice,
    required String? pageKey,
    required Map<int, TableColumnWidth> columnWidths,
  }) {
    final key = block.keys[col];
    final value = block.rows[row][key];
    final header = block.headers[col];
    final isMeaning = header.startsWith('مطلب') || header.contains('کا مطلب');
    final id = answerId(pdfPage, blockIndex, '$row-$col');
    if (value == null) {
      // The printed contents table has empty cells that aren't exercises,
      // and neither are gaps in a row-label column (sized to its content,
      // which a text field can't report).
      if (pageKey != null || columnWidths[col] is IntrinsicColumnWidth) {
        return const SizedBox.shrink();
      }
      return AnswerField(id: id, language: isMeaning ? KeyboardLanguage.urdu : KeyboardLanguage.arabic);
    }
    if (practice && isMeaning) return AnswerField(id: id, answerKey: value);
    final firstCol = col == 0 && (header == 'مثال' || header.isEmpty || !block.showHeader);
    return ScriptText(
      value,
      size: firstCol ? 12.5 : 14,
      bold: firstCol,
      color: firstCol ? book.red : null,
      align: TextAlign.center,
    );
  }

  Widget _maybeTappable({required Widget child, VoidCallback? onTap}) =>
      onTap == null ? child : InkWell(onTap: onTap, child: child);

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final practice = context.select<SettingsCubit, bool>((c) => c.state.practiceMode);
    final nav = ReaderNavigation.maybeOf(context);
    // Found by header so list-row tables (Volume 3's contents) work too.
    final pageKey = block.keyForHeader(_pageColumn);

    final columnWidths = <int, TableColumnWidth>{
      for (var c = 0; c < block.keys.length; c++)
        c: switch (block.headers[c]) {
          'مثال' || 'سبق' || 'صفحہ' || '' || 'label' => const IntrinsicColumnWidth(),
          _ => const FlexColumnWidth(),
        },
    };
    if (!block.showHeader) columnWidths[0] = const IntrinsicColumnWidth();

    final table = Table(
      border: TableBorder.all(color: book.border.withValues(alpha: 0.6), width: 0.9, borderRadius: BorderRadius.circular(6)),
      columnWidths: columnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        if (block.showHeader)
          TableRow(
            decoration: BoxDecoration(color: book.red.withValues(alpha: 0.12)),
            children: [
              for (final h in block.headers)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: ScriptText(h, size: 12.5, bold: true, color: book.red, align: TextAlign.center, fallback: Script.urdu),
                ),
            ],
          ),
        for (var r = 0; r < block.rows.length; r++)
          TableRow(
            decoration: BoxDecoration(color: r.isOdd ? book.paperShade.withValues(alpha: 0.25) : null),
            children: [
              for (var c = 0; c < block.keys.length; c++)
                _maybeTappable(
                  onTap: pageKey != null && nav != null ? () => _handleJump(nav, block.rows[r][pageKey]) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: _buildCell(
                      context,
                      row: r,
                      col: c,
                      book: book,
                      practice: practice,
                      pageKey: pageKey,
                      columnWidths: columnWidths,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (block.caption != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ScriptText(block.caption!, size: 13, bold: true, align: TextAlign.center, color: book.muted),
          ),
        table,
      ],
    );
  }
}
