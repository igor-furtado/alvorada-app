import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/ui/app_ui.dart';
import '../topicos_list/topicos_list_state.dart';

enum _TopicoAction { rename, delete }

class SubtopicosListHeader extends StatelessWidget {
  const SubtopicosListHeader({
    required this.topico,
    required this.hasItems,
    required this.canMutateTopic,
    required this.canMutateSubtopics,
    required this.onAdd,
    required this.onRenameTopic,
    required this.onDeleteTopic,
    super.key,
  });

  final TopicoListItemData topico;
  final bool hasItems;
  final bool canMutateTopic;
  final bool canMutateSubtopics;
  final VoidCallback onAdd;
  final VoidCallback onRenameTopic;
  final VoidCallback onDeleteTopic;

  @override
  Widget build(BuildContext context) => AppListItem(
    title: hasItems ? AppMessages.subtopics : AppMessages.noSubtopics,
    leadingIcon: AppIcons.book,
    trailing: AppButtonGroup(
      children: [
        AppButton(
          label: AppMessages.addSubtopic,
          icon: AppIcons.add,
          variant: AppButtonVariant.text,
          size: AppButtonSize.sm,
          onPressed: canMutateSubtopics ? onAdd : null,
        ),
        AppMenuButton<_TopicoAction>(
          icon: AppIcons.settings,
          label: '${AppMessages.moreActions}: ${topico.name}',
          items: const [
            AppMenuItem(
              value: _TopicoAction.rename,
              label: AppMessages.rename,
              icon: AppIcons.edit,
            ),
            AppMenuItem(
              value: _TopicoAction.delete,
              label: AppMessages.delete,
              icon: AppIcons.delete,
              destructive: true,
            ),
          ],
          enabled: canMutateTopic,
          onSelected: (action) => switch (action) {
            _TopicoAction.rename => onRenameTopic(),
            _TopicoAction.delete => onDeleteTopic(),
          },
        ),
      ],
    ),
    variant: AppListItemVariant.muted,
    size: AppListItemSize.xs,
  );
}
