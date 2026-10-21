import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../blocs/book_cubit.dart';
import '../data/search_index.dart';
import '../l10n/l10n.dart';
import '../models/book.dart';
import '../theme/book_theme.dart';
import '../widgets/search/search_hit_tile.dart';
import '../widgets/search/search_no_results_view.dart';
import '../widgets/search/search_prompt_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.onOpen});

  final ValueChanged<int> onOpen;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchIndex _index = SearchIndex(
    context.read<BookCubit>().state.book!,
  );
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<SearchHit> _hits = const [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() {
        _hits = const [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        _performSearch(q);
      }
    });
  }

  void _performSearch(String q) {
    _debounce?.cancel();
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _hits = const [];
        _isSearching = false;
      });
      return;
    }
    setState(() {
      _hits = _index.search(query);
      _isSearching = false;
    });
  }

  void _applySuggestion(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    _performSearch(text);
  }

  void _clear() {
    _controller.clear();
    _performSearch('');
  }

  void _handleSubmitted(String q) {
    _performSearch(q);
    _focusNode.unfocus();
  }

  void _handleHitTap(int pageIndex) {
    widget.onOpen(pageIndex);
  }

  Widget _buildBody(Book book, AppLocalizations l, String query) {
    if (query.isEmpty) {
      return SearchPromptView(onSelectSuggestion: _applySuggestion);
    }
    if (_hits.isEmpty && !_isSearching) {
      return SearchNoResultsView(query: query);
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _hits.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, i) {
        final hit = _hits[i];
        final page = book.pages[hit.pageIndex];
        return SearchHitTile(
          hit: hit,
          page: page,
          query: query,
          onTap: () => _handleHitTap(hit.pageIndex),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = context.read<BookCubit>().state.book!;
    final bookTheme = BookTheme.of(context);
    final l = context.l10n;
    final query = _controller.text.trim();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SearchBar(
            controller: _controller,
            focusNode: _focusNode,
            hintText: l.searchHint,
            hintStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: 14.5,
                color: bookTheme.muted.withValues(alpha: 0.8),
                fontFamilyFallback: const [urduFont, arabicFont, symbolsFont],
              ),
            ),
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: 15.5,
                color: bookTheme.ink,
                fontFamilyFallback: const [urduFont, arabicFont, symbolsFont],
                height: 1.35,
              ),
            ),
            backgroundColor: WidgetStatePropertyAll(
              bookTheme.paperShade.withValues(alpha: 0.35),
            ),
            elevation: const WidgetStatePropertyAll(0),
            side: WidgetStatePropertyAll(
              BorderSide(
                color: _focusNode.hasFocus
                    ? bookTheme.accent
                    : bookTheme.border.withValues(alpha: 0.4),
                width: _focusNode.hasFocus ? 1.5 : 1.0,
              ),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 14),
            ),
            leading: Icon(
              SolarIconsOutline.magnifier,
              color: _focusNode.hasFocus ? bookTheme.accent : bookTheme.muted,
              size: 22,
            ),
            trailing: [
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: bookTheme.accent,
                    ),
                  ),
                )
              else if (_controller.text.isNotEmpty)
                IconButton(
                  tooltip: l.clearSearch,
                  icon: Icon(SolarIconsBold.closeCircle, color: bookTheme.muted, size: 20),
                  onPressed: _clear,
                ),
            ],
            onChanged: _onChanged,
            onSubmitted: _handleSubmitted,
            textInputAction: TextInputAction.search,
          ),
        ),
        if (query.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                _hits.length >= 200
                    ? l.searchResultsMax
                    : l.searchResults(_hits.length),
                style: TextStyle(
                  color: bookTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Expanded(child: _buildBody(book, l, query)),
      ],
    );
  }
}
