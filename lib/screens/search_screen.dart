import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/book_cubit.dart';
import '../data/search_index.dart';
import '../l10n/l10n.dart';
import '../theme/book_theme.dart';
import '../widgets/common/script_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.onOpen});

  final ValueChanged<int> onOpen;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchIndex _index = SearchIndex(context.read<BookCubit>().state.book!);
  final _controller = TextEditingController();
  Timer? _debounce;
  List<SearchHit> _hits = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _hits = _index.search(q));
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = context.read<BookCubit>().state.book!;
    final theme = BookTheme.of(context);
    final l = context.l10n;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SearchBar(
            controller: _controller,
            hintText: l.searchHint,
            leading: const Icon(Icons.search),
            trailing: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    _onChanged('');
                  },
                ),
            ],
            onChanged: _onChanged,
          ),
        ),
        if (_controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                _hits.length >= 200 ? l.searchResultsMax : l.searchResults(_hits.length),
                style: TextStyle(color: theme.muted, fontSize: 12),
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            itemCount: _hits.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, i) {
              final hit = _hits[i];
              final page = book.pages[hit.pageIndex];
              return ListTile(
                title: ScriptText(hit.text.length > 160 ? '${hit.text.substring(0, 160)}…' : hit.text, size: 13.5),
                subtitle: Text(pageLocation(l, page), style: TextStyle(fontSize: 12, color: theme.muted)),
                trailing: page.printedPage != null ? Text(l.pageShort(page.printedPage!)) : null,
                onTap: () => widget.onOpen(hit.pageIndex),
              );
            },
          ),
        ),
      ],
    );
  }
}
