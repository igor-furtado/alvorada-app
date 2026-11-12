import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/models/concurso.dart';
import '../concursos_form/concursos_form_view.dart';
import 'concursos_list_bloc.dart';
import 'concursos_list_event.dart';
import 'concursos_list_state.dart';

abstract final class ConcursosListActions {
  static Future<void> add(BuildContext context) async {
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => const ConcursosFormView(),
    );
    if (saved == true && context.mounted) {
      context.read<ConcursosListBloc>().add(
        const ConcursosListRefreshRequested(
          feedback: ConcursosListFeedback(
            ConcursosListFeedbackType.created,
          ),
        ),
      );
    }
  }

  static Future<void> edit(BuildContext context, Concurso concurso) async {
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => ConcursosFormView(concurso: concurso),
    );
    if (saved == true && context.mounted) {
      context.read<ConcursosListBloc>().add(
        const ConcursosListRefreshRequested(
          feedback: ConcursosListFeedback(
            ConcursosListFeedbackType.updated,
          ),
        ),
      );
    }
  }

  static void details(BuildContext context, Concurso concurso) {
    context.go(
      '/concursos/${Uri.encodeComponent(concurso.id)}',
    );
  }

  static void openEdital(BuildContext context, Concurso concurso) => details(context, concurso);

  static void prioritize(BuildContext context, Concurso concurso) {
    context.read<ConcursosListBloc>().add(
      ConcursoPrioritarioSetRequested(concurso.id),
    );
  }

  static void archive(BuildContext context, Concurso concurso) {
    context.read<ConcursosListBloc>().add(
      ConcursoArchiveRequested(concurso.id),
    );
  }

  static Future<void> delete(BuildContext context, Concurso concurso) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppAlertDialog(
        title: AppMessages.excluirConcursoQuestion,
        description: AppMessages.excluirConcursoImpacto(concurso.instituicao),
        cancelLabel: AppMessages.cancel,
        actionLabel: AppMessages.excluirConcurso,
        onCancel: () => Navigator.pop(dialogContext, false),
        onAction: () => Navigator.pop(dialogContext, true),
        destructive: true,
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ConcursosListBloc>().add(
        ConcursoDeleteRequested(concurso.id),
      );
    }
  }
}
