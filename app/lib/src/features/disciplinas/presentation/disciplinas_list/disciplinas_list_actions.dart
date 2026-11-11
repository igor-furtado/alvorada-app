import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/ui/app_ui.dart';
import '../disciplinas_form/disciplinas_form_view.dart';
import 'disciplinas_list_bloc.dart';
import 'disciplinas_list_event.dart';
import 'disciplinas_list_state.dart';

abstract final class DisciplinasListActions {
  static Future<void> add(BuildContext context) async {
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => const DisciplinasFormView(),
    );
    if (saved == true && context.mounted) {
      context.read<DisciplinasListBloc>().add(
        const DisciplinasListRefreshRequested(
          feedback: DisciplinasListFeedback.created,
        ),
      );
    }
  }

  static Future<void> rename(
    BuildContext context,
    DisciplinaListItemData disciplina,
  ) async {
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => DisciplinasFormView(disciplina: disciplina),
    );
    if (saved == true && context.mounted) {
      context.read<DisciplinasListBloc>().add(
        const DisciplinasListRefreshRequested(
          feedback: DisciplinasListFeedback.renamed,
        ),
      );
    }
  }

  static Future<void> delete(
    BuildContext context,
    DisciplinaListItemData disciplina,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppAlertDialog(
        title: AppMessages.deleteDisciplineQuestion,
        description: AppMessages.disciplineDeletedImpact(disciplina.name),
        cancelLabel: AppMessages.cancel,
        onCancel: () => Navigator.pop(dialogContext, false),
        actionLabel: AppMessages.delete,
        onAction: () => Navigator.pop(dialogContext, true),
        destructive: true,
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<DisciplinasListBloc>().add(
        DisciplinasListDeleteRequested(disciplina.id),
      );
    }
  }
}
