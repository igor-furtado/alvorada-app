import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
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
            AppMessages.topicCountInCatalog(disciplina.topicCount),
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
            label: AppMessages.addTopics,
            variant: AppIconButtonVariant.primary,
            onPressed: canAdd ? onAdd : null,
          ),
          SizedBox(width: context.tokens.spacing.xs),
          AppAccessibleIconButton(
            icon: AppIcons.edit,
            label: AppMessages.editDiscipline,
            onPressed: canMutateDiscipline ? onRenameDiscipline : null,
          ),
          SizedBox(width: context.tokens.spacing.xs),
          AppAccessibleIconButton(
            icon: AppIcons.delete,
            label: AppMessages.deleteDiscipline,
            onPressed: canMutateDiscipline ? onDeleteDiscipline : null,
          ),
        ],
      );
      if (constraints.maxWidth < context.tokens.layout.narrow) {
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
