import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import 'disciplinas_list_item.dart';
import 'disciplinas_list_state.dart';

class DisciplinasListPanel extends StatelessWidget {
  const DisciplinasListPanel({
    required this.state,
    required this.horizontal,
    required this.onOrderChanged,
    required this.onSelect,
    required this.onRename,
    required this.onDelete,
    super.key,
  });

  final DisciplinasListState state;
  final bool horizontal;
  final ValueChanged<DisciplinasListOrder> onOrderChanged;
  final ValueChanged<DisciplinaListItemData> onSelect;
  final ValueChanged<DisciplinaListItemData> onRename;
  final ValueChanged<DisciplinaListItemData> onDelete;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final disciplina in state.items)
        DisciplinaListItem(
          disciplina: disciplina,
          selected: state.selectedDisciplineId == disciplina.id,
          canMutate: state.canMutate,
          width: horizontal ? context.tokens.sizes.overviewPanel : null,
          onSelect: () => onSelect(disciplina),
          onRename: () => onRename(disciplina),
          onDelete: () => onDelete(disciplina),
        ),
    ];
    return Padding(
      padding: EdgeInsets.all(context.tokens.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppMenuButton<DisciplinasListOrder>(
            icon: state.order == DisciplinasListOrder.alphabetical ? AppIcons.sortAscending : AppIcons.arrowsDownUp,
            label: AppMessages.orderDisciplines,
            triggerLabel: state.order == DisciplinasListOrder.alphabetical
                ? AppMessages.alphabeticalDisciplineOrder
                : AppMessages.defaultDisciplineOrder,
            items: const [
              AppMenuItem(
                value: DisciplinasListOrder.catalog,
                label: AppMessages.defaultDisciplineOrder,
                icon: AppIcons.arrowsDownUp,
              ),
              AppMenuItem(
                value: DisciplinasListOrder.alphabetical,
                label: AppMessages.alphabeticalDisciplineOrder,
                icon: AppIcons.sortAscending,
              ),
            ],
            onSelected: onOrderChanged,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          if (horizontal)
            AppScrollArea(
              axis: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    if (index > 0) SizedBox(width: context.tokens.spacing.sm),
                    items[index],
                  ],
                ],
              ),
            )
          else
            AppListItemGroup(
              spacing: context.tokens.spacing.xxs,
              children: items,
            ),
        ],
      ),
    );
  }
}
