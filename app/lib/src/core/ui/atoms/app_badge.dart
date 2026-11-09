import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';

enum AppBadgeVariant { neutral, primary, success, error, info }

class AppBadge extends StatelessWidget {
  const AppBadge({required this.label, this.variant = AppBadgeVariant.neutral, super.key});

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.tokens.colors;
    final (background, foreground) = switch (variant) {
      AppBadgeVariant.neutral => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      AppBadgeVariant.primary => (scheme.primaryContainer, scheme.onPrimaryContainer),
      AppBadgeVariant.success => (colors.successContainer, colors.success),
      AppBadgeVariant.error => (scheme.errorContainer, scheme.onErrorContainer),
      AppBadgeVariant.info => (colors.infoContainer, colors.info),
    };
    return Semantics(
      label: label,
      child: ShadBadge.outline(
        backgroundColor: background,
        foregroundColor: foreground,
        shape: RoundedRectangleBorder(borderRadius: context.tokens.borders.sm),
        padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm, vertical: context.tokens.spacing.xxs),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
      ),
    );
  }
}
