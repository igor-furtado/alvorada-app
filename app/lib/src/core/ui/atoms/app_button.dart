import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, outline, text, destructive }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.loading = false,
    this.semanticLabel,
    this.autofocus = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;
  final String? semanticLabel;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !loading;
    final foreground = switch (variant) {
      AppButtonVariant.primary => scheme.onPrimary,
      AppButtonVariant.secondary => scheme.onSecondaryContainer,
      AppButtonVariant.outline => scheme.onSurface,
      AppButtonVariant.text => tokens.colors.actionForeground,
      AppButtonVariant.destructive => scheme.onError,
    };
    final horizontalPadding = switch (size) {
      AppButtonSize.sm => tokens.spacing.md,
      AppButtonSize.md => tokens.spacing.xl,
      AppButtonSize.lg => tokens.spacing.xxl,
    };
    final verticalPadding = switch (size) {
      AppButtonSize.sm => tokens.spacing.sm,
      AppButtonSize.md => tokens.spacing.md,
      AppButtonSize.lg => tokens.spacing.lg,
    };
    final callback = enabled ? onPressed : null;
    final leading = loading
        ? SizedBox.square(
            dimension: tokens.icons.sm,
            child: CircularProgressIndicator(
              color: foreground,
              strokeWidth: tokens.borders.widthStrong,
            ),
          )
        : icon == null
        ? null
        : Icon(icon, size: tokens.icons.sm);
    final padding = EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
    final child = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
    final button = switch (variant) {
      AppButtonVariant.primary => ShadButton(
        onPressed: callback,
        enabled: enabled,
        autofocus: autofocus,
        height: tokens.layout.controlHeight,
        padding: padding,
        leading: leading,
        child: child,
      ),
      AppButtonVariant.secondary => ShadButton.secondary(
        onPressed: callback,
        enabled: enabled,
        autofocus: autofocus,
        height: tokens.layout.controlHeight,
        padding: padding,
        leading: leading,
        child: child,
      ),
      AppButtonVariant.outline => ShadButton.outline(
        onPressed: callback,
        enabled: enabled,
        autofocus: autofocus,
        height: tokens.layout.controlHeight,
        padding: padding,
        leading: leading,
        child: child,
      ),
      AppButtonVariant.text => ShadButton.ghost(
        onPressed: callback,
        enabled: enabled,
        autofocus: autofocus,
        height: tokens.layout.controlHeight,
        padding: padding,
        leading: leading,
        child: child,
      ),
      AppButtonVariant.destructive => ShadButton.destructive(
        onPressed: callback,
        enabled: enabled,
        autofocus: autofocus,
        height: tokens.layout.controlHeight,
        padding: padding,
        leading: leading,
        child: child,
      ),
    };
    if (loading) {
      return Semantics(
        label: '${semanticLabel ?? label}, ${AppMessages.loading}',
        button: true,
        enabled: false,
        liveRegion: true,
        excludeSemantics: true,
        child: button,
      );
    }
    if (semanticLabel == null) return button;
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      onTap: callback,
      excludeSemantics: true,
      child: button,
    );
  }
}
