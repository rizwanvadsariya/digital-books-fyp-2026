import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/library_cubit.dart';
import 'blocs/settings_cubit.dart';
import 'blocs/volume_session.dart';
import 'data/book_repository.dart';
import 'data/local_store.dart';
import 'data/volumes.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'models/reader_settings.dart';
import 'screens/splash_screen.dart';
import 'theme/book_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization skipped or failed: $e');
  }
  _registerFontLicenses();
  final store = LocalStore(await SharedPreferences.getInstance());
  runApp(FehmEQuranApp(store: store));
}

void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (font, file) in [
      ('Amiri', 'OFL-Amiri.txt'),
      ('Noto Nastaliq Urdu', 'OFL-NotoNastaliqUrdu.txt'),
      ('Noto Sans Math', 'OFL-NotoSansMath.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        font,
      ], await rootBundle.loadString('assets/fonts/$file'));
    }
  });
}

class FehmEQuranApp extends StatefulWidget {
  const FehmEQuranApp({super.key, required this.store, this.repositoryFor});

  final LocalStore store;

  /// Overrides how a volume's JSON is loaded (tests pre-warm repositories).
  final BookRepository Function(BookVolume volume)? repositoryFor;

  @override
  State<FehmEQuranApp> createState() => _FehmEQuranAppState();
}

class _FehmEQuranAppState extends State<FehmEQuranApp> {
  late final _library = LibraryCubit(widget.store);
  late final AppLifecycleListener _lifecycle;

  /// Opened volumes, kept so switching back is instant.
  final _sessions = <String, VolumeSession>{};

  VolumeSession _session(BookVolume volume) => _sessions.putIfAbsent(
    volume.id,
    () => VolumeSession(
      volume,
      widget.store,
      widget.repositoryFor?.call(volume) ??
          BookRepository(assetPath: volume.assetPath),
    ),
  );

  @override
  void initState() {
    super.initState();
    // Answers are saved on a short debounce; make sure nothing is lost if the
    // app is backgrounded or closed mid-typing.
    _lifecycle = AppLifecycleListener(onHide: _flush, onDetach: _flush);
  }

  void _flush() {
    for (final s in _sessions.values) {
      s.answers.flush();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    for (final s in _sessions.values) {
      s.close();
    }
    _library.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(widget.store)),
        BlocProvider.value(value: _library),
      ],
      // The open volume's cubits sit above MaterialApp so every route sees
      // them; switching volume swaps them in place.
      child: BlocBuilder<LibraryCubit, BookVolume>(
        builder: (context, volume) {
          final session = _session(volume);
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: session.book),
              BlocProvider.value(value: session.progress),
              BlocProvider.value(value: session.answers),
            ],
            child: _app(),
          );
        },
      ),
    );
  }

  Widget _app() {
    return BlocBuilder<SettingsCubit, ReaderSettings>(
      buildWhen: (a, b) =>
          a.theme != b.theme ||
          a.fontScale != b.fontScale ||
          a.language != b.language,
      builder: (context, settings) => MaterialApp(
        onGenerateTitle: (context) => context.l10n.appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(settings),
        // Only the interface follows this locale; book content is always
        // rendered in its own Urdu/Arabic, right-to-left.
        locale: settings.language.code == null
            ? null
            : Locale(settings.language.code!),
        // Urdu first so unsupported device languages fall back to Urdu.
        supportedLocales: AppLocalizations.supportedLocales.toList()
          ..sort(
            (a, b) =>
                a.languageCode == 'ur' ? -1 : (b.languageCode == 'ur' ? 1 : 0),
          ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => Theme(
          data: withUiFont(Theme.of(context), urdu: context.isUrduUi),
          child: child!,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
