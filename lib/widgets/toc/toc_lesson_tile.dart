import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/book.dart';
import '../../theme/book_theme.dart';
import '../common/script_text.dart';

class TocLessonTile extends StatelessWidget {
  const TocLessonTile({
    super.key,
    required this.lesson,
    required this.selected,
    required this.onTap,
  });

  final LessonEntry lesson;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final l = context.l10n;
    return ListTile(
      selected: selected,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 17,
        backgroundColor: selected ? book.red : book.badgeBg,
        child: Text(
          lesson.lessonLabel,
          style: TextStyle(
            color: selected ? Colors.white : book.badgeFg,
            fontSize: lesson.lessonLabel.length > 2 ? 10 : 13,
          ),
        ),
      ),
      title: lesson.title != null
          ? ScriptText(lesson.title!, size: 14)
          : Text(l.lessonN(lesson.lessonLabel)),
      subtitle: Text(
        l.pagesCount(lesson.pageCount),
        style: TextStyle(color: book.muted, fontSize: 11),
      ),
      trailing: lesson.printedPage != null
          ? Text(
              l.pageShort(lesson.printedPage!),
              style: TextStyle(color: book.muted),
            )
          : null,
    );
  }
}
