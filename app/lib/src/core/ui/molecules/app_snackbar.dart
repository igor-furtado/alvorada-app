import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../accessibility/app_accessibility.dart';
import '../atoms/app_icon.dart';

enum AppSnackbarVariant { neutral, success, error, info }

abstract final class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarVariant variant = AppSnackbarVariant.neutral,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = context.tokens.colors;
    final (background, foreground, icon) = switch (variant) {
      AppSnackbarVariant.neutral => (colors.onSurface, colors.canvas, AppIcons.observation),
      AppSnackbarVariant.success => (colors.success, colors.onSuccess, AppIcons.check),
      AppSnackbarVariant.error => (colors.error, colors.onError, AppIcons.attention),
      AppSnackbarVariant.info => (colors.info, colors.onInfo, AppIcons.observation),
    };
    AppAccessibility.announce(context, message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          content: Row(
            children: [
              AppIcon(icon, size: AppIconSize.sm, color: foreground),
              SizedBox(width: context.tokens.spacing.md),
              Expanded(
                child: Text(message, style: context.tokens.typography.bodyMedium.copyWith(color: foreground)),
              ),
            ],
          ),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(label: actionLabel, textColor: foreground, onPressed: onAction),
        ),
      );
  }
}
