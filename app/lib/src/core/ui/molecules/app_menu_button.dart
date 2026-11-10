import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_accessible_icon_button.dart';
import '../atoms/app_button.dart';

@immutable
class AppMenuItem<T> {
  const AppMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool destructive;
}

class AppMenuButton<T> extends StatelessWidget {
  const AppMenuButton({
    required this.icon,
    required this.label,
    required this.items,
    required this.onSelected,
    this.triggerLabel,
    this.enabled = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? triggerLabel;
  final bool enabled;
  final List<AppMenuItem<T>> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      label: label,
      button: true,
      enabled: enabled,
      child: PopupMenuButton<T>(
        enabled: enabled,
        tooltip: label,
        color: context.tokens.colors.popover,
        surfaceTintColor: context.tokens.colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: context.tokens.borders.sm,
          side: BorderSide(color: context.tokens.colors.border),
        ),
        constraints: BoxConstraints(minWidth: context.tokens.sizes.navigationBrand),
        onSelected: onSelected,
        itemBuilder: (context) => [
          for (final item in items)
            PopupMenuItem<T>(
              value: item.value,
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: context.tokens.icons.sm,
                      color: item.destructive
                          ? context.tokens.colors.errorForeground
                          : context.tokens.colors.onSurfaceMuted,
                    ),
                    SizedBox(width: context.tokens.spacing.sm),
                  ],
                  Text(
                    item.label,
                    style: context.tokens.typography.labelMedium.copyWith(
                      color: item.destructive ? context.tokens.colors.errorForeground : context.tokens.colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
        ],
        child: IgnorePointer(
          child: triggerLabel == null
              ? AppAccessibleIconButton(
                  icon: icon,
                  label: label,
                  onPressed: enabled ? () {} : null,
                )
              : AppButton(
                  label: triggerLabel!,
                  semanticLabel: label,
                  icon: icon,
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.sm,
                  onPressed: enabled ? () {} : null,
                ),
        ),
      ),
    ),
  );
}
