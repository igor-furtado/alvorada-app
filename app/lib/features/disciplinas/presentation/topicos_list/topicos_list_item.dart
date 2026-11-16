import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'topicos_list_state.dart';

enum _TopicAction { edit, delete }

class TopicoListItem extends StatelessWidget {
  const TopicoListItem({
    required this.index,
    required this.topico,
    required this.canMutate,
    required this.onRename,
    required this.onDelete,
    this.reorderIndex,
    super.key,
  });

  final int index;
  final TopicoListItemData topico;
  final bool canMutate;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final int? reorderIndex;

  @override
  Widget build(BuildContext context) {
    final number = Text(
      index.toString().padLeft(2, '0'),
      style: context.tokens.typography.labelMedium,
    );
    return AppListItem(
      title: topico.name,
      subtitle: topico.mandatory ? context.l10n.mandatoryTopic : null,
      media: SizedBox(
        width: context.tokens.icons.lg,
        child: number,
      ),
      trailing: topico.mandatory
          ? const Icon(AppIcons.lockedTopic, size: 17)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (reorderIndex case final index?)
                  ReorderableDragStartListener(
                    index: index,
                    child: Tooltip(
                      message: context.l10n.reorderTopic,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Padding(
                          padding: EdgeInsets.all(context.tokens.spacing.sm),
                          child: const Icon(AppIcons.reorder, size: 18),
                        ),
                      ),
                    ),
                  ),
                AppMenuButton<_TopicAction>(
                  icon: AppIcons.edit,
                  label: '${context.l10n.editTopic}: ${topico.name}',
                  enabled: canMutate,
                  onSelected: (action) {
                    switch (action) {
                      case _TopicAction.edit:
                        onRename();
                      case _TopicAction.delete:
                        onDelete();
                    }
                  },
                  items: [
                    AppMenuItem(
                      value: _TopicAction.edit,
                      label: context.l10n.editTopic,
                      icon: AppIcons.edit,
                    ),
                    AppMenuItem(
                      value: _TopicAction.delete,
                      label: context.l10n.delete,
                      icon: AppIcons.delete,
                      destructive: true,
                    ),
                  ],
                ),
              ],
            ),
      size: AppListItemSize.sm,
    );
  }
}
