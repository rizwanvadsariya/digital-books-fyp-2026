import 'package:flutter/material.dart';

import '../../theme/book_theme.dart';
import '../common/script_text.dart';

class LabelledBox extends StatelessWidget {
  const LabelledBox({
    super.key,
    required this.label,
    required this.color,
    required this.child,
  });

  final String? label;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: book.boxTint,
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(8),
                    bottomEnd: Radius.circular(10),
                  ),
                ),
                child: ScriptText(
                  label!,
                  size: 13,
                  bold: true,
                  color: Colors.white,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: child,
          ),
        ],
      ),
    );
  }
}
