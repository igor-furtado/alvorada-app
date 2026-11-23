import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../disciplinas_list/disciplinas_list_state.dart';
import 'topicos_list_actions.dart';
import 'topicos_list_bloc.dart';
import 'topicos_list_event.dart';
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
    final visibleItems = normalizedQuery.isEmpty || disciplineMatches
        ? state.items
        : state.items.where((item) => item.name.toLowerCase().contains(normalizedQuery)).toList(growable: false);
    final regularItems = visibleItems.where((item) => !item.mandatory).toList(growable: false);
    final mandatoryItems = visibleItems.where((item) => item.mandatory).toList(growable: false);
    final canReorder = state.canMutate && normalizedQuery.isEmpty && regularItems.length > 1;
    return Padding(
      padding: EdgeInsets.all(context.tokens.spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopicosListHeader(
            disciplina: disciplina,
            canEditTopics: state.canMutate,
            canMutateDiscipline: canMutateDiscipline,
            onEditTopics: () => TopicosListActions.manage(
              context,
              disciplineId,
              disciplina.name,
              state.items,
            ),
            onRenameDiscipline: onRenameDiscipline,
            onDeleteDiscipline: onDeleteDiscipline,
          ),
          SizedBox(height: context.tokens.spacing.lg),
          const AppDivider(margin: EdgeInsets.zero),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: regularItems.length,
            onReorderItem: (oldIndex, newIndex) => context.read<TopicosListBloc>().add(
              TopicosListReorderRequested(
                oldIndex: oldIndex,
                newIndex: newIndex,
              ),
            ),
            itemBuilder: (context, index) => Column(
              key: ValueKey('topic-${regularItems[index].id}'),
              children: [
                TopicoListItem(
                  index: index + 1,
                  reorderIndex: canReorder ? index : null,
                  topico: regularItems[index],
                ),
                const AppDivider(margin: EdgeInsets.zero),
              ],
            ),
          ),
          for (var index = 0; index < mandatoryItems.length; index++) ...[
            TopicoListItem(
              key: ValueKey('topic-${mandatoryItems[index].id}'),
              index: regularItems.length + index + 1,
              topico: mandatoryItems[index],
            ),
            if (index < mandatoryItems.length - 1) const AppDivider(margin: EdgeInsets.zero),
          ],
        ],
      ),
    );
  }
}
