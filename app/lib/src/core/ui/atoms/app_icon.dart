import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum AppIconSize { sm, md, lg, xl, hero }

class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {this.size = AppIconSize.md, this.color, this.semanticLabel, super.key});

  final IconData icon;
  final AppIconSize size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dimension = switch (size) {
      AppIconSize.sm => context.tokens.icons.sm,
      AppIconSize.md => context.tokens.icons.md,
      AppIconSize.lg => context.tokens.icons.lg,
      AppIconSize.xl => context.tokens.icons.xl,
      AppIconSize.hero => context.tokens.icons.hero,
    };
    final child = Icon(icon, size: dimension, color: color, semanticLabel: semanticLabel);
    return semanticLabel == null ? ExcludeSemantics(child: child) : child;
  }
}
