import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../common/responsive_grid.dart';
import '../common/script_text.dart';

/// Exercise type 14 (explanation): the item plus a reveal for the book's
/// model answer. Ungraded — shown as reference only.
class ReferenceAnswerGrid extends StatefulWidget {
  const ReferenceAnswerGrid({super.key, required this.items, required this.answers});

  final List<String> items;
  final List<String?>? answers;

  @override
  State<ReferenceAnswerGrid> createState() => _ReferenceAnswerGridState();
}

class _ReferenceAnswerGridState extends State<ReferenceAnswerGrid> {
  final _revealed = <int>{};

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final l = context.l10n;
    return ResponsiveGrid(
      minCellWidth: 220,
      children: [
        for (var i = 0; i < widget.items.length; i++)
          Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            decoration: BoxDecoration(
              color: book.paperShade.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScriptText(widget.items[i], size: 15, align: TextAlign.center, fallback: Script.arabic),
                if (i < (widget.answers?.length ?? 0) && widget.answers![i] != null)
                  _revealed.contains(i)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: ScriptText(widget.answers![i]!, size: 13, color: book.muted, fallback: Script.urdu),
                        )
                      : Center(
                          child: TextButton.icon(
                            onPressed: () => setState(() => _revealed.add(i)),
                            icon: const Icon(Icons.lightbulb_outline, size: 16),
                            label: Text(l.showModelAnswer, style: TextStyle(fontSize: 12, color: book.accent)),
                          ),
                        ),
              ],
            ),
          ),
      ],
    );
  }
}
