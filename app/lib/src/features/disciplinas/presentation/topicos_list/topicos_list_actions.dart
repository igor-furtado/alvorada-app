import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/ui/app_ui.dart';
import '../topicos_form/topicos_form_view.dart';
import 'topicos_list_bloc.dart';
import 'topicos_list_event.dart';
import 'topicos_list_state.dart';

abstract final class TopicosListActions {
  static Future<void> add(BuildContext context, String disciplineId) async {
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => TopicosFormView(disciplineId: disciplineId),
    );
    if (saved == true && context.mounted) {
      context.read<TopicosListBloc>().add(
        const TopicosListRefreshRequested(
          feedback: TopicosListFeedback.created,
        ),
      );
    }
  }

  static Future<void> rename(
    BuildContext context,
    String disciplineId,
    TopicoListItemData topico,
  ) async {
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => TopicosFormView(
        disciplineId: disciplineId,
        topico: topico,
      ),
    );
    if (saved == true && context.mounted) {
      context.read<TopicosListBloc>().add(
        const TopicosListRefreshRequested(
          feedback: TopicosListFeedback.renamed,
        ),
      );
    }
  }

  static Future<void> delete(
    BuildContext context,
    TopicoListItemData topico,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppAlertDialog(
        title: AppMessages.deleteTopicQuestion,
        description: AppMessages.topicDeletedImpact(topico.name),
        cancelLabel: AppMessages.cancel,
        onCancel: () => Navigator.pop(dialogContext, false),
        actionLabel: AppMessages.delete,
        onAction: () => Navigator.pop(dialogContext, true),
        destructive: true,
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<TopicosListBloc>().add(
        TopicosListDeleteRequested(topico.id),
      );
    }
  }
}
