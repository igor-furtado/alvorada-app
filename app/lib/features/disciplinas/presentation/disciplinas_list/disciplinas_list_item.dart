import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'disciplinas_list_state.dart';

class DisciplinaListItem extends StatelessWidget {
  const DisciplinaListItem({
    required this.disciplina,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final DisciplinaListItemData disciplina;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) => AppListItem(
    title: disciplina.name,
    leadingIcon: AppIcons.bookText,
    variant: selected ? AppListItemVariant.primary : AppListItemVariant.plain,
    size: AppListItemSize.sm,
    selected: selected,
    onTap: onSelect,
  );
}
