import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'disciplinas_list_item.dart';
import 'disciplinas_list_state.dart';

class DisciplinasListPanel extends StatelessWidget {
  const DisciplinasListPanel({
    required this.state,
    required this.onSelect,
    super.key,
  });

  final DisciplinasListState state;
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
          AppListItemGroup(
            spacing: context.tokens.spacing.xxs,
            children: items,
          ),
        ],
      ),
    );
  }
}
