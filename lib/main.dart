import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/answers_cubit.dart';
import 'blocs/book_cubit.dart';
import 'blocs/progress_cubit.dart';
import 'blocs/settings_cubit.dart';
import 'data/book_repository.dart';
import 'data/local_store.dart';
import 'models/reader_settings.dart';
import 'screens/splash_screen.dart';
import 'theme/book_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalStore(await SharedPreferences.getInstance());
  runApp(MuallimApp(store: store, repository: BookRepository()));
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
        buildWhen: (a, b) => a.theme != b.theme || a.fontScale != b.fontScale,
        builder: (context, settings) => MaterialApp(
          title: 'Muallim-Ul-Quran',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(settings),
          locale: const Locale('ur'),
          supportedLocales: const [Locale('ur'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
