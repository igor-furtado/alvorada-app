import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import 'concursos_list_actions.dart';
import 'concursos_list_bloc.dart';
import 'concursos_list_event.dart';
import 'concursos_list_state.dart';
import 'concursos_timeline.dart';

class ConcursosListView extends StatelessWidget {
  const ConcursosListView({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<ConcursosListBloc, ConcursosListState>(
    listenWhen: (previous, current) => previous.feedback != current.feedback && current.feedback != null,
    listener: (context, state) => _showFeedback(context, state.feedback!),
    buildWhen: (previous, current) =>
        previous.status != current.status ||
        previous.items != current.items ||
        previous.isRefreshing != current.isRefreshing ||
        previous.isMutating != current.isMutating,
    builder: (context, state) => switch (state.status) {
      ConcursosListStatus.initial || ConcursosListStatus.loading => const _ConcursosListLoading(),
      ConcursosListStatus.failure => AppStateView(
        variant: AppStateVariant.error,
        actionLabel: AppMessages.tryAgain,
        onAction: () => context.read<ConcursosListBloc>().add(
          const ConcursosListLoadRequested(),
        ),
      ),
      ConcursosListStatus.success when state.items.isEmpty => AppStateView(
        variant: AppStateVariant.empty,
        title: AppMessages.nenhumConcursoAtivo,
        message: AppMessages.concursosEmpty,
        icon: AppIcons.concursos,
        actionLabel: AppMessages.novoConcurso,
        onAction: state.canMutate ? () => ConcursosListActions.add(context) : null,
      ),
      ConcursosListStatus.success => ConcursosTimeline(
        concursos: state.items,
        enabled: state.canMutate,
        actions: ConcursosTimelineActions(
          details: (concurso) => ConcursosListActions.details(context, concurso),
          openEdital: (concurso) => ConcursosListActions.openEdital(context, concurso),
          edit: (concurso) => ConcursosListActions.edit(context, concurso),
          prioritize: (concurso) => ConcursosListActions.prioritize(context, concurso),
          archive: (concurso) => ConcursosListActions.archive(context, concurso),
          delete: (concurso) => ConcursosListActions.delete(context, concurso),
        ),
      ),
    },
  );
}

class _ConcursosListLoading extends StatelessWidget {
  const _ConcursosListLoading();

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppMessages.carregandoConcursos,
    liveRegion: true,
    child: Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          AppSkeleton(height: context.tokens.sizes.overviewPanel),
          if (index != 2) SizedBox(height: context.tokens.spacing.xl),
        ],
      ],
    ),
  );
}

void _showFeedback(
  BuildContext context,
  ConcursosListFeedback feedback,
) {
  switch (feedback.type) {
    case ConcursosListFeedbackType.archived:
      final concurso = feedback.concurso;
      if (concurso == null) return;
      AppToast.show(
        context,
        title: AppMessages.concursoArquivado(concurso.instituicao),
        variant: AppToastVariant.success,
        actionLabel: AppMessages.undo,
        onAction: () => context.read<ConcursosListBloc>().add(
          ConcursoRestoreRequested(concurso.id),
        ),
      );
    case ConcursosListFeedbackType.updated:
      _toast(context, AppMessages.concursoAtualizado, AppToastVariant.success);
    case ConcursosListFeedbackType.created:
      _toast(context, AppMessages.concursoCriado, AppToastVariant.success);
    case ConcursosListFeedbackType.prioritized:
      _toast(context, AppMessages.concursoPriorizado, AppToastVariant.success);
    case ConcursosListFeedbackType.restored:
      _toast(context, AppMessages.concursoRestaurado, AppToastVariant.success);
    case ConcursosListFeedbackType.deleted:
      _toast(context, AppMessages.concursoExcluido, AppToastVariant.success);
    case ConcursosListFeedbackType.refreshFailed:
      _toast(
        context,
        AppMessages.contentUpdateFailed,
        AppToastVariant.error,
      );
    case ConcursosListFeedbackType.synchronizationPending:
      AppToast.show(
        context,
        title: AppMessages.concursosSincronizacaoPendente,
        variant: AppToastVariant.info,
        actionLabel: AppMessages.update,
        onAction: () => context.read<ConcursosListBloc>().add(
          const ConcursosListRefreshRequested(forceRefresh: true),
        ),
      );
    case ConcursosListFeedbackType.operationFailed:
      _toast(
        context,
        AppMessages.concursoOperacaoFalhou,
        AppToastVariant.error,
      );
  }
}

void _toast(
  BuildContext context,
  String message,
  AppToastVariant variant,
) {
  AppToast.show(context, title: message, variant: variant);
}
