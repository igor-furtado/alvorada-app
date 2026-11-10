import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_icon.dart';

enum AppAlertVariant { neutral, success, warning, destructive }

class AppAlert extends StatelessWidget {
  const AppAlert({
    required this.title,
    required this.description,
    this.icon,
    this.action,
    this.variant = AppAlertVariant.neutral,
    super.key,
  });

  final String title;
  final String description;
  final IconData? icon;
  final Widget? action;
  final AppAlertVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final foreground = switch (variant) {
      AppAlertVariant.neutral => colors.onSurface,
      AppAlertVariant.success => colors.success,
      AppAlertVariant.warning => colors.warning,
      AppAlertVariant.destructive => colors.errorForeground,
    };
    final background = switch (variant) {
      AppAlertVariant.neutral => colors.card,
      AppAlertVariant.success => colors.card,
      AppAlertVariant.warning => colors.warningContainer,
      AppAlertVariant.destructive => colors.card,
    };
    final border = switch (variant) {
      AppAlertVariant.warning => colors.warningBorder,
      _ => colors.border,
    };
    return Semantics(
      container: true,
      liveRegion: variant != AppAlertVariant.neutral,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.tokens.spacing.md,
          vertical: context.tokens.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: context.tokens.borders.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              AppIcon(icon!, size: AppIconSize.sm, color: foreground),
              SizedBox(width: context.tokens.spacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.tokens.typography.titleSmall.copyWith(color: foreground)),
                  SizedBox(height: context.tokens.spacing.xxs),
                  Text(description, style: context.tokens.typography.bodySmall.copyWith(color: foreground)),
                ],
              ),
            ),
            if (action != null) ...[
              SizedBox(width: context.tokens.spacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
