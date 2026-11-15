import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'disciplinas_list_actions.dart';
import 'disciplinas_list_bloc.dart';
import 'disciplinas_list_event.dart';
import 'disciplinas_list_panel.dart';
import 'disciplinas_list_state.dart';

class DisciplinasListView extends StatelessWidget {
  const DisciplinasListView({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<DisciplinasListBloc, DisciplinasListState>(
    listenWhen: (previous, current) => previous.feedback != current.feedback && current.feedback != null,
    listener: (context, state) => _showFeedback(context, state.feedback!),
    buildWhen: (previous, current) =>
        previous.status != current.status ||
        previous.items != current.items ||
        previous.query != current.query ||
        previous.selectedDisciplineId != current.selectedDisciplineId ||
        previous.isRefreshing != current.isRefreshing ||
        previous.isDeleting != current.isDeleting,
    builder: (context, state) => switch (state.status) {
      DisciplinasListStatus.loading => AppSkeleton(
        height: context.tokens.listItemMediaHeight,
        semanticLabel: context.l10n.loadingDisciplines,
      ),
      DisciplinasListStatus.failure => AppStateView(
        variant: AppStateVariant.error,
        actionLabel: context.l10n.tryAgain,
        onAction: () => context.read<DisciplinasListBloc>().add(const DisciplinasListLoadRequested()),
      ),
      _ => DisciplinasListPanel(
        state: state,
        onAdd: () => DisciplinasListActions.add(context),
        onSelect: (item) => context.read<DisciplinasListBloc>().add(DisciplinasListSelectionChanged(item.id)),
      ),
    },
  );
}

void _showFeedback(BuildContext context, DisciplinasListFeedback feedback) {
  final (message, variant) = switch (feedback) {
    DisciplinasListFeedback.updated => (context.l10n.disciplinesUpdated, AppToastVariant.success),
    DisciplinasListFeedback.created => (context.l10n.disciplineCreated, AppToastVariant.success),
    DisciplinasListFeedback.renamed => (context.l10n.disciplineUpdated, AppToastVariant.success),
    DisciplinasListFeedback.deleted => (context.l10n.disciplineDeleted, AppToastVariant.success),
    DisciplinasListFeedback.refreshFailed => (context.l10n.contentUpdateFailed, AppToastVariant.error),
    DisciplinasListFeedback.synchronizationPending => (context.l10n.contentSavedSyncPending, AppToastVariant.info),
    DisciplinasListFeedback.operationFailed => (context.l10n.contentOperationFailed, AppToastVariant.error),
  };
  AppToast.show(context, title: message, variant: variant);
}
