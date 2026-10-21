import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../blocs/library_cubit.dart';
import '../../data/volumes.dart';
import '../../l10n/l10n.dart';

/// Volume picker: one mini cover per volume; the open one is highlighted.
class VolumeShelf extends StatelessWidget {
  const VolumeShelf({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<LibraryCubit>().state;
    return Row(
      children: [
        for (final v in bookVolumes) ...[
          if (v != bookVolumes.first) const SizedBox(width: 8),
          Expanded(
            child: VolumeShelfItem(
              volume: v,
              isSelected: v == current,
            ),
          ),
        ],
      ],
    );
  }
}

class VolumeShelfItem extends StatelessWidget {
  const VolumeShelfItem({
    super.key,
    required this.volume,
    required this.isSelected,
  });

  final BookVolume volume;
  final bool isSelected;

  void _handleTap(BuildContext context) {
    context.read<LibraryCubit>().select(volume);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const gold = Color(0xFFE6C77A);

    return Material(
      color: isSelected
          ? const Color(0xFF7A1F1A)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? gold : Colors.transparent,
              width: 1.5,
            ),
          ),
          // Icon beside the text when there's room; stacked above it
          // on narrow cards (three volumes on a phone).
          child: LayoutBuilder(
            builder: (context, constraints) {
              final icon = Icon(
                isSelected
                    ? SolarIconsBold.book2
                    : SolarIconsOutline.book2,
                color: isSelected ? gold : null,
              );
              final narrow = constraints.maxWidth < 130;
              final labels = Column(
                crossAxisAlignment: narrow
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    l.volumeN(volume.number),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  Text(
                    // Isolate numbers so RTL text doesn't read "4–5" as "5–4".
                    volume.units.contains('–')
                        ? l.unitsRange('\u2066${volume.units}\u2069')
                        : l.unitN(volume.units),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : null,
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
    );
  }
}
