import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../theme/book_theme.dart';
import '../common/script_text.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.label,
    required this.bookmarked,
  });

  final String label;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    return SizedBox(
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: theme.badgeBg, borderRadius: BorderRadius.circular(30)),
            child: ScriptText(label, size: 12, bold: true, color: theme.badgeFg),
          ),
          if (bookmarked)
            PositionedDirectional(
              top: 0,
              start: 26,
              child: Icon(SolarIconsBold.bookmark, color: theme.red, size: 30),
            ),
        ],
      ),
    );
  }
}
