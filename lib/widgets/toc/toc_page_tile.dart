import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';
import '../common/script_text.dart';

class TocPageTile extends StatelessWidget {
  const TocPageTile({
    super.key,
    required this.title,
    required this.onTap,
    this.printedPage,
    this.leading,
    this.selected = false,
  });

  final String title;
  final String? printedPage;
  final String? leading;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return ListTile(
      dense: true,
      selected: selected,
      onTap: onTap,
      leading: leading != null
          ? SizedBox(
              width: 36,
              child: Text(
                leading!,
                textAlign: TextAlign.center,
                style: TextStyle(color: book.red),
              ),
            )
          : Icon(SolarIconsOutline.documentText, color: book.muted, size: 20),
      title: ScriptText(title, size: 13.5),
      trailing: printedPage != null
          ? Text(
              context.l10n.pageShort(printedPage!),
              style: TextStyle(color: book.muted),
            )
          : null,
    );
  }
}
