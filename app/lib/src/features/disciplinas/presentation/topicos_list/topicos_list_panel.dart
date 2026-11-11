import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import 'topicos_list_actions.dart';
import 'topicos_list_header.dart';
import 'topicos_list_item.dart';
import 'topicos_list_state.dart';

class TopicosListPanel extends StatelessWidget {
  const TopicosListPanel({
    required this.state,
    required this.onToggle,
    super.key,
  });

  final TopicosListState state;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final disciplineId = state.disciplineId!;
    final regular = state.regularItems;
    final mandatory = state.mandatoryItems;
    return Padding(
      padding: EdgeInsets.all(context.tokens.spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopicosListHeader(
            canAdd: state.canMutate,
            onAdd: () => TopicosListActions.add(context, disciplineId),
          ),
          SizedBox(height: context.tokens.spacing.md),
          const AppDivider(margin: EdgeInsets.zero),
          if (regular.isNotEmpty)
            AppAccordion<String>(
              expandedValues: state.expandedTopicIds,
              onToggle: onToggle,
              items: [
                for (final topico in regular)
                  AppAccordionItem<String>(
                    value: topico.id,
                    title: AppLabel(topico.name, style: AppLabelStyle.control),
                    child: TopicoListItem(
                      topico: topico,
                      canMutate: state.canMutate,
                      onRename: () => TopicosListActions.rename(
                        context,
                        disciplineId,
                        topico,
                      ),
                      onDelete: () => TopicosListActions.delete(context, topico),
                    ),
                  ),
              ],
            ),
          if (mandatory.isNotEmpty) ...[
            SizedBox(height: context.tokens.spacing.lg),
            AppListItemGroup(
              spacing: context.tokens.spacing.sm,
              children: [
                for (final topico in mandatory)
                  TopicoListItem(
                    topico: topico,
                    canMutate: false,
                    onRename: () {},
                    onDelete: () {},
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
