import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_accessible_icon_button.dart';

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
    super.key,
  });

  final IconData icon;
  final String label;
  final List<AppMenuItem<T>> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => ShadContextMenuRegion(
    tapEnabled: true,
    longPressEnabled: true,
    constraints: BoxConstraints(minWidth: context.tokens.sizes.navigationBrand),
    padding: EdgeInsets.all(context.tokens.spacing.xxs),
    items: [
      for (final item in items)
        ShadContextMenuItem(
          leading: item.icon == null
              ? null
              : Icon(
                  item.icon,
                  size: context.tokens.icons.sm,
                  color: item.destructive ? context.tokens.colors.errorForeground : null,
                ),
          textStyle: item.destructive
              ? Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.tokens.colors.errorForeground,
                )
              : null,
          onPressed: () => onSelected(item.value),
          child: Text(item.label),
        ),
    ],
    child: IgnorePointer(
      child: AppAccessibleIconButton(
        icon: icon,
        label: label,
        onPressed: () {},
      ),
    ),
  );
}
