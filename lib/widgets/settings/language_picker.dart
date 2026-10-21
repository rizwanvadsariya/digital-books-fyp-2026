import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/settings_cubit.dart';
import '../../l10n/l10n.dart';
import '../../models/reader_settings.dart';
import '../../theme/book_theme.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  void _handleLanguageChanged(BuildContext context, AppLanguage? v) {
    if (v != null) {
      context.read<SettingsCubit>().setLanguage(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = context.select<SettingsCubit, AppLanguage>(
      (c) => c.state.language,
    );
    // Each language is named in its own script so it can be found whatever
    // the current interface language is.
    final options = [
      (AppLanguage.system, l.languageSystem, null),
      (AppLanguage.urdu, 'اردو', 'Urdu'),
      (AppLanguage.english, 'English', 'انگریزی'),
    ];
    return RadioGroup<AppLanguage>(
      groupValue: current,
      onChanged: (v) => _handleLanguageChanged(context, v),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.languageHint,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          for (final (value, label, subtitle) in options)
            RadioListTile<AppLanguage>(
              contentPadding: EdgeInsets.zero,
              value: value,
              title: Text(
                label,
                style: TextStyle(
                  fontFamily: value == AppLanguage.urdu ? urduFont : null,
                ),
              ),
              subtitle: subtitle != null ? Text(subtitle) : null,
            ),
        ],
      ),
    );
  }
}
