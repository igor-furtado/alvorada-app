import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';
import '../responsive/app_responsive.dart';

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
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (secondaryLabel != null)
        AppButton(label: secondaryLabel!, variant: AppButtonVariant.text, onPressed: onSecondary),
      if (primaryLabel != null)
        AppButton(
          label: primaryLabel!,
          variant: destructive ? AppButtonVariant.destructive : AppButtonVariant.primary,
          onPressed: onPrimary,
          loading: loading,
        ),
    ];
    if (context.windowClass.isCompact) {
      return Dialog.fullscreen(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spacing.xl),
            child: FocusTraversalGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: context.tokens.spacing.xl),
                  Expanded(child: SingleChildScrollView(child: content)),
                  SizedBox(height: context.tokens.spacing.xl),
                  Wrap(
                    spacing: context.tokens.spacing.sm,
                    runSpacing: context.tokens.spacing.sm,
                    alignment: WrapAlignment.end,
                    children: actions,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return ShadDialog(
      title: Text(title),
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? context.tokens.layout.dialogMaxWidth,
      ),
      scrollable: true,
      actions: actions,
      child: content,
    );
  }
}
