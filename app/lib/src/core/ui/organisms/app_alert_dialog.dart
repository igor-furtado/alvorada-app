import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';

enum AppAlertDialogSize { standard, small }

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    required this.title,
    required this.description,
    required this.cancelLabel,
    required this.actionLabel,
    required this.onCancel,
    required this.onAction,
    this.descriptionContent,
    this.media,
    this.size = AppAlertDialogSize.standard,
    this.destructive = false,
    this.loading = false,
    super.key,
  });

  final String title;
  final String description;
  final Widget? descriptionContent;
  final String cancelLabel;
  final String actionLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onAction;
  final Widget? media;
  final AppAlertDialogSize size;
  final bool destructive;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final small = size == AppAlertDialogSize.small;
    final compactViewport = MediaQuery.sizeOf(context).width < tokens.layout.toolbar;
    final centered = small || compactViewport;

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
          insetPadding: EdgeInsets.all(tokens.spacing.lg),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: title,
            child: FocusTraversalGroup(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: small ? tokens.layout.alertDialogSmallMaxWidth : tokens.layout.dialogMaxWidth,
                ),
                child: Container(
                  key: const ValueKey('app-alert-dialog-surface'),
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: tokens.colors.popover,
                    border: Border.all(
                      color: tokens.colors.border,
                      width: tokens.borders.widthHairline,
                    ),
                    borderRadius: tokens.borders.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          tokens.spacing.lg,
                          tokens.spacing.lg,
                          tokens.spacing.lg,
                          tokens.spacing.none,
                        ),
                        child: _AppAlertDialogHeader(
                          title: title,
                          description: description,
                          descriptionContent: descriptionContent,
                          media: media,
                          centered: centered,
                          destructive: destructive,
                        ),
                      ),
                      SizedBox(height: tokens.spacing.lg),
                      _AppAlertDialogFooter(
                        cancelLabel: cancelLabel,
                        actionLabel: actionLabel,
                        onCancel: onCancel,
                        onAction: onAction,
                        expanded: small,
                        stacked: !small && compactViewport,
                        destructive: destructive,
                        loading: loading,
                      ),
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

class _AppAlertDialogHeader extends StatelessWidget {
  const _AppAlertDialogHeader({
    required this.title,
    required this.description,
    required this.descriptionContent,
    required this.media,
    required this.centered,
    required this.destructive,
  });

  final String title;
  final String description;
  final Widget? descriptionContent;
  final Widget? media;
  final bool centered;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = _AppAlertDialogText(
      title: title,
      description: description,
      descriptionContent: descriptionContent,
      centered: centered,
    );

    if (media == null) return text;

    final mediaContainer = Container(
      width: tokens.sizes.iconContainerSm,
      height: tokens.sizes.iconContainerSm,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: destructive ? tokens.colors.errorContainer : tokens.colors.surfaceSubtle,
        borderRadius: tokens.borders.lg,
      ),
      child: IconTheme(
        data: IconThemeData(
          color: destructive ? tokens.colors.error : tokens.colors.onSurface,
          size: tokens.icons.lg,
        ),
        child: media!,
      ),
    );

    if (centered) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mediaContainer,
          SizedBox(height: tokens.spacing.sm),
          text,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mediaContainer,
        SizedBox(width: tokens.spacing.lg),
        Expanded(child: text),
      ],
    );
  }
}

class _AppAlertDialogText extends StatelessWidget {
  const _AppAlertDialogText({
    required this.title,
    required this.description,
    required this.descriptionContent,
    required this.centered,
  });

  final String title;
  final String description;
  final Widget? descriptionContent;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final descriptionStyle = tokens.typography.bodySmall.copyWith(
      color: tokens.colors.onSurfaceMuted,
      letterSpacing: 0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: tokens.typography.titleMedium,
        ),
        SizedBox(height: tokens.spacing.xs),
        DefaultTextStyle.merge(
          style: descriptionStyle,
          textAlign: centered ? TextAlign.center : TextAlign.left,
          child:
              descriptionContent ??
              Text(
                description,
                textAlign: centered ? TextAlign.center : TextAlign.left,
              ),
        ),
      ],
    );
  }
}

class _AppAlertDialogFooter extends StatelessWidget {
  const _AppAlertDialogFooter({
    required this.cancelLabel,
    required this.actionLabel,
    required this.onCancel,
    required this.onAction,
    required this.expanded,
    required this.stacked,
    required this.destructive,
    required this.loading,
  });

  final String cancelLabel;
  final String actionLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onAction;
  final bool expanded;
  final bool stacked;
  final bool destructive;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final cancel = AppButton(
      label: cancelLabel,
      variant: AppButtonVariant.outline,
      onPressed: onCancel,
    );
    final action = AppButton(
      label: actionLabel,
      variant: destructive ? AppButtonVariant.destructive : AppButtonVariant.primary,
      onPressed: onAction,
      loading: loading,
    );

    final actions = expanded
        ? Row(
            children: [
              Expanded(child: cancel),
              SizedBox(width: tokens.spacing.sm),
              Expanded(child: action),
            ],
          )
        : stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              action,
              SizedBox(height: tokens.spacing.sm),
              cancel,
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              cancel,
              SizedBox(width: tokens.spacing.sm),
              action,
            ],
          );

    return Container(
      key: const ValueKey('app-alert-dialog-footer'),
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.colors.surfaceSubtle.withValues(alpha: tokens.opacity.half),
        border: Border(
          top: BorderSide(
            color: tokens.colors.border,
            width: tokens.borders.widthHairline,
          ),
        ),
      ),
      child: actions,
    );
  }
}
