import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.content,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.destructive = false,
    this.loading = false,
    this.maxWidth,
    super.key,
  });

  final String title;
  final Widget content;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool destructive;
  final bool loading;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? context.tokens.layout.dialogMaxWidth),
      child: content,
    ),
    actions: [
      if (secondaryLabel != null)
        AppButton(label: secondaryLabel!, variant: AppButtonVariant.text, onPressed: onSecondary),
      if (primaryLabel != null)
        AppButton(
          label: primaryLabel!,
          variant: destructive ? AppButtonVariant.destructive : AppButtonVariant.primary,
          onPressed: onPrimary,
          loading: loading,
        ),
    ],
  );
}
