import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';

class CheckButton extends StatelessWidget {
  const CheckButton({
    super.key,
    required this.result,
    required this.onPressed,
  });

  final bool? result;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final (icon, color) = switch (result) {
      true => (SolarIconsBold.checkCircle, book.correct),
      false => (SolarIconsBold.closeCircle, book.incorrect),
      null => (SolarIconsOutline.checkCircle, book.muted),
    };
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: context.l10n.checkAnswer,
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
      ),
    );
  }
}
