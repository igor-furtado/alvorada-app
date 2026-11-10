import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum AppBadgeVariant { primary, secondary, destructive, outline }

class AppBadge extends StatelessWidget {
  const AppBadge({required this.label, this.variant = AppBadgeVariant.primary, super.key});

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final (background, foreground, border) = switch (variant) {
      AppBadgeVariant.primary => (colors.primary, colors.onPrimary, colors.transparent),
      AppBadgeVariant.secondary => (colors.surfaceSubtle, colors.onSurface, colors.transparent),
      AppBadgeVariant.destructive => (colors.errorContainer, colors.errorForeground, colors.transparent),
      AppBadgeVariant.outline => (colors.transparent, colors.onSurface, colors.border),
    };
    return Semantics(
      label: label,
      child: Container(
        constraints: BoxConstraints(minHeight: context.tokens.spacing.xl),
        padding: EdgeInsets.symmetric(
          horizontal: context.tokens.spacing.sm,
          vertical: context.tokens.spacing.xxxs,
        ),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: context.tokens.borders.full,
        ),
        child: Text(label, style: context.tokens.typography.labelMedium.copyWith(color: foreground)),
      ),
    );
  }
}
