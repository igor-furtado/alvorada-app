import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/ui/app_ui.dart';
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
