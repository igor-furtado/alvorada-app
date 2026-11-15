import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../disciplinas_list/disciplinas_list_state.dart';

class TopicosListHeader extends StatelessWidget {
  const TopicosListHeader({
    required this.disciplina,
    required this.canAdd,
    required this.canMutateDiscipline,
    required this.onAdd,
    required this.onRenameDiscipline,
    required this.onDeleteDiscipline,
    super.key,
  });

  final DisciplinaListItemData disciplina;
  final bool canAdd;
  final bool canMutateDiscipline;
  final VoidCallback onAdd;
  final VoidCallback? onRenameDiscipline;
  final VoidCallback? onDeleteDiscipline;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            disciplina.name,
            style: context.tokens.typography.titleLarge,
          ),
          SizedBox(height: context.tokens.spacing.xxs),
          Text(
            context.l10n.topicCountInCatalog(disciplina.topicCount),
            style: context.tokens.typography.bodySmall.copyWith(
              color: context.tokens.colors.onSurfaceMuted,
            ),
          ),
        ],
      );
      final actions = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAccessibleIconButton(
            icon: AppIcons.add,
            label: context.l10n.addTopics,
            variant: AppIconButtonVariant.primary,
            onPressed: canAdd ? onAdd : null,
          ),
          SizedBox(width: context.tokens.spacing.xs),
          AppAccessibleIconButton(
            icon: AppIcons.edit,
            label: context.l10n.editDiscipline,
            onPressed: canMutateDiscipline ? onRenameDiscipline : null,
          ),
          SizedBox(width: context.tokens.spacing.xs),
          AppAccessibleIconButton(
            icon: AppIcons.delete,
            label: context.l10n.deleteDiscipline,
            onPressed: canMutateDiscipline ? onDeleteDiscipline : null,
          ),
        ],
      );
      if (constraints.maxWidth < context.tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            SizedBox(height: context.tokens.spacing.sm),
            Align(alignment: Alignment.centerRight, child: actions),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: heading),
          SizedBox(width: context.tokens.spacing.lg),
          actions,
        ],
      );
    },
  );
}
