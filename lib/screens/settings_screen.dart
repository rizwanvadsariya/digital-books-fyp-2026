import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';

import '../blocs/library_cubit.dart';
import '../core/navigation/route_enums.dart';
import '../l10n/l10n.dart';
import '../widgets/reading_settings_sheet.dart';
import '../widgets/settings/about_view.dart';
import '../widgets/settings/book_preview.dart';
import '../widgets/settings/data_controls.dart';
import '../widgets/settings/language_picker.dart';
import '../widgets/settings/settings_section.dart';

Future<void> openSettings(BuildContext context) =>
    context.pushNamed(AppRoutes.settings.name);

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
          SettingsSection(
            title: l.sectionLanguage,
            icon: SolarIconsOutline.global,
            child: const LanguagePicker(),
          ),
          SettingsSection(
            title: l.sectionReading,
            icon: SolarIconsOutline.book2,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [ReadingControls(), BookPreview()],
            ),
          ),
          SettingsSection(
            title: l.sectionExercises,
            icon: SolarIconsOutline.notes,
            child: const ExerciseControls(),
          ),
          SettingsSection(
            title: l.sectionDataForVolume(
              context.watch<LibraryCubit>().state.number,
            ),
            icon: SolarIconsOutline.database,
            child: const DataControls(),
          ),
          SettingsSection(
            title: l.sectionAbout,
            icon: SolarIconsOutline.infoCircle,
            child: const AboutView(),
          ),
        ],
      ),
    );
  }
}
