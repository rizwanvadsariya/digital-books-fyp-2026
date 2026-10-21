import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

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
        child: ReadingSettingsSheet(parentContext: context),
      ),
    );

class ReadingSettingsSheet extends StatelessWidget {
  const ReadingSettingsSheet({super.key, required this.parentContext});

  final BuildContext parentContext;

  void _handleOpenAllSettings(BuildContext sheetContext) {
    Navigator.of(sheetContext).pop();
    openSettings(parentContext);
  }

  @override
  Widget build(BuildContext sheetContext) {
    return SafeArea(
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
                icon: const Icon(SolarIconsOutline.settings),
                label: Text(sheetContext.l10n.allSettings),
                onPressed: () => _handleOpenAllSettings(sheetContext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page colour and book text size.
class ReadingControls extends StatelessWidget {
  const ReadingControls({super.key});

  void _handleThemeChanged(BuildContext context, Set<ReadingTheme> v) {
    if (v.isNotEmpty) {
      context.read<SettingsCubit>().setTheme(v.first);
    }
  }

  void _handleFontScaleChanged(BuildContext context, double value) {
    context.read<SettingsCubit>().setFontScale(value);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final s = context.watch<SettingsCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.pageColor, style: text.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<ReadingTheme>(
          segments: [
            ButtonSegment(value: ReadingTheme.paper, icon: const Icon(SolarIconsOutline.sun), label: Text(l.themePaper)),
            ButtonSegment(value: ReadingTheme.sepia, icon: const Icon(SolarIconsOutline.cup), label: Text(l.themeSepia)),
            ButtonSegment(value: ReadingTheme.dark, icon: const Icon(SolarIconsOutline.moon), label: Text(l.themeDark)),
          ],
          selected: {s.theme},
          onSelectionChanged: (v) => _handleThemeChanged(context, v),
        ),
        const SizedBox(height: 16),
        Text(l.fontSize, style: text.titleSmall),
        Row(
          children: [
            const Icon(SolarIconsOutline.text, size: 16),
            Expanded(
              child: Slider(
                value: s.fontScale,
                min: ReaderSettings.minFontScale,
                max: ReaderSettings.maxFontScale,
                divisions: 8,
                label: '${(s.fontScale * 100).round()}%',
                onChanged: (v) => _handleFontScaleChanged(context, v),
              ),
            ),
            const Icon(SolarIconsOutline.text, size: 24),
          ],
        ),
      ],
    );
  }
}

/// Practice mode and strict answer checking.
class ExerciseControls extends StatelessWidget {
  const ExerciseControls({super.key});

  void _handlePracticeModeChanged(BuildContext context, bool value) {
    context.read<SettingsCubit>().setPracticeMode(value);
  }

  void _handleStrictMatchingChanged(BuildContext context, bool value) {
    context.read<SettingsCubit>().setStrictMatching(value);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = context.watch<SettingsCubit>().state;

    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(SolarIconsOutline.eyeClosed),
          title: Text(l.practiceMode),
          subtitle: Text(l.practiceModeHint),
          value: s.practiceMode,
          onChanged: (v) => _handlePracticeModeChanged(context, v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(SolarIconsOutline.checkSquare),
          title: Text(l.strictMatching),
          subtitle: Text(l.strictMatchingHint),
          value: s.strictMatching,
          onChanged: (v) => _handleStrictMatchingChanged(context, v),
        ),
      ],
    );
  }
}
