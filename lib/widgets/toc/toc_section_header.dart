import 'package:flutter/material.dart';

import '../../theme/book_theme.dart';

class TocSectionHeader extends StatelessWidget {
  const TocSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final book = BookTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: book.red, fontWeight: FontWeight.bold),
      ),
    );
  }
}
