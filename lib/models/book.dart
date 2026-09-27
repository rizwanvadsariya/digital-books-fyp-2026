import 'content_block.dart';

class BookPage {
  const BookPage({
    required this.index,
    required this.pdfPage,
    this.printedPage,
    this.unit,
    this.lessonLabel,
    this.pageKind,
    required this.blocks,
  });

  factory BookPage.fromJson(Map<String, dynamic> json, int index) {
    final rawLesson = json['lesson'];
    final rawUnit = json['unit'];
    return BookPage(
      index: index,
      pdfPage: (json['pdf_page'] as num?)?.toInt() ?? index + 1,
      printedPage: json['printed_page']?.toString(),
      unit: rawUnit is num ? rawUnit.toInt() : int.tryParse('${rawUnit ?? ''}'),
      lessonLabel: rawLesson?.toString(),
      pageKind: json['page_kind'] as String?,
      blocks: [
        for (final b in (json['blocks'] as List? ?? const []))
          if (b is Map) ContentBlock.fromJson(Map<String, dynamic>.from(b)),
      ],
    );
  }

  /// Zero-based position in the book.
  final int index;
  final int pdfPage;
  final String? printedPage;
  final int? unit;

  /// Usually a number (`"3"`), occasionally a range (`"15-16"`).
  final String? lessonLabel;
  final String? pageKind;
  final List<ContentBlock> blocks;

  /// Numeric lesson used for sorting; the first number of a range.
  int? get lessonNumber =>
      lessonLabel == null ? null : int.tryParse(lessonLabel!.split('-').first.trim());

  bool get isLessonPage => unit != null && lessonLabel != null;
}

class LessonEntry {
  const LessonEntry({
    required this.unit,
    required this.lessonLabel,
    required this.title,
    required this.firstPageIndex,
    required this.pageCount,
    this.printedPage,
  });

  final int unit;
  final String lessonLabel;

  /// The lesson's first heading from the book, if it has one.
  final String? title;
  final int firstPageIndex;
  final int pageCount;
  final String? printedPage;
}

class UnitEntry {
  const UnitEntry({
    required this.unit,
    required this.title,
    required this.coverPageIndex,
    required this.lessons,
  });

  final int unit;
  final String? title;
  final int coverPageIndex;
  final List<LessonEntry> lessons;
}

class Book {
  Book({required this.title, required this.pages});

  factory Book.fromJson(Map<String, dynamic> json) {
    final raw = json['pages'] as List? ?? const [];
    return Book(
      title: json['book_title']?.toString() ?? 'Muallim-Ul-Quran',
      pages: [
        for (var i = 0; i < raw.length; i++)
          BookPage.fromJson(Map<String, dynamic>.from(raw[i] as Map), i),
      ],
    );
  }

  final String title;
  final List<BookPage> pages;

  late final List<UnitEntry> units = _buildUnits();

  late final Map<String, int> _printedToIndex = {
    for (final p in pages)
      if (p.printedPage != null) p.printedPage!: p.index,
  };

  int get length => pages.length;

  int? indexForPrintedPage(String printed) {
    final direct = _printedToIndex[printed.trim()];
    if (direct != null) return direct;
    // Printed page N sits a fixed offset from its pdf page in this book;
    // fall back to the nearest known page for printed numbers without a page
    // of their own (e.g. covers).
    final n = int.tryParse(printed.trim());
    if (n == null) return null;
    int? best;
    var bestDist = 1 << 30;
    for (final entry in _printedToIndex.entries) {
      final m = int.tryParse(entry.key);
      if (m == null) continue;
      final d = (m - n).abs();
      if (d < bestDist) {
        bestDist = d;
        best = entry.value + (n - m);
      }
    }
    if (best == null) return null;
    return best.clamp(0, pages.length - 1);
  }

  int? indexForPdfPage(int pdfPage) {
    for (final p in pages) {
      if (p.pdfPage == pdfPage) return p.index;
    }
    return null;
  }

  BookPage? firstPageOfKind(String kind) {
    for (final p in pages) {
      if (p.pageKind == kind) return p;
    }
    return null;
  }

  /// The book's own (Urdu) label for a page's position, e.g. "یونٹ 2 · سبق 4",
  /// used for the badge printed on the page. Interface text uses the
  /// localized `pageLocation` in `l10n/l10n.dart` instead.
  String locationLabel(BookPage page) {
    if (page.isLessonPage) return 'یونٹ ${page.unit} · سبق ${page.lessonLabel}';
    switch (page.pageKind) {
      case 'unit_cover':
        return page.unit != null ? 'یونٹ ${page.unit}' : 'یونٹ';
      case 'pre_lesson':
        return 'یونٹ ${page.unit ?? ''} · تعارف';
      case 'sample_exam':
        return 'نمونہ امتحان';
      case 'table_of_contents':
        return 'فہرست';
      case 'back_matter':
        return 'اختتامیہ';
    }
    return 'مقدمہ';
  }

  List<UnitEntry> _buildUnits() {
    // Unit covers without a `unit` field precede that unit's first lesson.
    final coverFor = <int, int>{};
    final unitTitles = <int, String>{};
    int? pendingCover;
    String? pendingTitle;

    final lessonsByUnit = <int, List<LessonEntry>>{};
    String? currentKey;
    for (final page in pages) {
      if (page.pageKind == 'unit_cover') {
        pendingCover = page.index;
        pendingTitle = _firstText(page, const {'unit_title'});
        if (page.unit != null) {
          coverFor[page.unit!] = page.index;
          if (pendingTitle != null) unitTitles[page.unit!] = pendingTitle;
        }
        continue;
      }
      final unit = page.unit;
      if (unit == null) continue;
      if (pendingCover != null) {
        coverFor.putIfAbsent(unit, () => pendingCover!);
        if (pendingTitle != null) unitTitles.putIfAbsent(unit, () => pendingTitle!);
        pendingCover = null;
        pendingTitle = null;
      }
      if (!page.isLessonPage) continue;

      final key = '$unit/${page.lessonLabel}';
      final list = lessonsByUnit.putIfAbsent(unit, () => []);
      if (key == currentKey && list.isNotEmpty) {
        final last = list.removeLast();
        list.add(LessonEntry(
          unit: unit,
          lessonLabel: last.lessonLabel,
          title: last.title,
          firstPageIndex: last.firstPageIndex,
          pageCount: last.pageCount + 1,
          printedPage: last.printedPage,
        ));
      } else {
        currentKey = key;
        list.add(LessonEntry(
          unit: unit,
          lessonLabel: page.lessonLabel!,
          title: _firstText(page, const {'heading', 'title', 'section_heading', 'subheading'}),
          firstPageIndex: page.index,
          pageCount: 1,
          printedPage: page.printedPage,
        ));
      }
    }

    final unitNumbers = lessonsByUnit.keys.toList()..sort();
    return [
      for (final u in unitNumbers)
        UnitEntry(
          unit: u,
          title: unitTitles[u],
          coverPageIndex: coverFor[u] ?? lessonsByUnit[u]!.first.firstPageIndex,
          lessons: lessonsByUnit[u]!
            ..sort((a, b) => a.firstPageIndex.compareTo(b.firstPageIndex)),
        ),
    ];
  }

  static String? _firstText(BookPage page, Set<String> types) {
    for (final b in page.blocks) {
      if (b is TextBlock && types.contains(b.type) && b.text.trim().isNotEmpty) {
        return b.text.trim();
      }
    }
    return null;
  }
}
