import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(context.tokens.spacing.xl);
    final content = onTap == null
        ? child
        : Material(
            color: context.tokens.colors.transparent,
            child: InkWell(
              onTap: onTap,
              excludeFromSemantics: true,
              child: Padding(padding: effectivePadding, child: child),
            ),
          );
    final card = ShadCard(
      width: double.infinity,
      padding: onTap == null ? effectivePadding : EdgeInsets.zero,
      backgroundColor: backgroundColor,
      child: content,
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: card,
    );
  }
}
