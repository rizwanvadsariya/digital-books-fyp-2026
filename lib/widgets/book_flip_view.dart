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
            physics: const ClampingScrollPhysics(parent: PageScrollPhysics()),
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
    if (delta.abs() < 0.0005) return child;
    if (delta <= -1.0 || delta >= 1.0) {
      return Visibility(visible: false, maintainState: true, child: child);
    }

    // Cancel PageView's slide so the page stays in place and rotates about its spine.
    final hold = Offset(-delta * width, 0);

    // =========================================================================
    // CASE 1: Page underneath being revealed (delta in [-1, 0])
    // =========================================================================
    if (delta < 0) {
      final shadowProgress = (-delta).clamp(0.0, 1.0);
      final reveal = 1.0 - shadowProgress;

      // Project the physical 3D position of the lifted edge onto the underneath page
      final turnAngle = Curves.easeInOutSine.transform(shadowProgress) * (math.pi / 2.02);
      final projectedEdgeX = (width * (1.0 - math.cos(turnAngle))).clamp(0.0, width);
      final edgeNorm = (projectedEdgeX / width).clamp(0.0, 1.0);

      // Contact shadow band coordinates tracking the moving 3D edge
      final s0 = (edgeNorm - 0.10).clamp(0.0, 1.0);
      final s1 = edgeNorm.clamp(s0, 1.0);
      final s2 = (edgeNorm + 0.22).clamp(s1, 1.0);

      final curl = math.sin(shadowProgress * math.pi);

      return Transform.translate(
        offset: hold,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            child,

            // 1. Ambient canopy shadow: light floods in from the revealed left;
            // the area under the standing page is softly darkened.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.08 * shadowProgress),
                        Colors.black.withValues(alpha: 0.35 * shadowProgress),
                      ],
                      stops: [
                        (reveal * 0.70).clamp(0.0, 0.70),
                        (reveal * 0.70 + 0.20).clamp(0.20, 0.90),
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Focused moving contact drop-shadow tracking the 3D turning edge:
            if (s1 > 0.02 && s1 < 0.98)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.24 * curl),
                          Colors.transparent,
                        ],
                        stops: [s0, s1, s2],
                      ),
                    ),
                  ),
                ),
              ),

            // 3. Realistic spine gutter crease (deep inner crease + soft ambient roll)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 36,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withValues(alpha: 0.30 * shadowProgress),
                        Colors.black.withValues(alpha: 0.12 * shadowProgress),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.20, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // =========================================================================
    // CASE 2: Page on top turning away towards the spine (delta in [0, 1])
    // =========================================================================
    final turn = delta.clamp(0.0, 1.0);
    // Smooth natural paper ease curve: organic initial peel and soft landing into spine
    final curvedTurn = Curves.easeInOutSine.transform(turn);
    final angle = curvedTurn * (math.pi / 2.02);

    // Physical paper flex / curl factor: 0 at start, peak around mid-turn, 0 when turned.
    final curl = math.sin(turn * math.pi);

    // Subtle 3D cylindrical compression (projected height contracts slightly as paper bends)
    final verticalCompression = 1.0 - (0.024 * curl);
    // Subtle organic curl tilt along the diagonal: lifted corner elevates slightly
    final tilt = -0.014 * curl;

    // Moving specular highlight apex along the paper's arching curvature
    final apex = (1.0 - turn * 0.72).clamp(0.08, 0.92);

    return Transform.translate(
      offset: hold,
      child: Transform(
        alignment: Alignment.centerRight,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0011) // Rich 3D perspective depth like Apple Books
          ..rotateY(angle)
          ..rotateZ(tilt)
          ..scale(1.0, verticalCompression, 1.0),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            child,

            // 1. Dynamic lighting across the curving page:
            // - Soft ambient shading on the curling left edge
            // - Moving specular highlight ridge across the curve crest
            // - Deepening shadow near the spine hinge as angle steepens
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.20 * turn),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.18 * curl),
                        Colors.black.withValues(alpha: 0.07 * turn),
                        Colors.black.withValues(alpha: 0.26 * turn),
                      ],
                      stops: [
                        0.0,
                        (apex - 0.14).clamp(0.04, 0.82),
                        apex,
                        (apex + 0.14).clamp(0.18, 0.96),
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Crisp dual-tone paper rim (illuminated highlight + contact bevel)
            // Gives the paper physical thickness and crispness on high-res displays
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: 2.0,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.40 * curl),
                        Colors.black.withValues(alpha: 0.20 * curl),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.30 * curl),
                        blurRadius: 6,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Spine hinge crease on the turning page:
            // Simulates the physical stress line where the page bends at the binding
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 20,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withValues(alpha: 0.24 * turn),
                        Colors.transparent,
                      ],
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
