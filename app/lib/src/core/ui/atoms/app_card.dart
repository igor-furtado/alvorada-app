import 'package:flutter/material.dart';

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
    final effectivePadding = padding ?? EdgeInsets.all(context.tokens.spacing.lg);
    final content = Padding(padding: effectivePadding, child: child);
    final card = Material(
      color: backgroundColor ?? context.tokens.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.borders.xl,
        side: BorderSide(color: context.tokens.colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              excludeFromSemantics: true,
              hoverColor: context.tokens.colors.surfaceSubtle,
              child: content,
            ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: card,
    );
  }
}
