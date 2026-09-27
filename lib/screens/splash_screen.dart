import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/book_cubit.dart';
import '../theme/book_theme.dart';
import 'home_shell.dart';

/// Loads and parses the book JSON once, then hands over to [HomeShell].
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookCubit, BookState>(
      listenWhen: (a, b) => b.status == BookStatus.ready,
      listener: (context, _) => Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, _, _) => const HomeShell(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        ),
      ),
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF3E0F0C),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'مُعَلِّمُ الْقُرْآن',
                  style: TextStyle(fontFamily: arabicFont, fontSize: 44, color: Color(0xFFE6C77A), height: 1.6),
                ),
                const SizedBox(height: 24),
                if (state.status == BookStatus.failure) ...[
                  Text(
                    'کتاب لوڈ نہیں ہو سکی\n${state.error ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<BookCubit>().load(),
                    child: const Text('دوبارہ کوشش کریں'),
                  ),
                ] else
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFE6C77A)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
