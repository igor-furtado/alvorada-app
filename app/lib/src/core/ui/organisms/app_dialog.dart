import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_accessible_icon_button.dart';
import '../atoms/app_button.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.content,
    this.description,
    this.media,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.actions = const [],
    this.destructive = false,
    this.loading = false,
    this.showCloseButton = true,
    this.maxWidth,
    super.key,
  });

  final String title;
  final String? description;
  final Widget? media;
  final Widget content;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final List<Widget> actions;
  final bool destructive;
  final bool loading;
  final bool showCloseButton;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final footerActions = <Widget>[
      if (secondaryLabel != null)
        AppButton(
          label: secondaryLabel!,
          variant: AppButtonVariant.outline,
          onPressed: onSecondary,
        ),
      if (primaryLabel != null)
        AppButton(
          label: primaryLabel!,
          variant: destructive ? AppButtonVariant.destructive : AppButtonVariant.primary,
          onPressed: onPrimary,
          loading: loading,
        ),
      ...actions,
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: tokens.sizes.dialogBackdropBlur,
            sigmaY: tokens.sizes.dialogBackdropBlur,
          ),
          child: ColoredBox(color: tokens.colors.transparent),
        ),
        Dialog(
          backgroundColor: tokens.colors.transparent,
          surfaceTintColor: tokens.colors.transparent,
          shadowColor: tokens.colors.transparent,
          elevation: tokens.spacing.none,
          insetPadding: EdgeInsets.all(tokens.spacing.xxl),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: title,
            child: FocusTraversalGroup(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth ?? tokens.layout.dialogMaxWidth,
                ),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: tokens.colors.popover,
                    border: Border.all(
                      color: tokens.colors.border,
                      width: tokens.borders.widthHairline,
                    ),
                    borderRadius: tokens.borders.xl,
                    boxShadow: tokens.shadows.overlay,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AppDialogHeader(
                        title: title,
                        description: description,
                        media: media,
                        showCloseButton: showCloseButton,
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            tokens.spacing.lg,
                            tokens.spacing.none,
                            tokens.spacing.lg,
                            tokens.spacing.lg,
                          ),
                          child: content,
                        ),
                      ),
                      if (footerActions.isNotEmpty) _AppDialogFooter(actions: footerActions),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppDialogHeader extends StatelessWidget {
  const _AppDialogHeader({
    required this.title,
    required this.description,
    required this.media,
    required this.showCloseButton,
  });

  final String title;
  final String? description;
  final Widget? media;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.lg,
        tokens.spacing.lg,
        tokens.spacing.lg,
        tokens.spacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (media != null) ...[
            Container(
              width: tokens.sizes.iconContainerSm,
              height: tokens.sizes.iconContainerSm,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.colors.surfaceSubtle,
                borderRadius: tokens.borders.lg,
              ),
              child: media,
            ),
            SizedBox(width: tokens.spacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tokens.typography.titleMedium),
                if (description != null) ...[
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    description!,
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showCloseButton) ...[
            SizedBox(width: tokens.spacing.md),
            AppAccessibleIconButton(
              icon: AppIcons.close,
              label: AppMessages.close,
              onPressed: () => Navigator.maybePop(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppDialogFooter extends StatelessWidget {
  const _AppDialogFooter({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.lg,
        vertical: tokens.spacing.lg,
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surfaceSubtle.withValues(alpha: tokens.opacity.half),
        border: Border(
          top: BorderSide(
            color: tokens.colors.border,
            width: tokens.borders.widthHairline,
          ),
        ),
      ),
      child: Wrap(
        spacing: tokens.spacing.sm,
        runSpacing: tokens.spacing.sm,
        alignment: WrapAlignment.end,
        children: actions,
      ),
    );
  }
}
