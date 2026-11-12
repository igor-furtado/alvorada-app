import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum AppIconButtonVariant { ghost, primary }

class AppAccessibleIconButton extends StatelessWidget {
  const AppAccessibleIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.selected = false,
    this.variant = AppIconButtonVariant.ghost,
    this.autofocus = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final AppIconButtonVariant variant;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final primary = variant == AppIconButtonVariant.primary;
    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: IconButton(
          onPressed: onPressed,
          autofocus: autofocus,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            fixedSize: Size.square(context.tokens.layout.controlHeight),
            backgroundColor: primary
                ? context.tokens.colors.primary
                : selected
                ? context.tokens.colors.surfaceSubtle
                : context.tokens.colors.transparent,
            foregroundColor: primary
                ? context.tokens.colors.onPrimary
                : selected
                ? context.tokens.colors.onSurface
                : context.tokens.colors.onSurfaceMuted,
            disabledBackgroundColor: primary ? context.tokens.colors.surfaceSubtle : null,
            disabledForegroundColor: context.tokens.colors.onSurfaceMuted,
            shape: RoundedRectangleBorder(borderRadius: context.tokens.borders.sm),
          ),
          icon: Icon(icon, size: context.tokens.icons.md),
        ),
      ),
    );
  }
}
