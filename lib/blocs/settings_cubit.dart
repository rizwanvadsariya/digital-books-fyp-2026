import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/local_store.dart';
import '../models/reader_settings.dart';

class SettingsCubit extends Cubit<ReaderSettings> {
  SettingsCubit(this._store) : super(_store.readSettings());

  final LocalStore _store;

  void setTheme(ReadingTheme theme) => _update(state.copyWith(theme: theme));

  void setFontScale(double scale) => _update(state.copyWith(
        fontScale: scale.clamp(ReaderSettings.minFontScale, ReaderSettings.maxFontScale),
      ));

  void setStrictMatching(bool strict) => _update(state.copyWith(strictMatching: strict));

  void setPracticeMode(bool on) => _update(state.copyWith(practiceMode: on));

  void _update(ReaderSettings next) {
    emit(next);
    _store.writeSettings(next);
  }
}
