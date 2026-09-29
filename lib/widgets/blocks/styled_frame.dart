import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/block_style.dart';
import '../../theme/book_theme.dart';

/// Wraps block content in the decoration its `style` asks for: plain box,
/// ornamental frame, black pill badge, circle badge, ornamental badge, or a
/// double underline.
class StyledFrame extends StatelessWidget {
  const StyledFrame({super.key, required this.style, required this.child, this.accent});

  final BlockStyle style;
  final Widget child;

  /// Border colour override (defaults to red for red styles, else the
  /// theme's border colour).
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final color = accent ?? (style.red ? book.red : book.border);

    if (style.blackBadge) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          decoration: BoxDecoration(color: book.badgeBg, borderRadius: BorderRadius.circular(40)),
          child: child,
        ),
      );
    }
    if (style.circleBadge) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: book.red,
            boxShadow: [BoxShadow(color: book.red.withValues(alpha: 0.3), blurRadius: 6)],
          ),
          child: Center(child: child),
        ),
      );
    }
    if (style.ornamentalBadge) {
      return Center(
        child: CustomPaint(
          painter: _OrnamentalBadgePainter(fill: book.boxTint, stroke: color),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
            child: child,
          ),
        ),
      );
    }
    if (style.ornamental || style.banner) {
      return CustomPaint(
        painter: OrnamentalFramePainter(color: color, fill: book.boxTint),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          child: child,
        ),
      );
    }
    if (style.boxed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: book.boxTint,
          border: Border.all(color: color, width: 1.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: style.exclamation
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 6, end: 8),
                    child: Icon(Icons.error_outline, color: book.red, size: 22),
                  ),
                  Expanded(child: child),
                ],
              )
            : child,
      );
    }
    if (style.underlined) {
      return Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: color, width: 2)),
        ),
        child: Container(
          padding: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color, width: 0.8))),
          child: child,
        ),
      );
    }
    return child;
  }
}

/// A double-ruled frame with flourished corners, drawn so it scales to any
/// block size without an image asset.
class OrnamentalFramePainter extends CustomPainter {
  OrnamentalFramePainter({required this.color, required this.fill});

  final Color color;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 6.0;
    final outer = Rect.fromLTWH(0, 0, size.width, size.height).deflate(2);
    final inner = outer.deflate(inset);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outer, const Radius.circular(10)),
      Paint()..color = fill,
    );
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final thin = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(RRect.fromRectAndRadius(outer, const Radius.circular(10)), stroke);
    canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(6)), thin);

    // Corner flourishes: a small diamond with two curls.
    final corners = [
      (outer.topLeft, 1.0, 1.0),
      (outer.topRight, -1.0, 1.0),
      (outer.bottomLeft, 1.0, -1.0),
      (outer.bottomRight, -1.0, -1.0),
    ];
    final solid = Paint()..color = color;
    for (final (p, sx, sy) in corners) {
      final c = p.translate(sx * inset, sy * inset);
      final diamond = Path()
        ..moveTo(c.dx, c.dy - 5)
        ..lineTo(c.dx + 5, c.dy)
        ..lineTo(c.dx, c.dy + 5)
        ..lineTo(c.dx - 5, c.dy)
        ..close();
      canvas.drawPath(diamond, solid);
      final curl = Path()
        ..moveTo(c.dx + sx * 6, c.dy)
        ..quadraticBezierTo(c.dx + sx * 16, c.dy - sy * 6, c.dx + sx * 24, c.dy)
        ..moveTo(c.dx, c.dy + sy * 6)
        ..quadraticBezierTo(c.dx - sx * 6, c.dy + sy * 16, c.dx, c.dy + sy * 24);
      canvas.drawPath(curl, stroke);
    }
    // Midpoint ornaments on the long edges.
    for (final y in [outer.top, outer.bottom]) {
      final m = Offset(outer.center.dx, y);
      canvas.drawCircle(m, 3.2, solid);
      canvas.drawCircle(m.translate(-9, 0), 1.6, solid);
      canvas.drawCircle(m.translate(9, 0), 1.6, solid);
    }
  }

  @override
  bool shouldRepaint(OrnamentalFramePainter old) => old.color != color || old.fill != fill;
}

/// Lozenge-shaped cartouche used for `ornamental_badge` titles.
class _OrnamentalBadgePainter extends CustomPainter {
  _OrnamentalBadgePainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final notch = math.min(h / 2, 18.0);
    final path = Path()
      ..moveTo(notch, 0)
      ..lineTo(w - notch, 0)
      ..quadraticBezierTo(w - notch * 0.2, h * 0.1, w, h / 2)
      ..quadraticBezierTo(w - notch * 0.2, h * 0.9, w - notch, h)
      ..lineTo(notch, h)
      ..quadraticBezierTo(notch * 0.2, h * 0.9, 0, h / 2)
      ..quadraticBezierTo(notch * 0.2, h * 0.1, notch, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final inner = path.shift(Offset.zero);
    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.scale((w - 8) / w, (h - 8) / h);
    canvas.translate(-w / 2, -h / 2);
    canvas.drawPath(
      inner,
      Paint()
        ..color = stroke.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrnamentalBadgePainter old) => old.fill != fill || old.stroke != stroke;
}

/// Rounded card with a coloured strip along its start (right, in RTL) edge.
///
/// Flutter can't combine rounded corners with a border whose sides differ in
/// colour, so the strip is painted as a separate layer.
class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.accent,
    required this.background,
    required this.child,
    this.outline,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 8),
  });

  final Color accent;
  final Color background;
  final Color? outline;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: outline != null ? Border.all(color: outline!) : null,
        ),
        child: Stack(
          children: [
            PositionedDirectional(start: 0, top: 0, bottom: 0, width: 4, child: ColoredBox(color: accent)),
            Padding(padding: padding.add(const EdgeInsetsDirectional.only(start: 4)), child: child),
          ],
        ),
      ),
    );
  }
}
