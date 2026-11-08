import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final colors = context.tokens.colors;
    final (background, foreground, icon) = switch (variant) {
      AppSnackbarVariant.neutral => (scheme.inverseSurface, scheme.onInverseSurface, AppIcons.observation),
      AppSnackbarVariant.success => (colors.success, colors.onSuccess, AppIcons.check),
      AppSnackbarVariant.error => (scheme.error, scheme.onError, AppIcons.attention),
      AppSnackbarVariant.info => (colors.info, colors.onInfo, AppIcons.observation),
    };
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
                child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: foreground)),
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
