import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';

import '../blocs/answers_cubit.dart';
import '../blocs/book_cubit.dart';
import '../blocs/library_cubit.dart';
import '../blocs/progress_cubit.dart';
import '../core/navigation/route_enums.dart';
import '../l10n/l10n.dart';
import '../models/content_block.dart';
import '../theme/book_theme.dart';
import '../widgets/home/action_tile.dart';
import '../widgets/home/book_cover.dart';
import '../widgets/home/volume_shelf.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onShowContents});

  final VoidCallback onShowContents;

  void _handleOpenReader(BuildContext context, int pageIndex) {
    openReader(context, pageIndex);
  }

  void _handleOpenAnswers(BuildContext context) {
    context.pushNamed(AppRoutes.answersReview.name);
  }

  void _handleOpenSettings(BuildContext context) {
    openSettings(context);
  }

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
          const VolumeShelf(),
          const SizedBox(height: 12),
          BookCover(
            volume: volume,
            tagline: tagline,
            onTap: () => _handleOpenReader(context, last ?? 0),
          ),
          const SizedBox(height: 16),
          if (last != null)
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _handleOpenReader(context, last),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.red,
                        child: const Icon(
                          SolarIconsBold.book2,
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
              ActionTile(
                icon: SolarIconsOutline.book2,
                label: last == null ? l.startReading : l.readFromStart,
                onTap: () => _handleOpenReader(context, 0),
              ),
              ActionTile(
                icon: SolarIconsOutline.list_1,
                label: l.navContents,
                onTap: onShowContents,
              ),
              ActionTile(
                icon: SolarIconsOutline.notes,
                label: l.myAnswers,
                badge: answerCount,
                onTap: () => _handleOpenAnswers(context),
              ),
              ActionTile(
                icon: SolarIconsOutline.settings,
                label: l.settings,
                onTap: () => _handleOpenSettings(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
