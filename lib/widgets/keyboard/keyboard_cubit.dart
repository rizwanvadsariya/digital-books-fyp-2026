import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'keyboard_layouts.dart';
import 'text_editing.dart';

class KeyboardState extends Equatable {
  const KeyboardState({
    this.activeId,
    this.language = KeyboardLanguage.arabic,
    this.symbols = false,
    this.useNative = false,
  });

  /// Answer ID of the field currently being edited, if any.
  final String? activeId;
  final KeyboardLanguage language;

  /// Showing the digits/punctuation layer instead of letters.
  final bool symbols;

  /// The learner chose the device's own keyboard instead of ours.
  final bool useNative;

  bool get customVisible => activeId != null && !useNative;

  KeyboardState copyWith({
    String? activeId,
    bool clearActive = false,
    KeyboardLanguage? language,
    bool? symbols,
    bool? useNative,
  }) =>
      KeyboardState(
        activeId: clearActive ? null : (activeId ?? this.activeId),
        language: language ?? this.language,
        symbols: symbols ?? this.symbols,
        useNative: useNative ?? this.useNative,
      );

  @override
  List<Object?> get props => [activeId, language, symbols, useNative];
}

/// Routes key presses from the embedded keyboard to whichever answer field
/// is active. Fields register their controller via [attach].
class KeyboardCubit extends Cubit<KeyboardState> {
  KeyboardCubit() : super(const KeyboardState());

  TextEditingController? _controller;
  FocusNode? _focusNode;

  void attach(
    String id,
    TextEditingController controller,
    FocusNode focusNode, {
    KeyboardLanguage? preferred,
  }) {
    _controller = controller;
    _focusNode = focusNode;
    emit(state.copyWith(
      activeId: id,
      language: preferred ?? state.language,
      symbols: false,
    ));
  }

  /// Called by a field when it's disposed or loses focus to another field.
  void detach(String id) {
    if (state.activeId != id) return;
    _controller = null;
    _focusNode = null;
    emit(state.copyWith(clearActive: true));
  }

  void dismiss() {
    _focusNode?.unfocus();
    _controller = null;
    _focusNode = null;
    emit(state.copyWith(clearActive: true));
  }

  void insert(String text) => _edit((v) => insertText(v, text));

  void backspace() => _edit(deleteBackward);

  void toggleLanguage() => emit(state.copyWith(
        language: state.language == KeyboardLanguage.arabic ? KeyboardLanguage.urdu : KeyboardLanguage.arabic,
        symbols: false,
      ));

  void toggleSymbols() => emit(state.copyWith(symbols: !state.symbols));

  /// Switches between our keyboard and the OS keyboard. The active field
  /// rebuilds as editable (native) or read-only (custom) and re-requests
  /// focus so the right keyboard appears.
  void setUseNative(bool native) {
    emit(state.copyWith(useNative: native));
    final node = _focusNode;
    if (node != null) {
      node.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) => node.requestFocus());
    }
  }

  void _edit(TextEditingValue Function(TextEditingValue) change) {
    final c = _controller;
    if (c == null) return;
    c.value = change(c.value);
  }
}
