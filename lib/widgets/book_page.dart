import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/progress_cubit.dart';
import '../models/book.dart';
import '../models/content_block.dart';
import '../theme/book_theme.dart';
import 'blocks/block_renderer.dart';
import 'reader/page_footer.dart';
import 'reader/page_header.dart';

/// One printed page: paper background, pinned unit/lesson badge, the page's
/// blocks in a scrollable column, and the printed page number as a footer.
class BookPageView extends StatelessWidget {
  const BookPageView({super.key, required this.book, required this.page});

  final Book book;
  final BookPage page;

  static const _pinnedTypes = {'lesson_marker', 'unit_marker'};

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    final bookmarked = context.select<ProgressCubit, bool>((c) => c.state.isBookmarked(page.index));

    TextBlock? marker;
    final body = <(int, ContentBlock)>[];
    for (var i = 0; i < page.blocks.length; i++) {
      final b = page.blocks[i];
      // A bare number (e.g. a unit cover's circle badge "5") isn't a useful
      // header, so it stays inline and the header shows the page's label.
      if (marker == null &&
          b is TextBlock &&
          _pinnedTypes.contains(b.type) &&
          int.tryParse(b.text.trim()) == null) {
        marker = b;
      } else {
        body.add((i, b));
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(6, 6, 0, 6),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: const BorderRadiusDirectional.horizontal(end: Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(-2, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadiusDirectional.horizontal(end: Radius.circular(10)).resolve(TextDirection.rtl),
        child: Stack(
          children: [
            // Paper grain: a soft vignette plus the gutter shadow along the
            // spine (the right edge for a right-to-left book).
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.2, -0.3),
                    radius: 1.3,
                    colors: [theme.paper, Color.lerp(theme.paper, theme.paperShade, 0.55)!],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 22,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Colors.black.withValues(alpha: 0.16), Colors.transparent],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                PageHeader(label: marker?.text ?? book.locationLabel(page), bookmarked: bookmarked),
                Expanded(
                  child: ListView.separated(
                    key: PageStorageKey('page-${page.index}'),
                    padding: const EdgeInsets.fromLTRB(20, 4, 26, 24),
                    itemCount: body.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => BlockRenderer(
                      block: body[i].$2,
                      pdfPage: page.pdfPage,
                      blockIndex: body[i].$1,
                    ),
                  ),
                ),
                PageFooter(page: page, total: book.length),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
