import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/book_cubit.dart';
import '../l10n/l10n.dart';
import '../models/book.dart';
import '../models/content_block.dart';
import '../theme/book_theme.dart';
import '../widgets/toc/toc_lesson_tile.dart';
import '../widgets/toc/toc_page_tile.dart';
import '../widgets/toc/toc_section_header.dart';
import '../widgets/toc/toc_unit_header.dart';

/// Contents opened from inside the reader; pops with the chosen page index.
class TableOfContentsScreen extends StatelessWidget {
  const TableOfContentsScreen({super.key, this.currentIndex});

  final int? currentIndex;

  void _handlePop(BuildContext context, int pageIndex) {
    Navigator.of(context).pop(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navContents)),
      body: TableOfContentsView(
        currentIndex: currentIndex,
        onOpen: (i) => _handlePop(context, i),
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

  void _handleOpen(int index) {
    widget.onOpen(index);
  }

  void _handlePrintedRowTap(Book book, String? printedPage) {
    final i = printedPage == null ? null : book.indexForPrintedPage(printedPage);
    if (i != null) {
      widget.onOpen(i);
    }
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
                  TocSectionHeader(key: _key('front'), title: l.sectionFront),
                for (final p in frontMatter)
                  TocPageTile(
                    title: _pageTitle(p) ?? l.pageN('${p.index + 1}'),
                    printedPage: p.printedPage,
                    selected: widget.currentIndex == p.index,
                    onTap: () => _handleOpen(p.index),
                  ),
                for (final unit in book.units) ...[
                  TocUnitHeader(
                    key: _key('unit${unit.unit}'),
                    unit: unit,
                    onTap: () => _handleOpen(unit.coverPageIndex),
                  ),
                  for (final lesson in unit.lessons)
                    TocLessonTile(
                      lesson: lesson,
                      selected:
                          widget.currentIndex != null &&
                          widget.currentIndex! >= lesson.firstPageIndex &&
                          widget.currentIndex! <
                              lesson.firstPageIndex + lesson.pageCount,
                      onTap: () => _handleOpen(lesson.firstPageIndex),
                    ),
                ],
                if (extras.isNotEmpty)
                  TocSectionHeader(key: _key('extra'), title: l.sectionExtra),
                for (final p in extras)
                  TocPageTile(
                    title: pageLocation(l, p),
                    printedPage: p.printedPage,
                    selected: widget.currentIndex == p.index,
                    onTap: () => _handleOpen(p.index),
                  ),
                if (printedRows.isNotEmpty) ...[
                  TocSectionHeader(key: _key('printed'), title: l.sectionPrinted),
                  for (final row in printedRows)
                    TocPageTile(
                      title: row.$1,
                      leading: row.$2,
                      printedPage: row.$3,
                      onTap: () => _handlePrintedRowTap(book, row.$3),
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
}
