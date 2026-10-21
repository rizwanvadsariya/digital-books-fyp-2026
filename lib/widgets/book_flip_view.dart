import 'package:flutter/material.dart';

import 'flip_transform.dart';

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

  void _handlePageChanged(int pos) {
    onPageChanged(positionForIndex(pos, itemCount));
  }

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
            onPageChanged: _handlePageChanged,
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
                  return FlipTransform(delta: pos - current, width: width, child: child!);
                },
              );
            },
          );
        },
      ),
    );
  }
}
