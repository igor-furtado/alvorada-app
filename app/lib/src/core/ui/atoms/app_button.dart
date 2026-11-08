import 'package:flutter/material.dart';

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
      AppButtonVariant.text => scheme.primary,
      AppButtonVariant.destructive => scheme.onError,
    };
    final background = switch (variant) {
      AppButtonVariant.primary => scheme.primary,
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
        if (variant != AppButtonVariant.outline) return BorderSide.none;
        return BorderSide(
          color: states.contains(WidgetState.focused) ? scheme.primary : scheme.outline,
          width: states.contains(WidgetState.focused) ? tokens.borders.widthStrong : tokens.borders.widthHairline,
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
    return Semantics(
      label: semanticLabel ?? label,
      button: true,
      enabled: enabled,
      child: ExcludeSemantics(child: button),
    );
  }
}
