import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';

import '../blocs/book_cubit.dart';
import '../blocs/progress_cubit.dart';
import '../core/navigation/route_enums.dart';
import '../l10n/l10n.dart';
import '../models/book.dart';
import '../widgets/book_flip_view.dart';
import '../widgets/book_page.dart';
import '../widgets/keyboard/arabic_keyboard.dart';
import '../widgets/keyboard/keyboard_cubit.dart';
import '../widgets/reader/page_scrubber.dart';
import '../widgets/reader_navigation.dart';
import '../widgets/reading_settings_sheet.dart';

Future<void> openReader(BuildContext context, int pageIndex) =>
    context.pushNamed(
      AppRoutes.reader.name,
      pathParameters: {'pageIndex': '$pageIndex'},
    );

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KeyboardCubit(),
      child: ReaderView(
        book: context.read<BookCubit>().state.book!,
        initialIndex: initialIndex,
      ),
    );
  }
}

class ReaderView extends StatefulWidget {
  const ReaderView({super.key, required this.book, required this.initialIndex});

  final Book book;
  final int initialIndex;

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  late int _index = widget.initialIndex.clamp(0, widget.book.length - 1);
  late final PageController _controller = PageController(
    initialPage: BookFlipView.positionForIndex(_index, widget.book.length),
  );

  Book get book => widget.book;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ProgressCubit>().setLastPage(_index));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_index != index) {
      HapticFeedback.selectionClick();
    }
    setState(() => _index = index);
    context.read<KeyboardCubit>().dismiss();
    context.read<ProgressCubit>().setLastPage(index);
  }

  void goTo(int index) {
    index = index.clamp(0, book.length - 1);
    if (index == _index) return;
    HapticFeedback.selectionClick();
    final diff = (index - _index).abs();
    final target = BookFlipView.positionForIndex(index, book.length);
    if (diff == 1) {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } else if (diff == 2) {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 440),
        curve: Curves.easeOutCubic,
      );
    } else {
      _controller.jumpToPage(target);
    }
  }

  Future<void> _openContents() async {
    final index = await context.pushNamed<int>(
      AppRoutes.contents.name,
      extra: _index,
    );
    if (index != null) goTo(index);
  }

  void _handlePopInvoked(bool didPop, dynamic result) {
    if (!didPop) {
      context.read<KeyboardCubit>().dismiss();
    }
  }

  void _handleToggleBookmark() {
    context.read<ProgressCubit>().toggleBookmark(_index);
  }

  void _handleShowReadingSettings() {
    showReadingSettings(context);
  }

  Widget _buildPage(BuildContext context, int i) =>
      BookPageView(book: book, page: book.pages[i]);

  @override
  Widget build(BuildContext context) {
    final page = book.pages[_index];
    final l = context.l10n;
    final bookmarked = context.select<ProgressCubit, bool>((c) => c.state.isBookmarked(_index));
    final keyboardVisible = context.select<KeyboardCubit, bool>((c) => c.state.customVisible);

    return PopScope(
      canPop: !keyboardVisible,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(fit: BoxFit.scaleDown, child: Text(pageLocation(l, page))),
          actions: [
            IconButton(
              tooltip: bookmarked ? l.removeBookmark : l.addBookmark,
              icon: Icon(bookmarked ? SolarIconsBold.bookmark : SolarIconsOutline.bookmark),
              onPressed: _handleToggleBookmark,
            ),
            IconButton(tooltip: l.navContents, icon: const Icon(SolarIconsOutline.list_1), onPressed: _openContents),
            IconButton(
              tooltip: l.readingSettings,
              icon: const Icon(SolarIconsOutline.text),
              onPressed: _handleShowReadingSettings,
            ),
          ],
        ),
        body: ReaderNavigation(
          book: book,
          goToIndex: goTo,
          child: Column(
            children: [
              Expanded(
                child: BookFlipView(
                  controller: _controller,
                  itemCount: book.length,
                  onPageChanged: _onPageChanged,
                  pageBuilder: _buildPage,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => SizeTransition(sizeFactor: anim, child: child),
                child: keyboardVisible
                    ? const ArabicKeyboard()
                    : PageScrubber(index: _index, total: book.length, onChanged: goTo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
