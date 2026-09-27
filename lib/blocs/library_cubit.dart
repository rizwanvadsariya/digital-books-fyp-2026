import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/local_store.dart';
import '../data/volumes.dart';

/// Which volume of the book is open. Persisted across launches.
class LibraryCubit extends Cubit<BookVolume> {
  LibraryCubit(this._store) : super(volumeById(_store.readSelectedVolume()));

  final LocalStore _store;

  void select(BookVolume volume) {
    if (volume.id == state.id) return;
    emit(volume);
    _store.writeSelectedVolume(volume.id);
  }
}
