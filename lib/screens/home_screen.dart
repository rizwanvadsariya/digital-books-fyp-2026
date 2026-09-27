import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/answers_cubit.dart';
import '../blocs/book_cubit.dart';
import '../blocs/library_cubit.dart';
import '../blocs/progress_cubit.dart';
import '../data/volumes.dart';
import '../l10n/l10n.dart';
import '../models/content_block.dart';
import '../theme/book_theme.dart';
import '../widgets/blocks/styled_frame.dart';
import 'answers_review_screen.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onShowContents});

  final VoidCallback onShowContents;

  @override
  Widget build(BuildContext context) {
    final book = context.read<BookCubit>().state.book!;
    final progress = context.watch<ProgressCubit>().state;
    final answerCount = context.select<AnswersCubit, int>(
      (c) => c.state.answers.length,
    );
    final theme = BookTheme.of(context);
    final last = progress.lastPageIndex;
    final l = context.l10n;
    final volume = context.watch<LibraryCubit>().state;

    String? tagline;
    for (final p in book.pages) {
      for (final b in p.blocks) {
        if (b is TextBlock && b.type == 'tagline') {
          tagline ??= b.text;
        }
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _VolumeShelf(),
          const SizedBox(height: 12),
          _Cover(
            volume: volume,
            tagline: tagline,
            onTap: () => openReader(context, last ?? 0),
          ),
          const SizedBox(height: 16),
          if (last != null)
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => openReader(context, last),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.red,
                        child: const Icon(
                          Icons.auto_stories,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.continueReading,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              pageLocation(l, book.pages[last]),
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.muted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: (last + 1) / book.length,
                              borderRadius: BorderRadius.circular(4),
                              color: theme.red,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${last + 1}/${book.length}'),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _ActionTile(
                icon: Icons.menu_book_outlined,
                label: last == null ? l.startReading : l.readFromStart,
                onTap: () => openReader(context, 0),
              ),
              _ActionTile(
                icon: Icons.toc,
                label: l.navContents,
                onTap: onShowContents,
              ),
              _ActionTile(
                icon: Icons.edit_note,
                label: l.myAnswers,
                badge: answerCount,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AnswersReviewScreen(),
                  ),
                ),
              ),
              _ActionTile(
                icon: Icons.tune,
                label: l.settings,
                onTap: () => openSettings(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Volume picker: one mini cover per volume; the open one is highlighted.
class _VolumeShelf extends StatelessWidget {
  const _VolumeShelf();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = context.watch<LibraryCubit>().state;
    const gold = Color(0xFFE6C77A);
    return Row(
      children: [
        for (final v in bookVolumes) ...[
          if (v != bookVolumes.first) const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: v == current
                  ? const Color(0xFF7A1F1A)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.read<LibraryCubit>().select(v),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: v == current ? gold : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  // Icon beside the text when there's room; stacked above it
                  // on narrow cards (three volumes on a phone).
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final icon = Icon(
                        v == current ? Icons.menu_book : Icons.book_outlined,
                        color: v == current ? gold : null,
                      );
                      final narrow = constraints.maxWidth < 130;
                      final labels = Column(
                        crossAxisAlignment: narrow
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.volumeN(v.number),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: v == current ? Colors.white : null,
                            ),
                          ),
                          Text(
                            // Isolate numbers so RTL text doesn't read "4–5" as "5–4".
                            v.units.contains('–')
                                ? l.unitsRange('\u2066${v.units}\u2069')
                                : l.unitN(v.units),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: v == current ? Colors.white70 : null,
                            ),
                          ),
                        ],
                      );
                      if (narrow) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [icon, const SizedBox(height: 2), labels],
                        );
                      }
                      return Row(
                        children: [
                          icon,
                          const SizedBox(width: 10),
                          Expanded(child: labels),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({
    required this.volume,
    required this.tagline,
    required this.onTap,
  });

  final BookVolume volume;
  final String? tagline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFE6C77A);
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF7A1F1A), Color(0xFF3E0F0C)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: CustomPaint(
              painter: OrnamentalFramePainter(
                color: gold,
                fill: Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 34,
                ),
                child: Column(
                  children: [
                    const Text(
                      'مُعَلِّمُ الْقُرْآن',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: arabicFont,
                        fontSize: 40,
                        color: gold,
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                      ),
                    ),
                    Text(
                      volume.coverSubtitle,
                      style: const TextStyle(
                        fontFamily: urduFont,
                        fontSize: 16,
                        color: Colors.white,
                        height: 2,
                      ),
                    ),
                    if (tagline != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        tagline!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: urduFont,
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge.count(
                count: badge ?? 0,
                isLabelVisible: (badge ?? 0) > 0,
                offset: const Offset(8, -4),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
