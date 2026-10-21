import 'package:flutter/material.dart';

import '../../data/volumes.dart';
import '../../theme/book_theme.dart';
import '../blocks/styled_frame.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.volume,
    required this.tagline,
    required this.onTap,
  });

  final BookVolume volume;
  final String? tagline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFE6C77A);
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF7A1F1A), Color(0xFF3E0F0C)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: CustomPaint(
              painter: OrnamentalFramePainter(
                color: gold,
                fill: Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 34,
                ),
                child: Column(
                  children: [
                    const Text(
                      'مُعَلِّمُ الْقُرْآن',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: arabicFont,
                        fontSize: 40,
                        color: gold,
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                      ),
                    ),
                    Text(
                      volume.coverSubtitle,
                      style: const TextStyle(
                        fontFamily: urduFont,
                        fontSize: 16,
                        color: Colors.white,
                        height: 2,
                      ),
                    ),
                    if (tagline != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        tagline!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: urduFont,
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
