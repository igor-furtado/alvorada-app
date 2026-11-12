import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
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
        height: context.tokens.sizes.listItemHeaderHeight,
        semanticLabel: AppMessages.loadingDisciplines,
      ),
      DisciplinasListStatus.failure => AppStateView(
        variant: AppStateVariant.error,
        actionLabel: AppMessages.tryAgain,
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
    DisciplinasListFeedback.updated => (AppMessages.disciplinesUpdated, AppToastVariant.success),
    DisciplinasListFeedback.created => (AppMessages.disciplineCreated, AppToastVariant.success),
    DisciplinasListFeedback.renamed => (AppMessages.disciplineUpdated, AppToastVariant.success),
    DisciplinasListFeedback.deleted => (AppMessages.disciplineDeleted, AppToastVariant.success),
    DisciplinasListFeedback.refreshFailed => (AppMessages.contentUpdateFailed, AppToastVariant.error),
    DisciplinasListFeedback.synchronizationPending => (AppMessages.contentSavedSyncPending, AppToastVariant.info),
    DisciplinasListFeedback.operationFailed => (AppMessages.contentOperationFailed, AppToastVariant.error),
  };
  AppToast.show(context, title: message, variant: variant);
}
