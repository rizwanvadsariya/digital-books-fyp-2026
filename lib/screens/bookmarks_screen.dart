import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../blocs/book_cubit.dart';
import '../blocs/progress_cubit.dart';
import '../l10n/l10n.dart';
import '../theme/book_theme.dart';
import '../widgets/bookmarks/bookmark_tile.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key, required this.onOpen});

  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final book = context.read<BookCubit>().state.book!;
    final theme = BookTheme.of(context);
    final l = context.l10n;
    final bookmarkSet = context.select<ProgressCubit, Set<int>>((c) => c.state.bookmarks);
    final bookmarks = bookmarkSet.toList()..sort();

    if (bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(SolarIconsOutline.bookmark, size: 56, color: theme.muted),
              const SizedBox(height: 12),
              Text(l.noBookmarksTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                l.noBookmarksHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.muted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: bookmarks.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final page = book.pages[bookmarks[i]];
        return BookmarkTile(page: page, onOpen: onOpen);
      },
    );
  }
}
