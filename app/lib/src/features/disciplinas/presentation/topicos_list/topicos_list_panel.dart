import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../disciplinas_list/disciplinas_list_state.dart';
import 'topicos_list_actions.dart';
import 'topicos_list_header.dart';
import 'topicos_list_item.dart';
import 'topicos_list_state.dart';

class TopicosListPanel extends StatelessWidget {
  const TopicosListPanel({
    required this.state,
    required this.disciplina,
    required this.query,
    required this.canMutateDiscipline,
    required this.onRenameDiscipline,
    required this.onDeleteDiscipline,
    super.key,
  });

  final TopicosListState state;
  final DisciplinaListItemData disciplina;
  final String query;
  final bool canMutateDiscipline;
  final VoidCallback? onRenameDiscipline;
  final VoidCallback? onDeleteDiscipline;

  @override
  Widget build(BuildContext context) {
    final disciplineId = state.disciplineId!;
    final normalizedQuery = query.trim().toLowerCase();
    final disciplineMatches = disciplina.name.toLowerCase().contains(normalizedQuery);
    final items = normalizedQuery.isEmpty || disciplineMatches
        ? state.items
        : state.items.where((item) => item.name.toLowerCase().contains(normalizedQuery)).toList(growable: false);
    return Padding(
      padding: EdgeInsets.all(context.tokens.spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopicosListHeader(
            disciplina: disciplina,
            canAdd: state.canMutate,
            canMutateDiscipline: canMutateDiscipline,
            onAdd: () => TopicosListActions.add(context, disciplineId),
            onRenameDiscipline: onRenameDiscipline,
            onDeleteDiscipline: onDeleteDiscipline,
          ),
          SizedBox(height: context.tokens.spacing.lg),
          const AppDivider(margin: EdgeInsets.zero),
          for (var index = 0; index < items.length; index++) ...[
            TopicoListItem(
              index: index + 1,
              topico: items[index],
              canMutate: state.canMutate && !items[index].mandatory,
              onRename: () => TopicosListActions.rename(
                context,
                disciplineId,
                items[index],
              ),
              onDelete: () => TopicosListActions.delete(context, items[index]),
            ),
            if (index < items.length - 1) const AppDivider(margin: EdgeInsets.zero),
          ],
        ],
      ),
    );
  }
}
