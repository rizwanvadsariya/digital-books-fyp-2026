# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app (**Muallim-Ul-Quran**) that renders the Urdu/Arabic Quran-learning textbook *Muallim-ul-Quran* — Volume 1 (`assets/data/muallim_ul_quran_vol1_full.json`, units 1–3) and Volume 2 (`…_vol2_full.json`, units 4–5). It provides a right-to-left, page-turning book reader, in-book exercises answered through an embedded Arabic/Urdu keyboard, and saved progress. State management is **flutter_bloc (Cubits)**. Persistence is **shared_preferences**. Do not introduce Riverpod or Hive.

## Commands

```bash
flutter pub get
flutter analyze
flutter test                                        # all tests (~20s; renders all 102 pages twice)
flutter test test/utils/arabic_text_test.dart       # one file
flutter test --plain-name 'check button grades'     # one test by name
flutter run -d macos    # or chrome / an emulator
```

`test/widgets/render_all_pages_test.dart` pumps every page of the real JSON in normal and practice mode and fails on any layout exception. Run it after changing any block widget. Widget tests use Flutter's placeholder test font. To see real Arabic/Nastaliq rendering, load the fonts with `FontLoader` in a throwaway golden test and view the PNGs.

## Architecture

- **Volumes:** `lib/data/volumes.dart` lists each volume's asset and storage namespace. All volumes share one parser, one set of models and one set of widgets. To add a volume, add its JSON to `assets/data/` and pubspec, then add an entry there. `LibraryCubit` holds the open volume. `main.dart` keeps a `VolumeSession` (Book/Progress/Answers Cubits) for each volume and provides the open one **above** `MaterialApp`, so every route sees it. `HomeShell` keys its tabs by volume id, so they rebuild on switch.
- **Per-volume storage:** answer IDs and page indexes are only unique within a volume, so answers, progress and bookmarks go through `LocalStore.forVolume(namespace)`. Volume 1's namespace is `''`, which keeps the original keys and existing user data. Settings and the selected volume are app-wide.

- `lib/models/content_block.dart`: a sealed `ContentBlock` hierarchy with a never-throwing `fromJson`. Text-like types (`heading`, `paragraph`, `note_box`, `instruction`, …) share one `TextBlock` model, distinguished by `type`. Structured types have their own classes. Unknown or malformed types become `UnknownBlock`, which renders every string it contains.
- `lib/models/block_style.dart`: the `style` field is free-form (19 values). It is decoded **by token** (`red`, `bold`, `boxed`, `ornamental`, `black_badge`, …) rather than as an enum, so new combinations render without code changes.
- `lib/models/book.dart`: `Book` builds `units` (Unit → Lesson → page) by scanning page `unit`/`lesson` fields. Lessons can be string ranges (`"15-16"`). Unit cover pages lack a `unit` field and are attached to the following unit. Also maps printed page numbers ↔ page indexes.
- `lib/widgets/blocks/block_renderer.dart`: dispatches on the sealed type. Blocks receive `pdfPage` and `blockIndex`, which form the answer IDs.
- **Answer IDs** are `{pdf_page}_{block_index}_{item_index}` (`answerId()` in `blocs/answers_cubit.dart`). Table cells use `{row}-{col}` as the item index. `block_index` is the position in the page's raw `blocks` array, including pinned markers, so never re-index blocks. `data/exercise_lookup.dart` resolves an ID back to its prompt and answer key for the review screen.
- **Blank vs. answer key:** a `null` `note`/`translation`/table cell is a blank for the student. A non-null value is the book's printed answer, which is shown normally. **Practice mode** (setting) hides printed answers and turns them into self-check fields. A `vocab_list` note of `"red"` is a formatting marker (new word shown in red), not a meaning (`VocabItem.meaning`).
- **Keyboard:** `widgets/keyboard/keyboard_cubit.dart` holds the active field's `TextEditingController`. `AnswerField` is `readOnly` while the custom keyboard is in use, so the OS keyboard stays hidden. It becomes editable when the user switches to the native keyboard. The docked `ArabicKeyboard` is shown by `ReaderScreen` in place of the page scrubber. Harakat are combining marks inserted at the caret. Backspace deletes one code point, so a haraka can be removed without deleting its letter. A `KeyboardCubit` is scoped to each reader route.
- **Page flip (`widgets/book_flip_view.dart`):** a `PageView` laid out LTR with **reversed indexes** (`positionForIndex`). Dragging left→right advances the book, and the page being turned always paints on top. Pages are counter-translated and the top page is rotated around its right-edge spine. Page transforms depend on this ordering.
- **Scrolling a field into view** must use the nearest *vertical* `Scrollable` only (see `AnswerField._activate`). `Scrollable.ensureVisible` also scrolls the horizontal page turner, which flips the page and closes the keyboard. `test/widgets/reader_test.dart` guards this.
- **Fonts / scripts:** Amiri for vocalised Arabic, Noto Nastaliq Urdu (a variable font; weight is set through `FontVariation('wght')`) for Urdu. `ScriptText` splits mixed text into per-script runs (`utils/arabic_text.dart`, `splitScriptRuns`). The heuristic is: harakat or Arabic letter forms (ي ك ه ة) → Arabic, and Urdu forms (ی ک ہ ے ٹ …) → Urdu. `BookTheme` (a `ThemeExtension`) carries the paper/sepia/dark palettes and the font scale.
- **Interface language vs. book content:** interface strings live in `lib/l10n/app_{en,ur}.arb` (gen-l10n, and `flutter pub get` regenerates them). Access them with `context.l10n` from `lib/l10n/l10n.dart`. The user picks System/Urdu/English in Settings (`ReaderSettings.language`). This locale must **never** affect book content, so:
  - Never pass text from the JSON through l10n.
  - Page contents stay right-to-left: `BookFlipView` wraps pages in `Directionality.rtl`, and the page scrubber is forced RTL because it mirrors the book's page order.
  - The badge printed on the page uses the Urdu `Book.locationLabel`. App bars and lists use the localized `pageLocation(l10n, page)`.
  - Interface text placed on a book page (hints, "Singular/Plural", check tooltips) uses `uiTextStyle(context)`, not `BookTheme`'s book fonts.
  - The Urdu interface uses Nastaliq (`withUiFont`). The English interface keeps the platform font, with a Nastaliq fallback for embedded Urdu such as lesson titles.
- Answer checking (`answerMatches`) is lenient by default: it ignores harakat, folds Arabic/Urdu letter variants, and accepts any `/`- or `،`-separated alternative. Strict mode requires exact harakat.

## Data quirks

Volume 1:

- `columns` is an int layout hint on vocab and verse lists, but a list of header strings on tables.
- Table `rows` are keyed by header text. Repeated headers are disambiguated only in the row keys (`مطلب`, `مطلب ۲`), so column order comes from the row keys (`TableBlock.keys`) and labels from `columns` (`TableBlock.headers`).
- `vocab_pair_list` items are either `{pair, note}` or `{singular, plural, …meaning?}`. `question` blocks have `items` (words to answer) or `verses` (snippets to identify a part of).
- The printed contents page (`page_kind: table_of_contents`) has `سبق/صفحہ/موضوع` rows. Tapping a row jumps to that printed page.

Volume 2 adds these shapes, all handled by the shared parser:
- `quran_verse` with `items: [..]` instead of `text`: use `QuranVerseBlock.allVerses`.
- `unit_summary_box` with `title` instead of `label`.
- Two tables whose `rows` are **lists**, matched to `columns` by position using `#0…` keys; one column header is blank.
- Row keys not in `columns` (`note`, `مطلب2`): see `TableBlock._headerFor`.
- `question.marks` on model papers.
- Page kinds `guidance_notes`, `model_paper`, `key_words`, `quranic_style`. The last two are lesson pages with the default layout.
- One contents row has `صفحہ: null`.
- Unit covers' `unit_marker` is just a number (circle badge). The page header pins only non-numeric markers.

Glyphs: `←` (248 times) and `↔` (24 times) aren't in Amiri or Nastaliq. `assets/fonts/NotoSansMath-Arrows.ttf` (family `BookSymbols`, a U+2190–21FF subset) is in every book and interface font's fallback list. Draw decorative markers such as ◆ as shapes, not characters.
