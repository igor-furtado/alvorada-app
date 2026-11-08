import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_badge.dart';
import '../atoms/app_icon.dart';

class AppListItem extends StatelessWidget {
  const AppListItem({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.badge,
    this.onTap,
    this.selected = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final String? badge;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    selected: selected,
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.lg, vertical: context.tokens.spacing.xxs),
      shape: RoundedRectangleBorder(borderRadius: context.tokens.borders.md),
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      leading: leadingIcon == null ? null : AppIcon(leadingIcon!),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: subtitle == null ? null : Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      trailing: trailing ?? (badge == null ? null : AppBadge(label: badge!)),
      onTap: onTap,
    ),
  );
}
