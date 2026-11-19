import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'disciplinas_list_item.dart';
import 'disciplinas_list_state.dart';

class DisciplinasListPanel extends StatelessWidget {
  const DisciplinasListPanel({
    required this.state,
    required this.onSelect,
    required this.onReorder,
    super.key,
  });

  final DisciplinasListState state;
  final ValueChanged<DisciplinaListItemData> onSelect;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final canReorder = state.canMutate && state.query.trim().isEmpty && state.items.length > 1;
    return Padding(
      padding: EdgeInsets.all(context.tokens.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.tokens.spacing.md,
              context.tokens.spacing.xs,
              context.tokens.spacing.md,
              context.tokens.spacing.sm,
            ),
            child: Text(
              context.l10n.navigationDisciplines.toUpperCase(),
              style: context.tokens.typography.catalogOverline,
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: state.items.length,
              onReorderItem: onReorder,
              itemBuilder: (context, index) {
                final disciplina = state.items[index];
                return Padding(
                  key: ValueKey('discipline-${disciplina.id}'),
                  padding: EdgeInsets.only(
                    bottom: index == state.items.length - 1 ? 0 : context.tokens.spacing.xxs,
                  ),
                  child: DisciplinaListItem(
                    disciplina: disciplina,
                    selected: state.selectedDisciplineId == disciplina.id,
                    reorderIndex: canReorder ? index : null,
                    onSelect: () => onSelect(disciplina),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
