import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muallim_ul_quran/blocs/answers_cubit.dart';
import 'package:muallim_ul_quran/blocs/progress_cubit.dart';
import 'package:muallim_ul_quran/blocs/settings_cubit.dart';
import 'package:muallim_ul_quran/data/local_store.dart';
import 'package:muallim_ul_quran/models/book.dart';
import 'package:muallim_ul_quran/models/reader_settings.dart';
import 'package:muallim_ul_quran/theme/book_theme.dart';
import 'package:muallim_ul_quran/widgets/keyboard/keyboard_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

Book? _book;

/// The real book data, parsed once per test run.
Book loadBook() => _book ??= Book.fromJson(
      jsonDecode(File('assets/data/muallim_ul_quran_vol1_full.json').readAsStringSync()) as Map<String, dynamic>,
    );

Future<LocalStore> freshStore([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return LocalStore(await SharedPreferences.getInstance());
}

/// Wraps [child] in the providers and theme the reader widgets expect.
Widget harness(
  Widget child, {
  required LocalStore store,
  AnswersCubit? answers,
  KeyboardCubit? keyboard,
  SettingsCubit? settings,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => settings ?? SettingsCubit(store)),
      BlocProvider(create: (_) => ProgressCubit(store)),
      BlocProvider(create: (_) => answers ?? AnswersCubit(store)),
      BlocProvider(create: (_) => keyboard ?? KeyboardCubit()),
    ],
    child: MaterialApp(
      theme: buildAppTheme(const ReaderSettings()),
      home: Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: child)),
    ),
  );
}
