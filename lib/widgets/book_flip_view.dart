import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Right-to-left page turner with a 3D page-flip effect.
///
/// Built on [PageView] for its physics and gestures, with two tricks:
/// - Scroll positions are the book indexes reversed, and the PageView itself
///   is laid out left-to-right. Dragging left→right therefore advances the
///   book (as in an Arabic/Urdu book), and because later scroll positions
///   paint on top, the page being turned is always drawn above the one it
///   reveals.
/// - Each page is counter-translated so it stays put; the top page rotates
///   about its spine (right edge) instead of sliding.
class BookFlipView extends StatelessWidget {
  const BookFlipView({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.pageBuilder,
    required this.onPageChanged,
  });

  /// Controller in *scroll-position* space; use [positionForIndex].
  final PageController controller;
  final int itemCount;
  final Widget Function(BuildContext context, int bookIndex) pageBuilder;
  final ValueChanged<int> onPageChanged;

  static int positionForIndex(int bookIndex, int itemCount) => itemCount - 1 - bookIndex;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return PageView.builder(
            controller: controller,
            itemCount: itemCount,
            onPageChanged: (pos) => onPageChanged(positionForIndex(pos, itemCount)),
            itemBuilder: (context, pos) {
              final page = Directionality(
                textDirection: TextDirection.rtl,
                child: pageBuilder(context, positionForIndex(pos, itemCount)),
              );
              return AnimatedBuilder(
                animation: controller,
                child: page,
                builder: (context, child) {
                  final current = controller.hasClients && controller.position.haveDimensions
                      ? controller.page!
                      : controller.initialPage.toDouble();
                  return _FlipTransform(delta: pos - current, width: width, child: child!);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _FlipTransform extends StatelessWidget {
  const _FlipTransform({required this.delta, required this.width, required this.child});

  /// Distance of this page from the settled position: 0 = fully shown,
  /// (0, 1) = on top and turning away, (-1, 0) = underneath being revealed.
  final double delta;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (delta.abs() < 0.0005 || delta.abs() >= 1) return child;

    // Cancel PageView's slide so the page stays in place.
    final hold = Offset(-delta * width, 0);

    if (delta < 0) {
      final shade = (-delta) * 0.35;
      return Transform.translate(
        offset: hold,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: Colors.black.withValues(alpha: shade))),
            ),
          ],
        ),
      );
    }

    // Positive rotation swings the free edge away from the viewer, folding
    // the page back over the spine.
    final angle = delta * math.pi / 2;
    final light = (delta * 1.6).clamp(0.0, 1.0);
    return Transform.translate(
      offset: hold,
      child: Transform(
        alignment: Alignment.centerRight,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0011)
          ..rotateY(angle),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            child,
            // Light falling across the lifted page: darker toward the free
            // (left) edge as it curls away.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.35 * light),
                        Colors.black.withValues(alpha: 0.05 * light),
                        Colors.white.withValues(alpha: 0.08 * light),
                      ],
                      stops: const [0, 0.7, 1],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
