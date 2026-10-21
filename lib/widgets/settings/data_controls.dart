import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../blocs/answers_cubit.dart';
import '../../blocs/progress_cubit.dart';
import '../../l10n/l10n.dart';

class DataControls extends StatelessWidget {
  const DataControls({super.key});

  Future<void> _handleDeleteAllAnswers(BuildContext context) async {
    final l = context.l10n;
    if (await _confirm(context, l.deleteAllAnswersQuestion, l.delete) &&
        context.mounted) {
      context.read<AnswersCubit>().clearAll();
    }
  }

  Future<void> _handleRemoveAllBookmarks(BuildContext context) async {
    final l = context.l10n;
    if (await _confirm(
          context,
          l.removeAllBookmarksQuestion,
          l.remove,
        ) &&
        context.mounted) {
      context.read<ProgressCubit>().clearBookmarks();
    }
  }

  static Future<bool> _confirm(BuildContext context, String title, String action) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(l.cannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final answers = context.select<AnswersCubit, int>(
      (c) => c.state.answers.length,
    );
    final bookmarks = context.select<ProgressCubit, int>(
      (c) => c.state.bookmarks.length,
    );
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(SolarIconsOutline.notes),
          title: Text(l.deleteAllAnswers),
          subtitle: Text(l.answersSaved(answers)),
          enabled: answers > 0,
          onTap: () => _handleDeleteAllAnswers(context),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(SolarIconsOutline.bookmarkSquare),
          title: Text(l.removeAllBookmarks),
          subtitle: Text(l.bookmarksSaved(bookmarks)),
          enabled: bookmarks > 0,
          onTap: () => _handleRemoveAllBookmarks(context),
        ),
      ],
    );
  }
}
