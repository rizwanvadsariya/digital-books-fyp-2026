import '../data/book_repository.dart';
import '../data/local_store.dart';
import '../data/volumes.dart';
import 'answers_cubit.dart';
import 'book_cubit.dart';
import 'progress_cubit.dart';

/// The per-volume state: its parsed book, reading progress/bookmarks and
/// answers, each persisted under the volume's own storage namespace.
class VolumeSession {
  VolumeSession(BookVolume volume, LocalStore store, BookRepository repository)
      : book = BookCubit(repository)..load(),
        progress = ProgressCubit(store.forVolume(volume.storageNamespace)),
        answers = AnswersCubit(store.forVolume(volume.storageNamespace));

  final BookCubit book;
  final ProgressCubit progress;
  final AnswersCubit answers;

  Future<void> close() async {
    await answers.close();
    await progress.close();
    await book.close();
  }
}
