import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solar_icons/solar_icons.dart';

import '../l10n/l10n.dart';
import '../widgets/home/volume_gate.dart';
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

  void _openReader(int i) => openReader(context, i);

  void _handleDestinationSelected(int i) {
    setState(() {
      _tab = i;
      _lastBackPress = null;
    });
  }

  void _handleShowContents() {
    setState(() {
      _tab = 1;
      _lastBackPress = null;
    });
  }

  void _handlePopInvoked(bool didPop, dynamic result) {
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
      final l = context.l10n;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l.pressBackAgainToExit),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final titles = [l.appTitle, l.navContents, l.navBookmarks, l.navSearch];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        appBar: _tab == 0 ? null : AppBar(title: Text(titles[_tab])),
        body: VolumeGate(
          // Keyed by volume so every tab (search index, contents…) is rebuilt
          // for the newly selected volume.
          builder: (volumeId) => IndexedStack(
            key: ValueKey(volumeId),
            index: _tab,
            children: [
              HomeScreen(
                onShowContents: _handleShowContents,
              ),
              TableOfContentsView(onOpen: _openReader),
              BookmarksScreen(onOpen: _openReader),
              SearchScreen(onOpen: _openReader),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _handleDestinationSelected,
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
