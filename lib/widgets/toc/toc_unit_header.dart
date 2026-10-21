import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/book.dart';
import '../../theme/book_theme.dart';
import '../common/script_text.dart';

class TocUnitHeader extends StatelessWidget {
  const TocUnitHeader({super.key, required this.unit, required this.onTap});

  final UnitEntry unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 4),
      child: Material(
        color: book.red,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  context.l10n.unitN('${unit.unit}'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                if (unit.title != null)
                  Expanded(
                    child: ScriptText(
                      unit.title!,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 12),
                Text(
                  context.l10n.lessonsCount(unit.lessons.length),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
