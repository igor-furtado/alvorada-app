import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import 'disciplinas_list_item.dart';
import 'disciplinas_list_state.dart';

class DisciplinasListPanel extends StatelessWidget {
  const DisciplinasListPanel({
    required this.state,
    required this.onAdd,
    required this.onSelect,
    super.key,
  });

  final DisciplinasListState state;
  final VoidCallback onAdd;
  final ValueChanged<DisciplinaListItemData> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final disciplina in state.items)
        DisciplinaListItem(
          disciplina: disciplina,
          selected: state.selectedDisciplineId == disciplina.id,
          onSelect: () => onSelect(disciplina),
        ),
    ];
    return Padding(
      padding: EdgeInsets.all(context.tokens.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: AppMessages.newDiscipline,
              icon: AppIcons.add,
              variant: AppButtonVariant.secondary,
              onPressed: state.canMutate ? onAdd : null,
            ),
          ),
          SizedBox(height: context.tokens.spacing.sm),
          AppListItemGroup(
            spacing: context.tokens.spacing.xxs,
            children: items,
          ),
        ],
      ),
    );
  }
}
