import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../topicos_list/topicos_list_state.dart';
import 'subtopicos_list_actions.dart';
import 'subtopicos_list_bloc.dart';
import 'subtopicos_list_header.dart';
import 'subtopicos_list_item.dart';
import 'subtopicos_list_state.dart';

class SubtopicosListView extends StatelessWidget {
  const SubtopicosListView({
    required this.topico,
    required this.canMutateTopic,
    required this.onRenameTopic,
    required this.onDeleteTopic,
    super.key,
  });

  final TopicoListItemData topico;
  final bool canMutateTopic;
  final VoidCallback onRenameTopic;
  final VoidCallback onDeleteTopic;

  @override
  Widget build(BuildContext context) => BlocSelector<SubtopicosListBloc, SubtopicosListState, SubtopicosTopicState?>(
    selector: (state) => state.topic(topico.id),
    builder: (context, state) {
      if (state == null) return const SizedBox.shrink();
      final canMutateSubtopics = canMutateTopic && state.canMutate;
      return RepaintBoundary(
        child: Padding(
          padding: EdgeInsets.only(left: context.tokens.spacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: AppListItemGroup(
              spacing: context.tokens.spacing.xxs,
              children: [
                SubtopicosListHeader(
                  topico: topico,
                  hasItems: state.items.isNotEmpty,
                  canMutateTopic: canMutateTopic,
                  canMutateSubtopics: canMutateSubtopics,
                  onAdd: () => SubtopicosListActions.add(context, topico.id),
                  onRenameTopic: onRenameTopic,
                  onDeleteTopic: onDeleteTopic,
                ),
                for (final subtopico in state.items)
                  SubtopicoListItem(
                    subtopico: subtopico,
                    canMutate: canMutateSubtopics,
                    onRename: () => SubtopicosListActions.rename(
                      context,
                      topico.id,
                      subtopico,
                    ),
                    onDelete: () => SubtopicosListActions.delete(
                      context,
                      subtopico,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
