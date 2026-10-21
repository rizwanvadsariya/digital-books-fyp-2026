import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/answers_cubit.dart';
import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';

/// "7/10" score and a Reset button for one exercise's gradable items.
class ExerciseScoreBar extends StatelessWidget {
  const ExerciseScoreBar({super.key, required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) return const SizedBox.shrink();
    final book = BookTheme.of(context);
    final l = context.l10n;
    final checks = context.select<AnswersCubit, Map<String, bool>>((c) => c.state.checks);
    final correct = ids.where((id) => checks[id] == true).length;
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Row(
        children: [
          Text(
            l.scoreFraction(correct, ids.length),
            style: TextStyle(fontSize: 12, color: book.muted, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => context.read<AnswersCubit>().resetIds(ids),
            icon: const Icon(Icons.refresh, size: 15),
            label: Text(l.resetExercise, style: TextStyle(fontSize: 12, color: book.muted)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
