import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../blocs/answers_cubit.dart';
import '../blocs/book_cubit.dart';
import '../blocs/settings_cubit.dart';
import '../data/exercise_lookup.dart';
import '../l10n/l10n.dart';
import '../theme/book_theme.dart';
import '../widgets/exercise/answer_row.dart';
import 'reader_screen.dart';

/// Every saved answer, grouped by page, with the exercise it belongs to.
class AnswersReviewScreen extends StatelessWidget {
  const AnswersReviewScreen({super.key});

  Future<void> _handleConfirmClear(BuildContext context) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteAllAnswersQuestion),
        content: Text(l.cannotBeUndone),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AnswersCubit>().clearAll();
    }
  }

  void _handleOpenPage(BuildContext context, int pageIndex) {
    openReader(context, pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    final book = context.read<BookCubit>().state.book!;
    final answers = context.select<AnswersCubit, Map<String, String>>((c) => c.state.answers);
    final strict = context.select<SettingsCubit, bool>((c) => c.state.strictMatching);
    final theme = BookTheme.of(context);
    final l = context.l10n;

    final byPage = <int, List<(String, String, ExerciseInfo)>>{};
    for (final e in answers.entries) {
      final info = describeAnswer(book, e.key);
      if (info == null) continue;
      byPage.putIfAbsent(info.page.index, () => []).add((e.key, e.value, info));
    }
    final pages = byPage.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.myAnswersCount(answers.length)),
        actions: [
          if (answers.isNotEmpty)
            IconButton(
              tooltip: l.deleteAllAnswers,
              icon: const Icon(SolarIconsOutline.trashBinTrash),
              onPressed: () => _handleConfirmClear(context),
            ),
        ],
      ),
      body: pages.isEmpty
          ? Center(
              child: Text(l.noAnswersYet, style: TextStyle(color: theme.muted)),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: pages.length,
              itemBuilder: (context, i) {
                final page = book.pages[pages[i]];
                final entries = byPage[pages[i]]!;
                return Card(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        tileColor: theme.red.withValues(alpha: 0.08),
                        title: Text(pageLocation(l, page), style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: TextButton.icon(
                          icon: const Icon(SolarIconsOutline.export, size: 16),
                          label: Text(page.printedPage != null ? l.pageShort(page.printedPage!) : l.open),
                          onPressed: () => _handleOpenPage(context, page.index),
                        ),
                      ),
                      for (final (_, answer, info) in entries)
                        AnswerRow(answer: answer, info: info, strict: strict),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
