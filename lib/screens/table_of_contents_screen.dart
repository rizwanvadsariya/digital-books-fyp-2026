import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../blocs/book_cubit.dart';
import '../l10n/l10n.dart';
import '../models/book.dart';
import '../models/content_block.dart';
import '../theme/book_theme.dart';
import '../widgets/common/script_text.dart';

/// Contents opened from inside the reader; pops with the chosen page index.
class TableOfContentsScreen extends StatelessWidget {
  const TableOfContentsScreen({super.key, this.currentIndex});

  final int? currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navContents)),
      body: TableOfContentsView(
        currentIndex: currentIndex,
        onOpen: (i) => Navigator.of(context).pop(i),
      ),
    );
  }
}

/// Unit → lesson → page navigation generated from every page's unit/lesson
/// fields, plus the book's own printed contents page.
class TableOfContentsView extends StatefulWidget {
  const TableOfContentsView({
    super.key,
    required this.onOpen,
    this.currentIndex,
  });

  final ValueChanged<int> onOpen;
  final int? currentIndex;

  @override
  State<TableOfContentsView> createState() => _TableOfContentsViewState();
}

class _TableOfContentsViewState extends State<TableOfContentsView> {
  final _sectionKeys = <String, GlobalKey>{};

  GlobalKey _key(String id) => _sectionKeys.putIfAbsent(id, GlobalKey.new);

  void _scrollTo(String id) {
    final ctx = _sectionKeys[id]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = context.read<BookCubit>().state.book!;
    final bookTheme = BookTheme.of(context);
    final l = context.l10n;
    // Front matter: pages before the first unit (the printed contents page
    // is listed with the extras instead).
    final frontMatter = book.frontMatter;
    // Extras: special pages (exam, model paper, contents…) that aren't part
    // of a lesson. Lesson pages with a kind (e.g. key_words) stay in their
    // lesson.
    final extras = [
      for (final p in book.pages)
        if (p.pageKind != null &&
            !p.isLessonPage &&
            p.pageKind != 'unit_cover' &&
            p.pageKind != 'pre_lesson' &&
            !frontMatter.contains(p))
          p,
    ];
    final printedRows = _printedRows(book.contentsPages);

    final chips = <(String, String)>[
      if (frontMatter.isNotEmpty) ('front', l.chipFront),
      for (final u in book.units) ('unit${u.unit}', l.unitN('${u.unit}')),
      if (extras.isNotEmpty) ('extra', l.chipExtra),
      if (printedRows.isNotEmpty) ('printed', l.chipPrinted),
    ];

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(chips.length, (index) {
              final (id, label) = chips[index];
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ActionChip(
                  labelPadding: const EdgeInsets.symmetric(horizontal: 1),
                  label: Text(label),
                  onPressed: () => _scrollTo(id),
                ),
              );
            }),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (frontMatter.isNotEmpty)
                  _SectionHeader(key: _key('front'), title: l.sectionFront),
                for (final p in frontMatter)
                  _PageTile(
                    title: _pageTitle(p) ?? l.pageN('${p.index + 1}'),
                    printedPage: p.printedPage,
                    selected: widget.currentIndex == p.index,
                    onTap: () => widget.onOpen(p.index),
                  ),
                for (final unit in book.units) ...[
                  _UnitHeader(
                    key: _key('unit${unit.unit}'),
                    unit: unit,
                    onTap: () => widget.onOpen(unit.coverPageIndex),
                  ),
                  for (final lesson in unit.lessons)
                    _LessonTile(
                      lesson: lesson,
                      selected:
                          widget.currentIndex != null &&
                          widget.currentIndex! >= lesson.firstPageIndex &&
                          widget.currentIndex! <
                              lesson.firstPageIndex + lesson.pageCount,
                      onTap: () => widget.onOpen(lesson.firstPageIndex),
                    ),
                ],
                if (extras.isNotEmpty)
                  _SectionHeader(key: _key('extra'), title: l.sectionExtra),
                for (final p in extras)
                  _PageTile(
                    title: pageLocation(l, p),
                    printedPage: p.printedPage,
                    selected: widget.currentIndex == p.index,
                    onTap: () => widget.onOpen(p.index),
                  ),
                if (printedRows.isNotEmpty) ...[
                  _SectionHeader(key: _key('printed'), title: l.sectionPrinted),
                  for (final row in printedRows)
                    _PageTile(
                      title: row.$1,
                      leading: row.$2,
                      printedPage: row.$3,
                      onTap: () {
                        final i = row.$3 == null
                            ? null
                            : book.indexForPrintedPage(row.$3!);
                        if (i != null) widget.onOpen(i);
                      },
                    ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l.totalPages(book.length),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: bookTheme.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String? _pageTitle(BookPage p) {
    for (final b in p.blocks) {
      if (b is TextBlock &&
          const {
            'title',
            'section_heading',
            'heading',
            'book_title',
            'subheading',
          }.contains(b.type)) {
        return b.text;
      }
    }
    return null;
  }

  /// (topic, lesson, printed page) rows from the printed contents tables.
  /// Columns are found by their printed headers: Volumes 1–2 use موضوع,
  /// Volume 3 splits it into عنوان (title) and ہدف (goal).
  static List<(String, String?, String?)> _printedRows(List<BookPage> pages) => [
    for (final page in pages)
      for (final b in page.blocks)
        if (b is TableBlock && b.keyForHeader('صفحہ') != null)
          for (final r in b.rows)
            (
              [
                for (final h in const ['موضوع', 'عنوان', 'ہدف'])
                  if (b.keyForHeader(h) case final k? when r[k] != null) r[k]!,
              ].join(' '),
              b.keyForHeader('سبق') == null ? null : r[b.keyForHeader('سبق')],
              r[b.keyForHeader('صفحہ')],
            ),
  ];
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: book.red, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _UnitHeader extends StatelessWidget {
  const _UnitHeader({super.key, required this.unit, required this.onTap});

  final UnitEntry unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 4),
      child: Material(
        color: book.red,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  context.l10n.unitN('${unit.unit}'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                if (unit.title != null)
                  Expanded(
                    child: ScriptText(
                      unit.title!,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 12),
                Text(
                  context.l10n.lessonsCount(unit.lessons.length),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
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

class _PageTile extends StatelessWidget {
  const _PageTile({
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
