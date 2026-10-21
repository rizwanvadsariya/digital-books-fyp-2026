import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../blocs/progress_cubit.dart';
import '../../l10n/l10n.dart';
import '../../models/book.dart';
import '../../models/content_block.dart';
import '../../theme/book_theme.dart';
import '../common/script_text.dart';

class BookmarkTile extends StatelessWidget {
  const BookmarkTile({
    super.key,
    required this.page,
    required this.onOpen,
  });

  final BookPage page;
  final ValueChanged<int> onOpen;

  void _handleDismiss(BuildContext context) {
    context.read<ProgressCubit>().toggleBookmark(page.index);
  }

  void _handleTap() {
    onOpen(page.index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    final l = context.l10n;
    final heading = page.blocks.whereType<TextBlock>().where((b) => b.type == 'heading').firstOrNull;

    return Dismissible(
      key: ValueKey(page.index),
      background: Container(color: theme.red),
      onDismissed: (_) => _handleDismiss(context),
      child: ListTile(
        leading: Icon(SolarIconsBold.bookmark, color: theme.red),
        title: Text(pageLocation(l, page), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: heading != null ? ScriptText(heading.text, size: 12, color: theme.muted) : null,
        trailing: Text(l.pageShort(page.printedPage ?? '${page.index + 1}')),
        onTap: _handleTap,
      ),
    );
  }
}
