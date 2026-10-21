import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../l10n/l10n.dart';
import 'keyboard_cubit.dart';
import 'keyboard_layouts.dart';

class KeyboardToolbar extends StatelessWidget {
  const KeyboardToolbar({super.key, required this.state});

  final KeyboardState state;

  void _handleLanguageSelection(KeyboardCubit cubit, Set<KeyboardLanguage> s) {
    if (s.first != state.language) {
      cubit.toggleLanguage();
    }
  }

  void _handleUseDeviceKeyboard(KeyboardCubit cubit) {
    cubit.setUseNative(true);
  }

  void _handleDismiss(KeyboardCubit cubit) {
    cubit.dismiss();
  }

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
            onSelectionChanged: (s) => _handleLanguageSelection(cubit, s),
          ),
          const Spacer(),
          IconButton(
            tooltip: l.useDeviceKeyboard,
            icon: const Icon(SolarIconsOutline.keyboard),
            onPressed: () => _handleUseDeviceKeyboard(cubit),
          ),
          IconButton(
            tooltip: l.closeKeyboard,
            icon: const Icon(SolarIconsOutline.altArrowDown),
            onPressed: () => _handleDismiss(cubit),
          ),
        ],
      ),
    );
  }
}
