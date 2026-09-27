import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/book_repository.dart';
import '../models/book.dart';

enum BookStatus { loading, ready, failure }

class BookState extends Equatable {
  const BookState({this.status = BookStatus.loading, this.book, this.error});

  final BookStatus status;
  final Book? book;
  final String? error;

  @override
  List<Object?> get props => [status, book, error];
}

class BookCubit extends Cubit<BookState> {
  BookCubit(this._repository) : super(const BookState());

  final BookRepository _repository;

  Future<void> load() async {
    emit(const BookState());
    try {
      final book = await _repository.load();
      emit(BookState(status: BookStatus.ready, book: book));
    } catch (e) {
      emit(BookState(status: BookStatus.failure, error: '$e'));
    }
  }
}
