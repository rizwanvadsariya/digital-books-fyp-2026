import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/answers_cubit.dart';
import 'blocs/book_cubit.dart';
import 'blocs/progress_cubit.dart';
import 'blocs/settings_cubit.dart';
import 'data/book_repository.dart';
import 'data/local_store.dart';
import 'l10n/l10n.dart';
import 'models/reader_settings.dart';
import 'screens/splash_screen.dart';
import 'theme/book_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  final store = LocalStore(await SharedPreferences.getInstance());
  runApp(MuallimApp(store: store, repository: BookRepository()));
}

void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (font, file) in [('Amiri', 'OFL-Amiri.txt'), ('Noto Nastaliq Urdu', 'OFL-NotoNastaliqUrdu.txt')]) {
      yield LicenseEntryWithLineBreaks([font], await rootBundle.loadString('assets/fonts/$file'));
    }
  });
}

class MuallimApp extends StatefulWidget {
  const MuallimApp({super.key, required this.store, required this.repository});

  final LocalStore store;
  final BookRepository repository;

  @override
  State<MuallimApp> createState() => _MuallimAppState();
}

class _MuallimAppState extends State<MuallimApp> {
  late final _answers = AnswersCubit(widget.store);
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Answers are saved on a short debounce; make sure nothing is lost if the
    // app is backgrounded or closed mid-typing.
    _lifecycle = AppLifecycleListener(onHide: _answers.flush, onDetach: _answers.flush);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BookCubit(widget.repository)..load()),
        BlocProvider(create: (_) => SettingsCubit(widget.store)),
        BlocProvider(create: (_) => ProgressCubit(widget.store)),
        BlocProvider.value(value: _answers),
      ],
      child: BlocBuilder<SettingsCubit, ReaderSettings>(
        buildWhen: (a, b) => a.theme != b.theme || a.fontScale != b.fontScale || a.language != b.language,
        builder: (context, settings) => MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(settings),
          // Only the interface follows this locale; book content is always
          // rendered in its own Urdu/Arabic, right-to-left.
          locale: settings.language.code == null ? null : Locale(settings.language.code!),
          // Urdu first so unsupported device languages fall back to Urdu.
          supportedLocales: AppLocalizations.supportedLocales.toList()
            ..sort((a, b) => a.languageCode == 'ur' ? -1 : (b.languageCode == 'ur' ? 1 : 0)),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => Theme(
            data: withUiFont(Theme.of(context), urdu: context.isUrduUi),
            child: child!,
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
