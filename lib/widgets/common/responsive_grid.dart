import 'package:flutter/material.dart';

/// Lays [children] out in rows of equal-width cells, using [columns] from the
/// book as an upper bound and dropping columns until each cell is at least
/// [minCellWidth] wide. Rows fill right-to-left under RTL directionality.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.columns,
    this.minCellWidth = 110,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final List<Widget> children;
  final int? columns;
  final double minCellWidth;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fit = ((width + spacing) / (minCellWidth + spacing)).floor().clamp(1, 12);
        final cols = (columns ?? fit).clamp(1, fit);
        final cellWidth = (width - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [for (final c in children) SizedBox(width: cellWidth, child: c)],
        );
      },
    );
  }
}
