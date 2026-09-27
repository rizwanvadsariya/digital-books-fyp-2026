import 'package:flutter/material.dart';

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
      body: IndexedStack(
        index: _tab,
        children: [
          HomeScreen(onShowContents: () => setState(() => _tab = 1)),
          TableOfContentsView(onOpen: open),
          BookmarksScreen(onOpen: open),
          SearchScreen(onOpen: open),
        ],
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
