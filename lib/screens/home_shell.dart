import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

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
  DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    void open(int i) => openReader(context, i);
    final l = context.l10n;
    final titles = [l.appTitle, l.navContents, l.navBookmarks, l.navSearch];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_tab != 0) {
          setState(() {
            _tab = 0;
            _lastBackPress = null;
          });
          return;
        }
        final now = DateTime.now();
        if (_lastBackPress != null &&
            now.difference(_lastBackPress!) <= const Duration(seconds: 2)) {
          SystemNavigator.pop();
        } else {
          _lastBackPress = now;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l.pressBackAgainToExit),
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
      child: Scaffold(
        appBar: _tab == 0 ? null : AppBar(title: Text(titles[_tab])),
        body: _VolumeGate(
          // Keyed by volume so every tab (search index, contents…) is rebuilt
          // for the newly selected volume.
          builder: (volumeId) => IndexedStack(
            key: ValueKey(volumeId),
            index: _tab,
            children: [
              HomeScreen(
                onShowContents: () => setState(() {
                  _tab = 1;
                  _lastBackPress = null;
                }),
              ),
              TableOfContentsView(onOpen: open),
              BookmarksScreen(onOpen: open),
              SearchScreen(onOpen: open),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() {
            _tab = i;
            _lastBackPress = null;
          }),
          destinations: [
            NavigationDestination(
              icon: const Icon(SolarIconsOutline.home),
              selectedIcon: const Icon(SolarIconsBold.home),
              label: l.navHome,
            ),
            NavigationDestination(
              icon: const Icon(SolarIconsOutline.list_1),
              selectedIcon: const Icon(SolarIconsBold.list_1),
              label: l.navContents,
            ),
            NavigationDestination(
              icon: const Icon(SolarIconsOutline.bookmark),
              selectedIcon: const Icon(SolarIconsBold.bookmark),
              label: l.navBookmarks,
            ),
            NavigationDestination(
              icon: const Icon(SolarIconsOutline.magnifier),
              selectedIcon: const Icon(SolarIconsBold.magnifier),
              label: l.navSearch,
            ),
          ],
        ),
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
