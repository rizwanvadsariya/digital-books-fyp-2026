import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/settings_cubit.dart';
import '../models/reader_settings.dart';

Future<void> showReadingSettings(BuildContext context) => showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: const ReadingSettingsSheet(),
      ),
    );

class ReadingSettingsSheet extends StatelessWidget {
  const ReadingSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return BlocBuilder<SettingsCubit, ReaderSettings>(
      builder: (context, s) {
        final cubit = context.read<SettingsCubit>();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('صفحے کا رنگ', style: text.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<ReadingTheme>(
                  segments: const [
                    ButtonSegment(value: ReadingTheme.paper, icon: Icon(Icons.light_mode_outlined), label: Text('کاغذ')),
                    ButtonSegment(value: ReadingTheme.sepia, icon: Icon(Icons.coffee_outlined), label: Text('سیپیا')),
                    ButtonSegment(value: ReadingTheme.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('رات')),
                  ],
                  selected: {s.theme},
                  onSelectionChanged: (v) => cubit.setTheme(v.first),
                ),
                const SizedBox(height: 16),
                Text('حروف کا سائز', style: text.titleSmall),
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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('مشق موڈ'),
                  subtitle: const Text('کتاب میں لکھے معانی اور ترجمے چھپا کر خود جانچیں'),
                  value: s.practiceMode,
                  onChanged: cubit.setPracticeMode,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('سخت جانچ'),
                  subtitle: const Text('جواب چیک کرتے وقت اعراب (زبر، زیر، پیش) بھی ملائیں'),
                  value: s.strictMatching,
                  onChanged: cubit.setStrictMatching,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
