import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/local_store.dart';

class ProgressState extends Equatable {
  const ProgressState({this.lastPageIndex, this.bookmarks = const {}});

  /// Zero-based index of the last page the reader had open.
  final int? lastPageIndex;

  /// Bookmarked page indexes.
  final Set<int> bookmarks;

  bool isBookmarked(int index) => bookmarks.contains(index);

  @override
  List<Object?> get props => [lastPageIndex, bookmarks];
}

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._store)
      : super(ProgressState(
          lastPageIndex: _store.readLastPage(),
          bookmarks: _store.readBookmarks(),
        ));

  final LocalStore _store;

  void setLastPage(int index) {
    if (state.lastPageIndex == index) return;
    emit(ProgressState(lastPageIndex: index, bookmarks: state.bookmarks));
    _store.writeLastPage(index);
  }

  void toggleBookmark(int index) {
    final next = {...state.bookmarks};
    if (!next.remove(index)) next.add(index);
    emit(ProgressState(lastPageIndex: state.lastPageIndex, bookmarks: next));
    _store.writeBookmarks(next);
  }

  void clearBookmarks() {
    emit(ProgressState(lastPageIndex: state.lastPageIndex));
    _store.writeBookmarks(const {});
  }
}
