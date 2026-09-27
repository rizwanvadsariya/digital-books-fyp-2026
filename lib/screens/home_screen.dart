import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/answers_cubit.dart';
import '../blocs/book_cubit.dart';
import '../blocs/progress_cubit.dart';
import '../models/content_block.dart';
import '../theme/book_theme.dart';
import '../widgets/blocks/styled_frame.dart';
import '../widgets/common/script_text.dart';
import '../widgets/reading_settings_sheet.dart';
import 'answers_review_screen.dart';
import 'reader_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onShowContents});

  final VoidCallback onShowContents;

  @override
  Widget build(BuildContext context) {
    final book = context.read<BookCubit>().state.book!;
    final progress = context.watch<ProgressCubit>().state;
    final answerCount = context.select<AnswersCubit, int>((c) => c.state.answers.length);
    final theme = BookTheme.of(context);
    final last = progress.lastPageIndex;

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
          _Cover(tagline: tagline, onTap: () => openReader(context, last ?? 0)),
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
                        child: const Icon(Icons.auto_stories, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('پڑھنا جاری رکھیں', style: TextStyle(fontWeight: FontWeight.bold)),
                            ScriptText(book.locationLabel(book.pages[last]), size: 13, color: theme.muted),
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
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.menu_book_outlined,
                  label: last == null ? 'پڑھنا شروع کریں' : 'شروع سے پڑھیں',
                  onTap: () => openReader(context, 0),
                ),
              ),
              Expanded(child: _ActionTile(icon: Icons.toc, label: 'فہرست', onTap: onShowContents)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.edit_note,
                  label: 'میرے جوابات',
                  badge: answerCount,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AnswersReviewScreen()),
                  ),
                ),
              ),
              Expanded(
                child: _ActionTile(
                  icon: Icons.tune,
                  label: 'ترتیبات',
                  onTap: () => showReadingSettings(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.tagline, required this.onTap});

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
              painter: OrnamentalFramePainter(color: gold, fill: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
                child: Column(
                  children: [
                    const Text(
                      'مُعَلِّمُ الْقُرْآن',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: arabicFont, fontSize: 40, color: gold, fontWeight: FontWeight.bold, height: 1.6),
                    ),
                    const Text(
                      'جلد اوّل',
                      style: TextStyle(fontFamily: urduFont, fontSize: 16, color: Colors.white, height: 2),
                    ),
                    if (tagline != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        tagline!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: urduFont, fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 2),
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
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.badge});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Badge(
                isLabelVisible: (badge ?? 0) > 0,
                label: Text('${badge ?? 0}'),
                child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
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
