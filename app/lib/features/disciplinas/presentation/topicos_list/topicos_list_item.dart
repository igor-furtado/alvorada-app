import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'topicos_list_state.dart';

class TopicoListItem extends StatelessWidget {
  const TopicoListItem({
    required this.index,
    required this.topico,
    required this.canMutate,
    required this.onRename,
    required this.onDelete,
    super.key,
  });

  final int index;
  final TopicoListItemData topico;
  final bool canMutate;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final number = Text(
      index.toString().padLeft(2, '0'),
      style: context.tokens.typography.labelMedium.copyWith(
        color: context.tokens.colors.onSurfaceMuted,
      ),
    );
    return AppListItem(
      title: topico.name,
      media: SizedBox(
        width: context.tokens.icons.lg,
        child: number,
      ),
      trailing: topico.mandatory
          ? Text(
              context.l10n.mandatory,
              style: context.tokens.typography.labelMedium.copyWith(
                color: context.tokens.colors.onSurfaceMuted,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppAccessibleIconButton(
                  icon: AppIcons.edit,
                  label: '${context.l10n.editTopic}: ${topico.name}',
                  onPressed: canMutate ? onRename : null,
                ),
                AppAccessibleIconButton(
                  icon: AppIcons.delete,
                  label: '${context.l10n.delete}: ${topico.name}',
                  onPressed: canMutate ? onDelete : null,
                ),
              ],
            ),
      size: AppListItemSize.sm,
    );
  }
}
