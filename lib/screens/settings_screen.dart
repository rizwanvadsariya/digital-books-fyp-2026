import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/answers_cubit.dart';
import '../blocs/progress_cubit.dart';
import '../blocs/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../models/reader_settings.dart';
import '../theme/book_theme.dart';
import '../widgets/common/script_text.dart';
import '../widgets/reading_settings_sheet.dart';

Future<void> openSettings(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Section(title: l.sectionLanguage, icon: Icons.translate, child: const _LanguagePicker()),
          _Section(
            title: l.sectionReading,
            icon: Icons.menu_book_outlined,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [ReadingControls(), _BookPreview()],
            ),
          ),
          _Section(title: l.sectionExercises, icon: Icons.edit_note, child: const ExerciseControls()),
          _Section(title: l.sectionData, icon: Icons.storage_outlined, child: const _DataControls()),
          _Section(title: l.sectionAbout, icon: Icons.info_outline, child: const _About()),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = context.select<SettingsCubit, AppLanguage>((c) => c.state.language);
    // Each language is named in its own script so it can be found whatever
    // the current interface language is.
    final options = [
      (AppLanguage.system, l.languageSystem, null),
      (AppLanguage.urdu, 'اردو', 'Urdu'),
      (AppLanguage.english, 'English', 'انگریزی'),
    ];
    return RadioGroup<AppLanguage>(
      groupValue: current,
      onChanged: (v) {
        if (v != null) context.read<SettingsCubit>().setLanguage(v);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.languageHint, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          for (final (value, label, subtitle) in options)
            RadioListTile<AppLanguage>(
              contentPadding: EdgeInsets.zero,
              value: value,
              title: Text(
                label,
                style: TextStyle(fontFamily: value == AppLanguage.urdu ? urduFont : null),
              ),
              subtitle: subtitle != null ? Text(subtitle) : null,
            ),
        ],
      ),
    );
  }
}

/// A snippet of real book text so the reader sees the size and colour
/// settings applied. It is book content, so it never changes language.
class _BookPreview extends StatelessWidget {
  const _BookPreview();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final book = BookTheme.forSettings(settings);
    return Theme(
      data: Theme.of(context).copyWith(extensions: [book]),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: book.paper,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: book.border.withValues(alpha: 0.4)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScriptText('وَاللَّهُ غَفُورٌ رَّحِيمٌ', size: 16, align: TextAlign.center),
              ScriptText('اور اللہ بخشنے والا، رحم کرنے والا ہے', size: 14, align: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataControls extends StatelessWidget {
  const _DataControls();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final answers = context.select<AnswersCubit, int>((c) => c.state.answers.length);
    final bookmarks = context.select<ProgressCubit, int>((c) => c.state.bookmarks.length);
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.edit_note),
          title: Text(l.deleteAllAnswers),
          subtitle: Text(l.answersSaved(answers)),
          enabled: answers > 0,
          onTap: () async {
            if (await _confirm(context, l.deleteAllAnswersQuestion, l.delete) && context.mounted) {
              context.read<AnswersCubit>().clearAll();
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.bookmark_remove_outlined),
          title: Text(l.removeAllBookmarks),
          subtitle: Text(l.bookmarksSaved(bookmarks)),
          enabled: bookmarks > 0,
          onTap: () async {
            if (await _confirm(context, l.removeAllBookmarksQuestion, l.remove) && context.mounted) {
              context.read<ProgressCubit>().clearBookmarks();
            }
          },
        ),
      ],
    );
  }
}

Future<bool> _confirm(BuildContext context, String title, String action) async {
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(l.cannotBeUndone),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
      ],
    ),
  );
  return ok == true;
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.aboutBook),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            icon: const Icon(Icons.description_outlined),
            label: Text(l.licenses),
            onPressed: () => showLicensePage(context: context, applicationName: l.appTitle),
          ),
        ),
      ],
    );
  }
}
