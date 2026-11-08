import 'package:flutter/material.dart';

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
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      isSelected: selected,
      autofocus: autofocus,
      constraints: BoxConstraints.tightFor(
        width: context.tokens.layout.controlHeight,
        height: context.tokens.layout.controlHeight,
      ),
      style: ButtonStyle(
        side: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? BorderSide(color: context.tokens.colors.focusRing, width: context.tokens.borders.widthStrong)
              : BorderSide.none,
        ),
      ),
      icon: Icon(icon, size: context.tokens.icons.md),
    ),
  );
}
