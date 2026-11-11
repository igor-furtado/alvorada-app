import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/ui/app_ui.dart';
import '../subtopicos_form/subtopicos_form_view.dart';
import 'subtopicos_list_bloc.dart';
import 'subtopicos_list_event.dart';
import 'subtopicos_list_state.dart';

abstract final class SubtopicosListActions {
  static Future<void> add(BuildContext context, String topicId) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => SubtopicosFormView(topicId: topicId),
    );
    if (saved == true && context.mounted) {
      context.read<SubtopicosListBloc>().add(
        const SubtopicosListRefreshRequested(
          feedback: SubtopicosListFeedback.created,
        ),
      );
    }
  }

  static Future<void> rename(
    BuildContext context,
    String topicId,
    SubtopicoListItemData subtopico,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => SubtopicosFormView(
        topicId: topicId,
        subtopico: subtopico,
      ),
    );
    if (saved == true && context.mounted) {
      context.read<SubtopicosListBloc>().add(
        const SubtopicosListRefreshRequested(
          feedback: SubtopicosListFeedback.renamed,
        ),
      );
    }
  }

  static Future<void> delete(
    BuildContext context,
    SubtopicoListItemData subtopico,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppAlertDialog(
        title: AppMessages.deleteSubtopicQuestion,
        description: AppMessages.subtopicDeletedImpact(subtopico.name),
        cancelLabel: AppMessages.cancel,
        onCancel: () => Navigator.pop(dialogContext, false),
        actionLabel: AppMessages.delete,
        onAction: () => Navigator.pop(dialogContext, true),
        destructive: true,
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<SubtopicosListBloc>().add(
        SubtopicosListDeleteRequested(subtopico.id),
      );
    }
  }
}
