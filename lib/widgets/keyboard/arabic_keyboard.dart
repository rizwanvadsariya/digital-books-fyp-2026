import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../l10n/l10n.dart';
import '../../theme/book_theme.dart';
import 'keyboard_cubit.dart';
import 'keyboard_layouts.dart';

/// Docked on-screen Arabic/Urdu keyboard with a dedicated harakat row.
///
/// Shown by the reader whenever an answer field is active and the learner
/// hasn't switched to the device keyboard.
class ArabicKeyboard extends StatelessWidget {
  const ArabicKeyboard({super.key});

  static const _columns = 11.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<KeyboardCubit, KeyboardState>(
      builder: (context, state) {
        final cubit = context.read<KeyboardCubit>();
        final rows = state.symbols ? symbolRows(state.language) : letterRows(state.language);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Material(
            color: scheme.surfaceContainerHighest,
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final unit = constraints.maxWidth / _columns;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Toolbar(state: state),
                        _row([
                          for (final h in harakatKeys)
                            _KeySpec.haraka(h, name: harakaName(context.l10n, h), onTap: () => cubit.insert(h)),
                        ], unit),
                        for (final row in rows)
                          _row([for (final k in row) _KeySpec.letter(k, onTap: () => cubit.insert(k))], unit),
                        _row([
                          _KeySpec(
                            label: state.symbols ? (state.language == KeyboardLanguage.urdu ? 'اب' : 'أب') : '١٢٣',
                            flex: 1.5,
                            kind: _KeyKind.function,
                            onTap: cubit.toggleSymbols,
                          ),
                          _KeySpec.letter('،', onTap: () => cubit.insert('،')),
                          _KeySpec(
                            label: state.language == KeyboardLanguage.urdu
                                ? context.l10n.keyboardUrdu
                                : context.l10n.keyboardArabic,
                            flex: 4.5,
                            kind: _KeyKind.space,
                            onTap: () => cubit.insert(' '),
                          ),
                          _KeySpec.letter(
                            state.language == KeyboardLanguage.urdu ? '۔' : '.',
                            onTap: () => cubit.insert(state.language == KeyboardLanguage.urdu ? '۔' : '.'),
                          ),
                          _KeySpec(
                            icon: SolarIconsOutline.backspace,
                            flex: 1.5,
                            kind: _KeyKind.function,
                            onTap: cubit.backspace,
                            repeat: true,
                          ),
                          _KeySpec(
                            icon: SolarIconsOutline.checkSquare,
                            flex: 1.5,
                            kind: _KeyKind.primary,
                            onTap: cubit.dismiss,
                          ),
                        ], unit),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _row(List<_KeySpec> keys, double unit) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final k in keys) SizedBox(width: unit * k.flex, height: 44, child: _Key(spec: k)),
          ],
        ),
      );
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.state});

  final KeyboardState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KeyboardCubit>();
    final l = context.l10n;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SegmentedButton<KeyboardLanguage>(
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            segments: [
              ButtonSegment(value: KeyboardLanguage.arabic, label: Text(l.keyboardArabic)),
              ButtonSegment(value: KeyboardLanguage.urdu, label: Text(l.keyboardUrdu)),
            ],
            selected: {state.language},
            onSelectionChanged: (s) {
              if (s.first != state.language) cubit.toggleLanguage();
            },
          ),
          const Spacer(),
          IconButton(
            tooltip: l.useDeviceKeyboard,
            icon: const Icon(SolarIconsOutline.keyboard),
            onPressed: () => cubit.setUseNative(true),
          ),
          IconButton(
            tooltip: l.closeKeyboard,
            icon: const Icon(SolarIconsOutline.altArrowDown),
            onPressed: cubit.dismiss,
          ),
        ],
      ),
    );
  }
}

enum _KeyKind { letter, haraka, function, space, primary }

class _KeySpec {
  const _KeySpec({
    this.label,
    this.icon,
    this.flex = 1,
    this.kind = _KeyKind.letter,
    required this.onTap,
    this.repeat = false,
    this.tooltip,
  });

  factory _KeySpec.letter(String ch, {required VoidCallback onTap}) =>
      _KeySpec(label: ch, flex: ch.length > 1 && ch != 'لا' ? 1.5 : 1, onTap: onTap);

  /// Harakat are drawn on a dotted circle (U+25CC) so the mark is visible.
  factory _KeySpec.haraka(String mark, {required String name, required VoidCallback onTap}) => _KeySpec(
        label: mark == 'ـ' ? 'ـ' : '◌$mark',
        kind: _KeyKind.haraka,
        onTap: onTap,
        tooltip: name,
      );

  final String? label;
  final IconData? icon;
  final double flex;
  final _KeyKind kind;
  final VoidCallback onTap;
  final bool repeat;
  final String? tooltip;
}

class _Key extends StatefulWidget {
  const _Key({required this.spec});

  final _KeySpec spec;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  Timer? _repeat;

  void _press() {
    HapticFeedback.selectionClick();
    widget.spec.onTap();
  }

  @override
  void dispose() {
    _repeat?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final scheme = Theme.of(context).colorScheme;
    final book = BookTheme.of(context);
    final (bg, fg) = switch (spec.kind) {
      _KeyKind.letter || _KeyKind.space => (scheme.surface, scheme.onSurface),
      _KeyKind.haraka => (book.boxTint, book.red),
      _KeyKind.function => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _KeyKind.primary => (scheme.primary, scheme.onPrimary),
    };
    final Widget content = spec.icon != null
        ? Icon(spec.icon, size: 20, color: fg)
        : Text(
            spec.label ?? '',
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              // The space bar shows the layout's name (interface text).
              fontFamily: spec.kind == _KeyKind.space ? null : arabicFont,
              fontSize: switch (spec.kind) {
                _KeyKind.haraka => 24,
                _KeyKind.space || _KeyKind.function => 14,
                _ => 21,
              },
              height: 1.2,
              color: spec.kind == _KeyKind.space ? scheme.onSurfaceVariant : fg,
            ),
          );

    Widget key = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: bg,
        elevation: 1,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: _press,
          onLongPress: spec.repeat
              ? () {
                  _repeat?.cancel();
                  _repeat = Timer.periodic(const Duration(milliseconds: 70), (_) => _press());
                }
              : null,
          child: Center(child: content),
        ),
      ),
    );
    if (spec.repeat) {
      key = Listener(
        onPointerUp: (_) => _repeat?.cancel(),
        onPointerCancel: (_) => _repeat?.cancel(),
        child: key,
      );
    }
    if (spec.tooltip != null) key = Tooltip(message: spec.tooltip!, child: key);
    return key;
  }
}
