import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/ui/app_ui.dart';
import 'subtopicos_list_state.dart';

enum _SubtopicoAction { rename, delete }

class SubtopicoListItem extends StatelessWidget {
  const SubtopicoListItem({
    required this.subtopico,
    required this.canMutate,
    required this.onRename,
    required this.onDelete,
    super.key,
  });

  final SubtopicoListItemData subtopico;
  final bool canMutate;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => AppListItem(
    title: subtopico.name,
    leadingIcon: AppIcons.arrowRight,
    trailing: AppMenuButton<_SubtopicoAction>(
      icon: AppIcons.settings,
      label: '${AppMessages.moreActions}: ${subtopico.name}',
      items: const [
        AppMenuItem(
          value: _SubtopicoAction.rename,
          label: AppMessages.rename,
          icon: AppIcons.edit,
        ),
        AppMenuItem(
          value: _SubtopicoAction.delete,
          label: AppMessages.delete,
          icon: AppIcons.delete,
          destructive: true,
        ),
      ],
      enabled: canMutate,
      onSelected: (action) => switch (action) {
        _SubtopicoAction.rename => onRename(),
        _SubtopicoAction.delete => onDelete(),
      },
    ),
    size: AppListItemSize.sm,
  );
}
