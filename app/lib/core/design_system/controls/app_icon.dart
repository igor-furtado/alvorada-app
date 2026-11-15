import 'package:flutter/material.dart';

import '../app_tokens.dart';

enum AppIconSize { sm, md }

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
    };
    final child = Icon(icon, size: dimension, color: color, semanticLabel: semanticLabel);
    return semanticLabel == null ? ExcludeSemantics(child: child) : child;
  }
}
