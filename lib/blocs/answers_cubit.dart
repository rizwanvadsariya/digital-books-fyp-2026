import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/local_store.dart';
import '../utils/arabic_text.dart';

/// Stable ID for one answerable slot: `{pdf_page}_{block_index}_{item_index}`.
/// Table cells use `{row}-{column}` as the item index.
String answerId(int pdfPage, int blockIndex, Object itemIndex) => '${pdfPage}_${blockIndex}_$itemIndex';

class AnswerIdParts {
  const AnswerIdParts(this.pdfPage, this.blockIndex, this.item);

  static AnswerIdParts? parse(String id) {
    final parts = id.split('_');
    if (parts.length != 3) return null;
    final page = int.tryParse(parts[0]);
    final block = int.tryParse(parts[1]);
    if (page == null || block == null) return null;
    return AnswerIdParts(page, block, parts[2]);
  }

  final int pdfPage;
  final int blockIndex;
  final String item;
}

class AnswersState extends Equatable {
  const AnswersState({this.answers = const {}, this.checks = const {}});

  final Map<String, String> answers;

  /// Result of the last "check" per answer ID; cleared when the answer changes.
  final Map<String, bool> checks;

  @override
  List<Object?> get props => [answers, checks];
}

class AnswersCubit extends Cubit<AnswersState> {
  AnswersCubit(this._store)
      : super(AnswersState(answers: _store.readAnswers(), checks: _store.readChecks()));

  final LocalStore _store;
  Timer? _saveTimer;

  String answerFor(String id) => state.answers[id] ?? '';

  void setAnswer(String id, String text) {
    if (answerFor(id) == text) return;
    final answers = {...state.answers};
    if (text.trim().isEmpty) {
      answers.remove(id);
    } else {
      answers[id] = text;
    }
    final checks = {...state.checks}..remove(id);
    emit(AnswersState(answers: answers, checks: checks));
    _scheduleSave();
  }

  /// Grades the stored answer for [id] against the book's [key].
  bool check(String id, String key, {required bool strict}) {
    final ok = answerMatches(answerFor(id), key, strict: strict);
    _setCheck(id, ok);
    return ok;
  }

  /// Records a result computed elsewhere (a custom grading rule, a
  /// highlight/set exercise, or the learner self-marking a translation).
  void recordResult(String id, bool ok) => _setCheck(id, ok);

  void _setCheck(String id, bool ok) {
    emit(AnswersState(answers: state.answers, checks: {...state.checks, id: ok}));
    _scheduleSave();
  }

  /// Clears the answer and check result for a specific set of IDs, e.g. all
  /// items of one exercise ("Reset" on that exercise).
  void resetIds(Iterable<String> ids) {
    final answers = {...state.answers};
    final checks = {...state.checks};
    for (final id in ids) {
      answers.remove(id);
      checks.remove(id);
    }
    emit(AnswersState(answers: answers, checks: checks));
    _scheduleSave();
  }

  void clearAll() {
    emit(const AnswersState());
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), flush);
  }

  /// Writes answers and check results to disk now (also called when the app
  /// is backgrounded).
  Future<void> flush() {
    _saveTimer?.cancel();
    return Future.wait([
      _store.writeAnswers(state.answers),
      _store.writeChecks(state.checks),
    ]);
  }

  @override
  Future<void> close() async {
    await flush();
    return super.close();
  }
}
