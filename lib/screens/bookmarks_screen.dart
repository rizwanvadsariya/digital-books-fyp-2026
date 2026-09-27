import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/book_cubit.dart';
import '../blocs/progress_cubit.dart';
import '../models/content_block.dart';
import '../theme/book_theme.dart';
import '../widgets/common/script_text.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key, required this.onOpen});

  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final book = context.read<BookCubit>().state.book!;
    final theme = BookTheme.of(context);
    final bookmarks = context.select<ProgressCubit, List<int>>((c) => c.state.bookmarks.toList()..sort());

    if (bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_border, size: 56, color: theme.muted),
              const SizedBox(height: 12),
              const Text('ابھی کوئی بک مارک نہیں', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'کسی صفحے پر اوپر بک مارک کا نشان دبائیں',
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
        final heading = page.blocks.whereType<TextBlock>().where((b) => b.type == 'heading').firstOrNull;
        return Dismissible(
          key: ValueKey(page.index),
          background: Container(color: theme.red),
          onDismissed: (_) => context.read<ProgressCubit>().toggleBookmark(page.index),
          child: ListTile(
            leading: Icon(Icons.bookmark, color: theme.red),
            title: ScriptText(book.locationLabel(page), size: 14, bold: true),
            subtitle: heading != null ? ScriptText(heading.text, size: 12, color: theme.muted) : null,
            trailing: Text(page.printedPage != null ? 'ص ${page.printedPage}' : '${page.index + 1}'),
            onTap: () => onOpen(page.index),
          ),
        );
      },
    );
  }
}
