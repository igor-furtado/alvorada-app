import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_accessible_icon_button.dart';
import '../atoms/app_divider.dart';

@immutable
class AppSidebarItem<T> {
  const AppSidebarItem({required this.value, required this.label, required this.icon});

  final T value;
  final String label;
  final IconData icon;
}

class AppSidebar<T> extends StatelessWidget {
  const AppSidebar({
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.header,
    this.footer,
    this.collapsed = false,
    super.key,
  });

  final List<AppSidebarItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelected;
  final Widget? header;
  final Widget? footer;
  final bool collapsed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppMessages.navigationSection,
    container: true,
    child: SizedBox(
      width: collapsed ? context.tokens.layout.iconRailWidth : context.tokens.layout.catalogMasterWidth,
      child: Material(
        color: context.tokens.colors.surface,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: context.tokens.colors.border)),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null) ...[
                  Padding(padding: EdgeInsets.all(context.tokens.spacing.lg), child: header),
                  const AppDivider(margin: EdgeInsets.zero),
                ],
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(context.tokens.spacing.sm),
                    children: [
                      for (final item in items)
                        Padding(
                          padding: EdgeInsets.only(bottom: context.tokens.spacing.xxs),
                          child: collapsed
                              ? AppAccessibleIconButton(
                                  icon: item.icon,
                                  label: item.label,
                                  selected: item.value == selectedValue,
                                  onPressed: () => onSelected(item.value),
                                )
                              : ListTile(
                                  selected: item.value == selectedValue,
                                  leading: Icon(item.icon, size: context.tokens.icons.md),
                                  title: Text(item.label),
                                  onTap: () => onSelected(item.value),
                                ),
                        ),
                    ],
                  ),
                ),
                if (footer != null) ...[
                  const AppDivider(margin: EdgeInsets.zero),
                  Padding(padding: EdgeInsets.all(context.tokens.spacing.lg), child: footer),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
