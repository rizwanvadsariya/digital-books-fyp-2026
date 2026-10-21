import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../blocs/book_cubit.dart';
import '../data/search_index.dart';
import '../l10n/l10n.dart';
import '../models/book.dart';
import '../theme/book_theme.dart';
import '../utils/arabic_text.dart';
import '../widgets/common/script_text.dart';

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
            onSubmitted: (q) {
              _performSearch(q);
              _focusNode.unfocus();
            },
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

  Widget _buildBody(Book book, AppLocalizations l, String query) {
    if (query.isEmpty) {
      return _SearchPromptView(onSelectSuggestion: _applySuggestion);
    }
    if (_hits.isEmpty && !_isSearching) {
      return _SearchNoResultsView(query: query);
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _hits.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, i) {
        final hit = _hits[i];
        final page = book.pages[hit.pageIndex];
        return _SearchHitTile(
          hit: hit,
          page: page,
          query: query,
          onTap: () => widget.onOpen(hit.pageIndex),
        );
      },
    );
  }
}

class _SearchHitTile extends StatelessWidget {
  const _SearchHitTile({
    required this.hit,
    required this.page,
    required this.query,
    required this.onTap,
  });

  final SearchHit hit;
  final BookPage page;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    final l = context.l10n;
    final truncatedText = hit.text.characters.length > 160
        ? '${hit.text.characters.take(160)}…'
        : hit.text;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: _HighlightedText(text: truncatedText, query: query),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          pageLocation(l, page),
          style: TextStyle(fontSize: 12, color: theme.muted),
        ),
      ),
      trailing: page.printedPage != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.paperShade.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.pageShort(page.printedPage!),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.muted,
                  fontFamily: arabicFont,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({required this.text, required this.query});

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    final normQuery = normalizeForSearch(query);
    if (normQuery.isEmpty) {
      return ScriptText(text, size: 14);
    }

    final words = text.split(' ');
    final spans = <TextSpan>[];

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final normWord = normalizeForSearch(word);
      final isMatch = normWord.isNotEmpty && normWord.contains(normQuery);

      final style = book.forScript(
        dominantScript(word),
        size: 14,
        bold: isMatch,
        color: isMatch ? book.red : book.ink,
      );

      spans.add(
        TextSpan(
          text: i < words.length - 1 ? '$word ' : word,
          style: isMatch
              ? style.copyWith(
                  backgroundColor: book.red.withValues(alpha: 0.12),
                )
              : style,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
    );
  }
}

class _SearchPromptView extends StatelessWidget {
  const _SearchPromptView({required this.onSelectSuggestion});

  final ValueChanged<String> onSelectSuggestion;

  static const _suggestions = [
    'الْحَمْدُ',
    'الْكِتَاب',
    'رَبّ',
    'مُسْلِم',
    'إِيمَان',
    'فِعْل',
    'ضَمِير',
    'جَنَّة',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    final l = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.boxTint,
                shape: BoxShape.circle,
              ),
              child: Icon(SolarIconsOutline.magnifier, size: 42, color: theme.accent),
            ),
            const SizedBox(height: 14),
            Text(
              l.searchPromptTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              l.searchPromptSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Text(
              l.searchSuggested,
              style: TextStyle(
                color: theme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final word in _suggestions)
                  ActionChip(
                    backgroundColor: theme.paper,
                    side: BorderSide(
                      color: theme.border.withValues(alpha: 0.3),
                    ),
                    label: ScriptText(
                      word,
                      size: 13,
                      forceScript: Script.arabic,
                    ),
                    onPressed: () => onSelectSuggestion(word),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchNoResultsView extends StatelessWidget {
  const _SearchNoResultsView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = BookTheme.of(context);
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(SolarIconsOutline.minimalisticMagnifier, size: 48, color: theme.muted),
            const SizedBox(height: 14),
            Text(
              l.searchNoResultsTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              l.searchNoResultsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
