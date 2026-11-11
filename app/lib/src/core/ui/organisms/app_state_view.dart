import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';
import '../atoms/app_dashed_container.dart';

enum AppStateVariant { empty, error, offline, permissionDenied, success }

enum AppStateSurface { plain, outline, muted }

enum AppStateMediaVariant { custom, icon }

class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.variant,
    this.title,
    this.message,
    this.icon,
    this.media,
    this.mediaVariant = AppStateMediaVariant.icon,
    this.showMedia = true,
    this.surface = AppStateSurface.plain,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.content,
    this.footer,
    super.key,
  }) : assert(
         content == null || (actionLabel == null && secondaryActionLabel == null),
         'Custom content replaces the standard actions.',
       );

  final AppStateVariant variant;
  final String? title;
  final String? message;
  final IconData? icon;
  final Widget? media;
  final AppStateMediaVariant mediaVariant;
  final bool showMedia;
  final AppStateSurface surface;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Widget? content;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final defaults = switch (variant) {
      AppStateVariant.empty => (AppIcons.folderDashed, AppMessages.emptyTitle, ''),
      AppStateVariant.error => (AppIcons.attention, AppMessages.genericErrorTitle, AppMessages.genericErrorMessage),
      AppStateVariant.offline => (AppIcons.cloud, AppMessages.offlineTitle, AppMessages.offlineMessage),
      AppStateVariant.permissionDenied => (
        AppIcons.lockedTopic,
        AppMessages.permissionDeniedTitle,
        AppMessages.permissionDeniedMessage,
      ),
      AppStateVariant.success => (AppIcons.check, AppMessages.successTitle, ''),
    };
    final resolvedTitle = title ?? defaults.$2;
    final resolvedMessage = message ?? defaults.$3;
    final resolvedMedia = media ?? Icon(icon ?? defaults.$1);

    return Semantics(
      container: true,
      liveRegion: variant != AppStateVariant.empty,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tokens = context.tokens;
          final padding = constraints.maxWidth < tokens.layout.compact ? tokens.spacing.xxl : tokens.spacing.huge;
          final minimumHeight = constraints.hasBoundedHeight ? constraints.maxHeight : tokens.spacing.none;
          final body = ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              minHeight: minimumHeight,
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: LayoutBuilder(
                builder: (context, contentConstraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: contentConstraints.hasBoundedHeight
                          ? contentConstraints.maxHeight
                          : tokens.spacing.none,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AppStateHeader(
                            title: resolvedTitle,
                            message: resolvedMessage,
                            media: showMedia ? resolvedMedia : null,
                            mediaVariant: mediaVariant,
                          ),
                          if (_hasContent) ...[
                            SizedBox(height: tokens.spacing.xxl),
                            _AppStateContent(
                              actionLabel: actionLabel,
                              onAction: onAction,
                              secondaryActionLabel: secondaryActionLabel,
                              onSecondaryAction: onSecondaryAction,
                              content: content,
                              footer: footer,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          return switch (surface) {
            AppStateSurface.plain => ClipRRect(
              borderRadius: tokens.borders.lg,
              child: body,
            ),
            AppStateSurface.outline => AppDashedContainer(
              color: tokens.colors.border,
              borderRadius: tokens.borders.lg,
              child: body,
            ),
            AppStateSurface.muted => ClipRRect(
              borderRadius: tokens.borders.lg,
              child: ColoredBox(
                color: Color.lerp(
                  tokens.colors.surface,
                  tokens.colors.surfaceSubtle,
                  tokens.opacity.half,
                )!,
                child: body,
              ),
            ),
          };
        },
      ),
    );
  }

  bool get _hasContent => content != null || actionLabel != null || secondaryActionLabel != null || footer != null;
}

class _AppStateHeader extends StatelessWidget {
  const _AppStateHeader({
    required this.title,
    required this.message,
    required this.media,
    required this.mediaVariant,
  });

  final String title;
  final String message;
  final Widget? media;
  final AppStateMediaVariant mediaVariant;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tokens.layout.dialogMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (media != null) ...[
            _AppStateMedia(variant: mediaVariant, child: media!),
            SizedBox(height: tokens.spacing.lg),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: tokens.typography.titleLarge.copyWith(fontWeight: FontWeight.w500),
          ),
          if (message.isNotEmpty) ...[
            SizedBox(height: tokens.spacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.colors.onSurfaceMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppStateMedia extends StatelessWidget {
  const _AppStateMedia({required this.variant, required this.child});

  final AppStateMediaVariant variant;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (variant == AppStateMediaVariant.custom) return child;
    final tokens = context.tokens;
    return IconTheme.merge(
      data: IconThemeData(
        size: tokens.icons.lg,
        color: tokens.colors.onSurface,
      ),
      child: Container(
        width: tokens.sizes.iconContainerSm,
        height: tokens.sizes.iconContainerSm,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.colors.surfaceSubtle,
          borderRadius: tokens.borders.lg,
        ),
        child: ExcludeSemantics(child: child),
      ),
    );
  }
}

class _AppStateContent extends StatelessWidget {
  const _AppStateContent({
    required this.actionLabel,
    required this.onAction,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
    required this.content,
    required this.footer,
  });

  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Widget? content;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final standardActions = actionLabel == null && secondaryActionLabel == null
        ? null
        : Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.sm,
            alignment: WrapAlignment.center,
            children: [
              if (actionLabel != null) AppButton(label: actionLabel!, onPressed: onAction),
              if (secondaryActionLabel != null)
                AppButton(
                  label: secondaryActionLabel!,
                  variant: AppButtonVariant.outline,
                  onPressed: onSecondaryAction,
                ),
            ],
          );
    final mainContent = content ?? standardActions;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tokens.layout.dialogMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mainContent != null) Align(child: mainContent),
          if (mainContent != null && footer != null) SizedBox(height: tokens.spacing.lg),
          if (footer != null) Align(child: footer),
        ],
      ),
    );
  }
}
