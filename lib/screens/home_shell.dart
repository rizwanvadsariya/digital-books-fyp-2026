import 'package:flutter/material.dart';

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

  static const _titles = ['معلم القرآن', 'فہرست', 'بک مارکس', 'تلاش'];

  @override
  Widget build(BuildContext context) {
    void open(int i) => openReader(context, i);
    return Scaffold(
      appBar: _tab == 0 ? null : AppBar(title: Text(_titles[_tab])),
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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'ہوم'),
          NavigationDestination(icon: Icon(Icons.toc_outlined), selectedIcon: Icon(Icons.toc), label: 'فہرست'),
          NavigationDestination(
            icon: Icon(Icons.bookmarks_outlined),
            selectedIcon: Icon(Icons.bookmarks),
            label: 'بک مارکس',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'تلاش'),
        ],
      ),
    );
  }
}
