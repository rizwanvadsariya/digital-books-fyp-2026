import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/book_cubit.dart';
import '../blocs/library_cubit.dart';

import '../l10n/l10n.dart';
import 'bookmarks_screen.dart';
import 'home_screen.dart';
import 'reader_screen.dart';
import 'search_screen.dart';
import 'table_of_contents_screen.dart';

/// Bottom navigation: Home | Contents | Bookmarks | Search.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    void open(int i) => openReader(context, i);
    final l = context.l10n;
    final titles = [l.appTitle, l.navContents, l.navBookmarks, l.navSearch];
    return Scaffold(
      appBar: _tab == 0 ? null : AppBar(title: Text(titles[_tab])),
      body: _VolumeGate(
        // Keyed by volume so every tab (search index, contents…) is rebuilt
        // for the newly selected volume.
        builder: (volumeId) => IndexedStack(
          key: ValueKey(volumeId),
          index: _tab,
          children: [
            HomeScreen(onShowContents: () => setState(() => _tab = 1)),
            TableOfContentsView(onOpen: open),
            BookmarksScreen(onOpen: open),
            SearchScreen(onOpen: open),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l.navHome),
          NavigationDestination(icon: const Icon(Icons.toc_outlined), selectedIcon: const Icon(Icons.toc), label: l.navContents),
          NavigationDestination(
            icon: const Icon(Icons.bookmarks_outlined),
            selectedIcon: const Icon(Icons.bookmarks),
            label: l.navBookmarks,
          ),
          NavigationDestination(icon: const Icon(Icons.search), label: l.navSearch),
        ],
      ),
    );
  }
}

/// Shows a loader (or error) while the selected volume's JSON is parsed.
class _VolumeGate extends StatelessWidget {
  const _VolumeGate({required this.builder});

  final Widget Function(String volumeId) builder;

  @override
  Widget build(BuildContext context) {
    final volume = context.watch<LibraryCubit>().state;
    final state = context.watch<BookCubit>().state;
    return switch (state.status) {
      BookStatus.ready => builder(volume.id),
      BookStatus.loading => const Center(child: CircularProgressIndicator()),
      BookStatus.failure => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.loadFailed),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => context.read<BookCubit>().load(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    };
  }
}
