import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../models/reader_settings.dart';
import '../screens/settings_screen.dart';

/// Quick reading settings, opened from the reader's app bar.
Future<void> showReadingSettings(BuildContext context) => showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ReadingControls(),
                const ExerciseControls(),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(sheetContext.l10n.allSettings),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      openSettings(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

/// Page colour and book text size.
class ReadingControls extends StatelessWidget {
  const ReadingControls({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final s = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.pageColor, style: text.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<ReadingTheme>(
          segments: [
            ButtonSegment(value: ReadingTheme.paper, icon: const Icon(Icons.light_mode_outlined), label: Text(l.themePaper)),
            ButtonSegment(value: ReadingTheme.sepia, icon: const Icon(Icons.coffee_outlined), label: Text(l.themeSepia)),
            ButtonSegment(value: ReadingTheme.dark, icon: const Icon(Icons.dark_mode_outlined), label: Text(l.themeDark)),
          ],
          selected: {s.theme},
          onSelectionChanged: (v) => cubit.setTheme(v.first),
        ),
        const SizedBox(height: 16),
        Text(l.fontSize, style: text.titleSmall),
        Row(
          children: [
            const Icon(Icons.text_decrease, size: 18),
            Expanded(
              child: Slider(
                value: s.fontScale,
                min: ReaderSettings.minFontScale,
                max: ReaderSettings.maxFontScale,
                divisions: 8,
                label: '${(s.fontScale * 100).round()}%',
                onChanged: cubit.setFontScale,
              ),
            ),
            const Icon(Icons.text_increase, size: 22),
          ],
        ),
      ],
    );
  }
}

/// Practice mode and strict answer checking.
class ExerciseControls extends StatelessWidget {
  const ExerciseControls({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.visibility_off_outlined),
          title: Text(l.practiceMode),
          subtitle: Text(l.practiceModeHint),
          value: s.practiceMode,
          onChanged: cubit.setPracticeMode,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.spellcheck),
          title: Text(l.strictMatching),
          subtitle: Text(l.strictMatchingHint),
          value: s.strictMatching,
          onChanged: cubit.setStrictMatching,
        ),
      ],
    );
  }
}
