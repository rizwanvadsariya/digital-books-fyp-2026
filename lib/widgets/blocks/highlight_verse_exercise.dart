import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../blocs/answers_cubit.dart';
import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../../utils/exercise_grading.dart';
import '../common/script_text.dart';

/// Exercise type 7: the learner taps one or more words in the verse to
/// highlight the part whose meaning they've learned. [expected] is the
/// required span — several words joined by "، " when more than one word
/// must be selected. The selection is persisted as the comma-joined word
/// indexes of [verse].
class HighlightVerseExercise extends StatefulWidget {
  const HighlightVerseExercise({
    super.key,
    required this.index,
    required this.verse,
    required this.id,
    required this.expected,
  });

  final int index;
  final String verse;
  final String id;
  final String? expected;

  @override
  State<HighlightVerseExercise> createState() => _HighlightVerseExerciseState();
}

class _HighlightVerseExerciseState extends State<HighlightVerseExercise> {
  late final List<String> _words;
  late final AnswersCubit _answers;
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _answers = context.read<AnswersCubit>();
    _words = widget.verse.split(RegExp(r'\s+'));
    _selected = _parse(_answers.answerFor(widget.id));
  }

  Set<int> _parse(String stored) => stored
      .split(',')
      .map(int.tryParse)
      .whereType<int>()
      .where((i) => i >= 0 && i < _words.length)
      .toSet();

  void _toggle(int i) {
    setState(() {
      if (!_selected.remove(i)) _selected.add(i);
    });
    _answers.setAnswer(widget.id, _selected.join(','));
  }

  void _check() {
    final expected = widget.expected;
    if (expected == null) return;
    final selected = {for (final i in _selected) _words[i]};
    _answers.recordResult(widget.id, gradeHighlightSelection(selected, expected));
  }

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final l = context.l10n;
    final result = context.select<AnswersCubit, bool?>((c) => c.state.checks[widget.id]);
    final (icon, color) = switch (result) {
      true => (SolarIconsBold.checkCircle, book.correct),
      false => (SolarIconsBold.closeCircle, book.incorrect),
      null => (SolarIconsOutline.checkCircle, book.muted),
    };
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
      decoration: BoxDecoration(color: book.verseTint, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6, top: 10),
                child: Text('${widget.index + 1}.', style: TextStyle(color: book.muted, fontSize: 12)),
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 2,
                    children: [
                      for (var i = 0; i < _words.length; i++)
                        GestureDetector(
                          onTap: () => _toggle(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                            decoration: BoxDecoration(
                              color: _selected.contains(i) ? book.accent.withValues(alpha: 0.28) : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ScriptText(_words[i], size: 18, forceScript: Script.arabic),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(l.hintTapToHighlight, style: TextStyle(fontSize: 11, color: book.muted)),
              ),
              IconButton(
                tooltip: l.checkAnswer,
                visualDensity: VisualDensity.compact,
                icon: Icon(icon, color: color, size: 22),
                onPressed: widget.expected == null ? null : _check,
              ),
            ],
          ),
          if (result == false && widget.expected != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: l.correctAnswerLabel, style: TextStyle(fontSize: 11, color: book.muted)),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: ScriptText(widget.expected!, size: 12, color: book.correct),
                  ),
                ]),
                textDirection: TextDirection.rtl,
              ),
            ),
        ],
      ),
    );
  }
}
