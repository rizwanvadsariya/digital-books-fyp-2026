import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/answers_cubit.dart';
import '../../blocs/settings_cubit.dart';
import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';
import '../../utils/arabic_text.dart';
import '../keyboard/keyboard_cubit.dart';
import '../keyboard/keyboard_layouts.dart';

/// The printed blank line (`______`) of an exercise, made answerable.
///
/// Tapping it opens the embedded Arabic/Urdu keyboard (or the device
/// keyboard, if the learner switched to it). Text is saved per [id]. When
/// [answerKey] is given, a check button grades the answer against it.
class AnswerField extends StatefulWidget {
  const AnswerField({
    super.key,
    required this.id,
    this.answerKey,
    this.language = KeyboardLanguage.urdu,
    this.hint,
  });

  final String id;
  final String? answerKey;

  /// Layout the keyboard switches to when this field is tapped: Urdu for
  /// translations, Arabic when the answer is Quranic text.
  final KeyboardLanguage language;
  final String? hint;

  @override
  State<AnswerField> createState() => _AnswerFieldState();
}

class _AnswerFieldState extends State<AnswerField> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  late final KeyboardCubit _keyboard;
  late final AnswersCubit _answers;

  @override
  void initState() {
    super.initState();
    _keyboard = context.read<KeyboardCubit>();
    _answers = context.read<AnswersCubit>();
    _controller = TextEditingController(text: _answers.answerFor(widget.id));
    _controller.addListener(_onChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _keyboard.detach(widget.id);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() => _answers.setAnswer(widget.id, _controller.text);

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _keyboard.state.activeId != widget.id)
      _activate();
  }

  void _activate() {
    _keyboard.attach(
      widget.id,
      _controller,
      _focusNode,
      preferred: widget.language,
    );
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
    // Wait for the docked keyboard to take its space, then bring the field
    // above it. Only the page's own (vertical) list is scrolled:
    // Scrollable.ensureVisible would also nudge the horizontal page turner
    // and flip the page.
    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      final scrollable = Scrollable.maybeOf(context, axis: Axis.vertical);
      final target = context.findRenderObject();
      if (scrollable == null || target == null) return;
      scrollable.position.ensureVisible(
        target,
        alignment: 0.4,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _check() {
    final key = widget.answerKey;
    if (key == null) return;
    _answers.check(
      widget.id,
      key,
      strict: context.read<SettingsCubit>().state.strictMatching,
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final l = context.l10n;
    final isArabic = widget.language == KeyboardLanguage.arabic;
    // Hints and labels are interface text: they follow the app language,
    // unlike the book content around them.
    final textStyle = isArabic
        ? book.arabic(size: 20, height: 1.6)
        : book.urdu(size: 15, height: 1.9);

    return BlocListener<AnswersCubit, AnswersState>(
      listenWhen: (a, b) => a.answers[widget.id] != b.answers[widget.id],
      listener: (context, state) {
        // Keep in sync with external changes (e.g. "clear all answers").
        final stored = state.answers[widget.id] ?? '';
        if (stored != _controller.text && !_focusNode.hasFocus)
          _controller.text = stored;
      },
      child: BlocBuilder<KeyboardCubit, KeyboardState>(
        buildWhen: (a, b) =>
            (a.activeId == widget.id) != (b.activeId == widget.id) ||
            a.useNative != b.useNative,
        builder: (context, kb) {
          final active = kb.activeId == widget.id;
          final result = context.select<AnswersCubit, bool?>(
            (c) => c.state.checks[widget.id],
          );
          final lineColor = switch (result) {
            true => book.correct,
            false => book.incorrect,
            null => active ? book.accent : book.fieldLine,
          };
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      readOnly: !kb.useNative,
                      showCursor: true,
                      onTap: _activate,
                      minLines: 1,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: textStyle,
                      cursorColor: book.accent,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText:
                            widget.hint ??
                            (isArabic ? l.hintWriteArabic : l.hintWriteAnswer),
                        hintStyle: uiTextStyle(
                          context,
                          color: book.muted.withValues(alpha: 0.7),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                        filled: active,
                        fillColor: book.accent.withValues(alpha: 0.08),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: lineColor,
                            width: result == null ? 1 : 1.6,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: lineColor, width: 2),
                        ),
                        suffixIcon: active && kb.useNative
                            ? IconButton(
                                tooltip: l.useArabicKeyboard,
                                icon: const Icon(Icons.translate, size: 18),
                                onPressed: () => _keyboard.setUseNative(false),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
                  ),
                  if (widget.answerKey != null) ...[
                    const SizedBox(width: 4),
                    _CheckButton(result: result, onPressed: _check),
                  ],
                ],
              ),
              if (result == false && widget.answerKey != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: l.correctAnswerLabel,
                          style: uiTextStyle(
                            context,
                            size: 11,
                            color: book.muted,
                          ),
                        ),
                        TextSpan(
                          text: widget.answerKey,
                          style: book.forScript(
                            dominantScript(widget.answerKey!),
                            size: 12,
                            color: book.correct,
                          ),
                        ),
                      ],
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.result, required this.onPressed});

  final bool? result;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final (icon, color) = switch (result) {
      true => (Icons.check_circle, book.correct),
      false => (Icons.cancel, book.incorrect),
      null => (Icons.task_alt, book.muted),
    };
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: context.l10n.checkAnswer,
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
      ),
    );
  }
}
