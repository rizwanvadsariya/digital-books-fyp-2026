import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/book_theme.dart';

enum KeyKind { letter, haraka, function, space, primary }

class KeySpec {
  const KeySpec({
    this.label,
    this.icon,
    this.flex = 1,
    this.kind = KeyKind.letter,
    required this.onTap,
    this.repeat = false,
    this.tooltip,
  });

  factory KeySpec.letter(String ch, {required VoidCallback onTap}) =>
      KeySpec(label: ch, flex: ch.length > 1 && ch != 'لا' ? 1.5 : 1, onTap: onTap);

  /// Harakat are drawn on a dotted circle (U+25CC) so the mark is visible.
  factory KeySpec.haraka(String mark, {required String name, required VoidCallback onTap}) => KeySpec(
        label: mark == 'ـ' ? 'ـ' : '◌$mark',
        kind: KeyKind.haraka,
        onTap: onTap,
        tooltip: name,
      );

  final String? label;
  final IconData? icon;
  final double flex;
  final KeyKind kind;
  final VoidCallback onTap;
  final bool repeat;
  final String? tooltip;
}

class KeyboardKeyWidget extends StatefulWidget {
  const KeyboardKeyWidget({super.key, required this.spec});

  final KeySpec spec;

  @override
  State<KeyboardKeyWidget> createState() => _KeyboardKeyWidgetState();
}

class _KeyboardKeyWidgetState extends State<KeyboardKeyWidget> {
  Timer? _repeat;

  void _press() {
    HapticFeedback.selectionClick();
    widget.spec.onTap();
  }

  void _handleLongPress() {
    _repeat?.cancel();
    _repeat = Timer.periodic(const Duration(milliseconds: 70), (_) => _press());
  }

  void _cancelRepeat(PointerEvent _) {
    _repeat?.cancel();
  }

  @override
  void dispose() {
    _repeat?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final scheme = Theme.of(context).colorScheme;
    final book = BookTheme.of(context);
    final (bg, fg) = switch (spec.kind) {
      KeyKind.letter || KeyKind.space => (scheme.surface, scheme.onSurface),
      KeyKind.haraka => (book.boxTint, book.red),
      KeyKind.function => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      KeyKind.primary => (scheme.primary, scheme.onPrimary),
    };
    final Widget content = spec.icon != null
        ? Icon(spec.icon, size: 20, color: fg)
        : Text(
            spec.label ?? '',
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              // The space bar shows the layout's name (interface text).
              fontFamily: spec.kind == KeyKind.space ? null : arabicFont,
              fontSize: switch (spec.kind) {
                KeyKind.haraka => 24,
                KeyKind.space || KeyKind.function => 14,
                _ => 21,
              },
              height: 1.2,
              color: spec.kind == KeyKind.space ? scheme.onSurfaceVariant : fg,
            ),
          );

    Widget key = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: bg,
        elevation: 1,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: _press,
          onLongPress: spec.repeat ? _handleLongPress : null,
          child: Center(child: content),
        ),
      ),
    );
    if (spec.repeat) {
      key = Listener(
        onPointerUp: _cancelRepeat,
        onPointerCancel: _cancelRepeat,
        child: key,
      );
    }
    if (spec.tooltip != null) key = Tooltip(message: spec.tooltip!, child: key);
    return key;
  }
}
