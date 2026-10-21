import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../l10n/l10n.dart';

/// Slider + previous/next buttons along the bottom of the reader.
class PageScrubber extends StatefulWidget {
  const PageScrubber({
    super.key,
    required this.index,
    required this.total,
    required this.onChanged,
  });

  final int index;
  final int total;
  final ValueChanged<int> onChanged;

  @override
  State<PageScrubber> createState() => _PageScrubberState();
}

class _PageScrubberState extends State<PageScrubber> {
  double? _dragValue;

  void _handlePreviousPage() {
    widget.onChanged(widget.index - 1);
  }

  void _handleNextPage() {
    widget.onChanged(widget.index + 1);
  }

  void _handleSliderChanged(double v) {
    setState(() => _dragValue = v);
  }

  void _handleSliderChangeEnd(double v) {
    setState(() => _dragValue = null);
    widget.onChanged(v.round());
  }

  @override
  Widget build(BuildContext context) {
    final value = _dragValue ?? widget.index.toDouble();
    final l = context.l10n;
    // Always right-to-left, whatever the interface language: the scrubber
    // mirrors the book's own page order.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              // In RTL the start (right) side points back toward earlier pages.
              IconButton(
                tooltip: l.previousPage,
                icon: const Icon(SolarIconsOutline.arrowLeft),
                onPressed: widget.index > 0 ? _handlePreviousPage : null,
              ),
              Expanded(
                child: Slider(
                  value: value,
                  min: 0,
                  max: (widget.total - 1).toDouble(),
                  divisions: widget.total - 1,
                  label: l.pageN('${value.round() + 1}'),
                  onChanged: _handleSliderChanged,
                  onChangeEnd: _handleSliderChangeEnd,
                ),
              ),
              Text(
                '${widget.index + 1}/${widget.total}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              IconButton(
                tooltip: l.nextPage,
                icon: const Icon(SolarIconsOutline.arrowRight),
                onPressed: widget.index < widget.total - 1 ? _handleNextPage : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
