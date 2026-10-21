import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../l10n/l10n.dart';
import 'keyboard_cubit.dart';
import 'keyboard_key.dart';
import 'keyboard_layouts.dart';
import 'keyboard_toolbar.dart';

/// Docked on-screen Arabic/Urdu keyboard with a dedicated harakat row.
///
/// Shown by the reader whenever an answer field is active and the learner
/// hasn't switched to the device keyboard.
class ArabicKeyboard extends StatelessWidget {
  const ArabicKeyboard({super.key});

  static const _columns = 11.0;

  void _handleInsert(KeyboardCubit cubit, String text) {
    cubit.insert(text);
  }

  Widget _row(List<KeySpec> keys, double unit) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final k in keys) SizedBox(width: unit * k.flex, height: 44, child: KeyboardKeyWidget(spec: k)),
          ],
        ),
      );

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
                        KeyboardToolbar(state: state),
                        _row([
                          for (final h in harakatKeys)
                            KeySpec.haraka(h, name: harakaName(context.l10n, h), onTap: () => _handleInsert(cubit, h)),
                        ], unit),
                        for (final row in rows)
                          _row([for (final k in row) KeySpec.letter(k, onTap: () => _handleInsert(cubit, k))], unit),
                        _row([
                          KeySpec(
                            label: state.symbols ? (state.language == KeyboardLanguage.urdu ? 'اب' : 'أب') : '١٢٣',
                            flex: 1.5,
                            kind: KeyKind.function,
                            onTap: cubit.toggleSymbols,
                          ),
                          KeySpec.letter('،', onTap: () => _handleInsert(cubit, '،')),
                          KeySpec(
                            label: state.language == KeyboardLanguage.urdu
                                ? context.l10n.keyboardUrdu
                                : context.l10n.keyboardArabic,
                            flex: 4.5,
                            kind: KeyKind.space,
                            onTap: () => _handleInsert(cubit, ' '),
                          ),
                          KeySpec.letter(
                            state.language == KeyboardLanguage.urdu ? '۔' : '.',
                            onTap: () => _handleInsert(cubit, state.language == KeyboardLanguage.urdu ? '۔' : '.'),
                          ),
                          KeySpec(
                            icon: SolarIconsOutline.backspace,
                            flex: 1.5,
                            kind: KeyKind.function,
                            onTap: cubit.backspace,
                            repeat: true,
                          ),
                          KeySpec(
                            icon: SolarIconsOutline.checkSquare,
                            flex: 1.5,
                            kind: KeyKind.primary,
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
}
