import 'package:flutter/material.dart';

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
    final background = switch (variant) {
      AppButtonVariant.primary => tokens.colors.primary,
      AppButtonVariant.secondary => scheme.secondaryContainer,
      AppButtonVariant.destructive => scheme.error,
      AppButtonVariant.outline || AppButtonVariant.text => tokens.colors.transparent,
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
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.square(tokens.layout.controlHeight)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: tokens.borders.md)),
      textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.labelLarge),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? scheme.onSurface.withValues(alpha: tokens.opacity.disabled)
            : foreground,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? scheme.onSurface.withValues(alpha: tokens.opacity.tint)
            : background,
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return foreground.withValues(alpha: tokens.opacity.tintStrong);
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
          return foreground.withValues(alpha: tokens.opacity.tint);
        }
        return tokens.colors.transparent;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: tokens.colors.focusRing, width: tokens.borders.widthStrong);
        }
        if (variant != AppButtonVariant.outline) return BorderSide.none;
        return BorderSide(
          color: scheme.outline,
          width: tokens.borders.widthHairline,
        );
      }),
    );
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox.square(
            dimension: tokens.icons.sm,
            child: CircularProgressIndicator(
              color: foreground,
              strokeWidth: tokens.borders.widthStrong,
            ),
          )
        else if (icon != null)
          Icon(icon, size: tokens.icons.sm),
        if (loading || icon != null) SizedBox(width: tokens.spacing.sm),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
    final callback = enabled ? onPressed : null;
    final button = switch (variant) {
      AppButtonVariant.outline => OutlinedButton(
        onPressed: callback,
        autofocus: autofocus,
        style: style,
        child: content,
      ),
      AppButtonVariant.text => TextButton(onPressed: callback, autofocus: autofocus, style: style, child: content),
      _ => FilledButton(onPressed: callback, autofocus: autofocus, style: style, child: content),
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
