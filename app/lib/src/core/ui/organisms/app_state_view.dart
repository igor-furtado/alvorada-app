import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';

enum AppStateVariant { empty, error, offline, permissionDenied, success }

class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.variant,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final AppStateVariant variant;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final defaults = switch (variant) {
      AppStateVariant.empty => (AppIcons.search, AppMessages.emptyTitle, ''),
      AppStateVariant.error => (AppIcons.attention, AppMessages.genericErrorTitle, AppMessages.genericErrorMessage),
      AppStateVariant.offline => (AppIcons.attention, AppMessages.offlineTitle, AppMessages.offlineMessage),
      AppStateVariant.permissionDenied => (
        AppIcons.lockedTopic,
        AppMessages.permissionDeniedTitle,
        AppMessages.permissionDeniedMessage,
      ),
      AppStateVariant.success => (AppIcons.check, AppMessages.successTitle, ''),
    };
    final resolvedTitle = title ?? defaults.$2;
    final resolvedMessage = message ?? defaults.$3;
    return Semantics(
      liveRegion: variant != AppStateVariant.empty,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.noteMaxWidth),
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: context.tokens.layout.controlHeight,
                  height: context.tokens.layout.controlHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.tokens.colors.surfaceSubtle,
                    borderRadius: context.tokens.borders.lg,
                  ),
                  child: Icon(
                    defaults.$1,
                    size: context.tokens.icons.sm,
                    color: context.tokens.colors.actionForeground,
                  ),
                ),
                SizedBox(height: context.tokens.spacing.md),
                Text(resolvedTitle, textAlign: TextAlign.center, style: context.tokens.typography.labelLarge),
                if (resolvedMessage.isNotEmpty) ...[
                  SizedBox(height: context.tokens.spacing.sm),
                  Text(
                    resolvedMessage,
                    textAlign: TextAlign.center,
                    style: context.tokens.typography.bodySmall.copyWith(
                      color: context.tokens.colors.onSurfaceMuted,
                    ),
                  ),
                ],
                if (actionLabel != null) ...[
                  SizedBox(height: context.tokens.spacing.lg),
                  AppButton(label: actionLabel!, onPressed: onAction),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
