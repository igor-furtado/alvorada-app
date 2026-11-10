import 'package:flutter/material.dart';

import 'app_snackbar.dart';

abstract final class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarVariant variant = AppSnackbarVariant.neutral,
    String? actionLabel,
    VoidCallback? onAction,
  }) => AppSnackbar.show(
    context,
    message: message,
    variant: variant,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}
