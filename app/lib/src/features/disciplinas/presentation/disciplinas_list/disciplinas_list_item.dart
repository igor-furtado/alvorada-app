import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/ui/app_ui.dart';
import 'disciplinas_list_state.dart';

enum _DisciplinaListAction { rename, delete }

class DisciplinaListItem extends StatelessWidget {
  const DisciplinaListItem({
    required this.disciplina,
    required this.selected,
    required this.canMutate,
    required this.onSelect,
    required this.onRename,
    required this.onDelete,
    this.width,
    super.key,
  });

  final DisciplinaListItemData disciplina;
  final bool selected;
  final bool canMutate;
  final VoidCallback onSelect;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final double? width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: AppListItem(
      title: disciplina.name,
      subtitle: AppMessages.topicCount(disciplina.topicCount),
      leadingIcon: AppIcons.bookText,
      trailing: selected
          ? AppMenuButton<_DisciplinaListAction>(
              icon: AppIcons.more,
              label: '${AppMessages.moreActions}: ${disciplina.name}',
              items: const [
                AppMenuItem(
                  value: _DisciplinaListAction.rename,
                  label: AppMessages.rename,
                  icon: AppIcons.edit,
                ),
                AppMenuItem(
                  value: _DisciplinaListAction.delete,
                  label: AppMessages.delete,
                  icon: AppIcons.delete,
                  destructive: true,
                ),
              ],
              enabled: canMutate,
              onSelected: (action) => switch (action) {
                _DisciplinaListAction.rename => onRename(),
                _DisciplinaListAction.delete => onDelete(),
              },
            )
          : null,
      selected: selected,
      onTap: onSelect,
    ),
  );
}
