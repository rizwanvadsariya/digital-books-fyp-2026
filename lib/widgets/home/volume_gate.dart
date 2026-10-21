import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/book_cubit.dart';
import '../../blocs/library_cubit.dart';
import '../../l10n/l10n.dart';

/// Shows a loader (or error) while the selected volume's JSON is parsed.
class VolumeGate extends StatelessWidget {
  const VolumeGate({super.key, required this.builder});

  final Widget Function(String volumeId) builder;

  void _handleRetry(BuildContext context) {
    context.read<BookCubit>().load();
  }

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
              onPressed: () => _handleRetry(context),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    };
  }
}
