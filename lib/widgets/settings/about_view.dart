import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Text(l.aboutBook);
  }
}
