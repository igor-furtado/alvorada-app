part of 'disciplinas_catalog.dart';

class _DisciplinasMasterPanel extends StatelessWidget {
  const _DisciplinasMasterPanel({
    required this.disciplinas,
    required this.selectedDisciplina,
    required this.horizontal,
    required this.canMutate,
    required this.onSelect,
    required this.onRename,
    required this.onDelete,
  });

  final List<Disciplina> disciplinas;
  final Disciplina? selectedDisciplina;
  final bool horizontal;
  final bool canMutate;
  final ValueChanged<Disciplina> onSelect;
  final ValueChanged<Disciplina> onRename;
  final ValueChanged<Disciplina> onDelete;

  @override
  Widget build(BuildContext context) {
    final items = disciplinas
        .map((disciplina) {
          final selected = selectedDisciplina?.id == disciplina.id;
          return SizedBox(
            width: horizontal ? context.tokens.sizes.overviewPanel : null,
            child: AppListItem(
              key: ValueKey('discipline-selector-${disciplina.id}'),
              title: disciplina.name,
              subtitle: AppMessages.topicCount(disciplina.topics.length),
              leadingIcon: AppIcons.bookText,
              trailing: selected
                  ? AppMenuButton<_DisciplinaAction>(
                      icon: AppIcons.more,
                      label: '${AppMessages.moreActions}: ${disciplina.name}',
                      items: const [
                        AppMenuItem(
                          value: _DisciplinaAction.rename,
                          label: AppMessages.rename,
                          icon: AppIcons.edit,
                        ),
                        AppMenuItem(
                          value: _DisciplinaAction.delete,
                          label: AppMessages.delete,
                          icon: AppIcons.delete,
                          destructive: true,
                        ),
                      ],
                      enabled: canMutate,
                      onSelected: (action) => switch (action) {
                        _DisciplinaAction.rename => onRename(disciplina),
                        _DisciplinaAction.delete => onDelete(disciplina),
                      },
                    )
                  : null,
              selected: selected,
              onTap: () => onSelect(disciplina),
            ),
          );
        })
        .toList(growable: false);
    return Padding(
      padding: EdgeInsets.all(context.tokens.spacing.sm),
      child: horizontal
          ? AppScrollArea(
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
          : AppListItemGroup(
              spacing: context.tokens.spacing.xxs,
              children: items,
            ),
    );
  }
}
