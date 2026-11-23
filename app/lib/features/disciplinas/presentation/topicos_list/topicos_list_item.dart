import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'topicos_list_state.dart';

class TopicoListItem extends StatelessWidget {
  const TopicoListItem({
    required this.index,
    required this.topico,
    this.reorderIndex,
    super.key,
  });

  final int index;
  final TopicoListItemData topico;
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
          : reorderIndex != null
          ? ReorderableDragStartListener(
              index: reorderIndex!,
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
            )
          : null,
      size: AppListItemSize.sm,
    );
  }
}
