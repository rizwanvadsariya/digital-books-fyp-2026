import 'package:flutter/material.dart';

import '../../theme/book_theme.dart';

class BulletedItem extends StatelessWidget {
  const BulletedItem({
    super.key,
    required this.marker,
    required this.child,
  });

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
