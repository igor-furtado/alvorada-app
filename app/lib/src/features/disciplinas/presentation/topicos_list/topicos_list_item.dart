import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../subtopicos_list/subtopicos_list_view.dart';
import 'topicos_list_state.dart';

class TopicoListItem extends StatelessWidget {
  const TopicoListItem({
    required this.topico,
    required this.canMutate,
    required this.onRename,
    required this.onDelete,
    super.key,
  });

  final TopicoListItemData topico;
  final bool canMutate;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (!topico.mandatory) {
      return SubtopicosListView(
        topico: topico,
        canMutateTopic: canMutate,
        onRenameTopic: onRename,
        onDeleteTopic: onDelete,
      );
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const badge = AppBadge(
            label: AppMessages.protected,
            variant: AppBadgeVariant.secondary,
          );
          final compact = constraints.maxWidth < context.tokens.layout.narrow;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppListItem(
                title: topico.name,
                subtitle: AppMessages.mandatoryTopic,
                leadingIcon: AppIcons.lockedTopic,
                trailing: compact ? null : badge,
                size: AppListItemSize.sm,
              ),
              if (compact)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.tokens.spacing.md,
                    context.tokens.spacing.none,
                    context.tokens.spacing.md,
                    context.tokens.spacing.md,
                  ),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: badge,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
