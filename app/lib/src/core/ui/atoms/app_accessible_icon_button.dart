import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';

class AppAccessibleIconButton extends StatelessWidget {
  const AppAccessibleIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.selected = false,
    this.autofocus = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: ShadButton.ghost(
      onPressed: onPressed,
      enabled: onPressed != null,
      autofocus: autofocus,
      width: context.tokens.layout.controlHeight,
      height: context.tokens.layout.controlHeight,
      padding: EdgeInsets.zero,
      backgroundColor: selected ? context.tokens.colors.surfaceSubtle : null,
      child: Icon(icon, size: context.tokens.icons.md),
    ),
  );
}
