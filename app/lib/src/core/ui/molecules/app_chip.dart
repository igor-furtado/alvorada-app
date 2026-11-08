import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_icon.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.selected = false,
    this.enabled = true,
    this.icon,
    this.onSelected,
    this.onDeleted,
    super.key,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final IconData? icon;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    selected: selected,
    enabled: enabled,
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? onSelected : null,
      avatar: icon == null ? null : AppIcon(icon!, size: AppIconSize.sm),
      onDeleted: enabled ? onDeleted : null,
      deleteIcon: onDeleted == null ? null : const AppIcon(AppIcons.close, size: AppIconSize.sm),
      padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm, vertical: context.tokens.spacing.xxs),
    ),
  );
}
