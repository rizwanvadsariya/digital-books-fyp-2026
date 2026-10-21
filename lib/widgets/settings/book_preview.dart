import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/settings_cubit.dart';
import '../../theme/book_theme.dart';
import '../common/script_text.dart';

/// A snippet of real book text so the reader sees the size and colour
/// settings applied. It is book content, so it never changes language.
class BookPreview extends StatelessWidget {
  const BookPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final book = BookTheme.forSettings(settings);
    return Theme(
      data: Theme.of(context).copyWith(extensions: [book]),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: book.paper,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: book.border.withValues(alpha: 0.4)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScriptText(
                'وَاللَّهُ غَفُورٌ رَّحِيمٌ',
                size: 16,
                align: TextAlign.center,
              ),
              ScriptText(
                'اور اللہ بخشنے والا، رحم کرنے والا ہے',
                size: 14,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
