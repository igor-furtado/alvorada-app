import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/presentation/app_shell_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import '../domain/use_cases/disciplinas_use_cases.dart';
import 'disciplinas_list/disciplinas_list_actions.dart';
import 'disciplinas_list/disciplinas_list_bloc.dart';
import 'disciplinas_list/disciplinas_list_event.dart';
import 'disciplinas_list/disciplinas_list_header.dart';
import 'disciplinas_list/disciplinas_list_state.dart';
import 'disciplinas_list/disciplinas_list_view.dart';
import 'subtopicos_list/subtopicos_list_bloc.dart';
import 'subtopicos_list/subtopicos_list_event.dart';
import 'subtopicos_list/subtopicos_list_state.dart';
import 'topicos_list/topicos_list_bloc.dart';
import 'topicos_list/topicos_list_event.dart';
import 'topicos_list/topicos_list_state.dart';
import 'topicos_list/topicos_list_view.dart';

class DisciplinasPage extends StatelessWidget {
  const DisciplinasPage({
    this.initialQuery = '',
    this.initialOrder = DisciplinasListOrder.catalog,
    super.key,
  });

  final String initialQuery;
  final DisciplinasListOrder initialOrder;

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<DisciplinasUseCases>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DisciplinasListBloc(
            getDisciplinas: useCases.getDisciplinas,
            deleteDisciplina: useCases.deleteDisciplina,
            initialQuery: initialQuery,
            initialOrder: initialOrder,
          )..add(const DisciplinasListLoadRequested()),
        ),
        BlocProvider(
          create: (_) => TopicosListBloc(
            getDisciplinas: useCases.getDisciplinas,
            deleteTopico: useCases.deleteTopico,
          ),
        ),
        BlocProvider(
          create: (_) => SubtopicosListBloc(
            getDisciplinas: useCases.getDisciplinas,
            deleteSubtopico: useCases.deleteSubtopico,
          ),
        ),
      ],
      child: _DisciplinasPageContent(
        routeQuery: initialQuery,
        routeOrder: initialOrder,
      ),
    );
  }
}

class _DisciplinasPageContent extends StatefulWidget {
  const _DisciplinasPageContent({
    required this.routeQuery,
    required this.routeOrder,
  });

  final String routeQuery;
  final DisciplinasListOrder routeOrder;

  @override
  State<_DisciplinasPageContent> createState() => _DisciplinasPageContentState();
}

class _DisciplinasPageContentState extends State<_DisciplinasPageContent> {
  final _shellOwner = Object();
  AppShellController? _shellController;
  Timer? _urlTimer;

  void _configureShellSearch() {
    final controller = _shellController;
    if (controller == null) return;
    final disciplinas = context.read<DisciplinasListBloc>().state;
    final topicos = context.read<TopicosListBloc>().state;
    final subtopicos = context.read<SubtopicosListBloc>().state;
    final canRefresh =
        disciplinas.status == DisciplinasListStatus.success &&
        !disciplinas.isRefreshing &&
        !disciplinas.isDeleting &&
        !topicos.isDeleting &&
        !subtopicos.byTopic.values.any((state) => state.isDeleting);
    controller.setSearch(
      _shellOwner,
      AppShellSearchConfig(
        placeholder: AppMessages.searchContent,
        query: disciplinas.query,
        actionIcon: AppIcons.refresh,
        actionLabel: AppMessages.update,
        onAction: canRefresh ? _refreshAll : null,
        onChanged: (value) {
          if (mounted) {
            context.read<DisciplinasListBloc>().add(
              DisciplinasListSearchChanged(value),
            );
          }
        },
      ),
    );
  }

  void _refreshAll() {
    context.read<DisciplinasListBloc>().add(
      const DisciplinasListRefreshRequested(
        feedback: DisciplinasListFeedback.updated,
        forceRefresh: true,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppShellScope.read(context);
    if (identical(controller, _shellController)) return;
    _shellController?.clearSearch(_shellOwner);
    _shellController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _configureShellSearch();
    });
  }

  @override
  void didUpdateWidget(_DisciplinasPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bloc = context.read<DisciplinasListBloc>();
    if (oldWidget.routeQuery != widget.routeQuery && bloc.state.query != widget.routeQuery) {
      bloc.add(DisciplinasListSearchChanged(widget.routeQuery));
    }
    if (oldWidget.routeOrder != widget.routeOrder && bloc.state.order != widget.routeOrder) {
      bloc.add(DisciplinasListOrderChanged(widget.routeOrder));
    }
  }

  void _synchronizeUrl(DisciplinasListState state) {
    _urlTimer?.cancel();
    final uri = Uri(
      path: '/disciplinas',
      queryParameters: {
        if (state.query.trim().isNotEmpty) 'busca': state.query.trim(),
        if (state.order == DisciplinasListOrder.alphabetical) 'ordem': 'alfabetica',
      },
    );
    if (GoRouterState.of(context).uri == uri) return;
    _urlTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) context.replace(uri.toString());
    });
  }

  @override
  void dispose() {
    _urlTimer?.cancel();
    _shellController?.clearSearch(_shellOwner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<DisciplinasListBloc, DisciplinasListState>(
        listenWhen: (previous, current) => previous.selectedDisciplineId != current.selectedDisciplineId,
        listener: (context, state) {
          context.read<TopicosListBloc>().add(
            TopicosListDisciplineChanged(state.selectedDisciplineId),
          );
          context.read<SubtopicosListBloc>().add(
            SubtopicosListDisciplineChanged(state.selectedDisciplineId),
          );
        },
      ),
      BlocListener<DisciplinasListBloc, DisciplinasListState>(
        listenWhen: (previous, current) => previous.query != current.query || previous.order != current.order,
        listener: (context, state) {
          _configureShellSearch();
          _synchronizeUrl(state);
        },
      ),
      BlocListener<DisciplinasListBloc, DisciplinasListState>(
        listenWhen: (previous, current) =>
            previous.feedback != current.feedback && current.feedback == DisciplinasListFeedback.updated,
        listener: (context, state) {
          context.read<TopicosListBloc>().add(
            const TopicosListRefreshRequested(),
          );
          context.read<SubtopicosListBloc>().add(
            const SubtopicosListRefreshRequested(),
          );
        },
      ),
      BlocListener<TopicosListBloc, TopicosListState>(
        listenWhen: (previous, current) =>
            previous.feedback != current.feedback && current.feedback != null && _topicosChanged(current.feedback!),
        listener: (context, state) {
          context.read<DisciplinasListBloc>().add(
            const DisciplinasListRefreshRequested(),
          );
          context.read<SubtopicosListBloc>().add(
            const SubtopicosListRefreshRequested(),
          );
        },
      ),
      BlocListener<SubtopicosListBloc, SubtopicosListState>(
        listenWhen: (previous, current) => previous.feedback != current.feedback && current.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback!;
          if (_subtopicosChanged(feedback)) {
            context.read<DisciplinasListBloc>().add(
              const DisciplinasListRefreshRequested(),
            );
          }
          _showSubtopicosFeedback(context, feedback);
        },
      ),
      BlocListener<DisciplinasListBloc, DisciplinasListState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.isRefreshing != current.isRefreshing ||
            previous.isDeleting != current.isDeleting,
        listener: (context, state) => _configureShellSearch(),
      ),
      BlocListener<TopicosListBloc, TopicosListState>(
        listenWhen: (previous, current) => previous.isDeleting != current.isDeleting,
        listener: (context, state) => _configureShellSearch(),
      ),
      BlocListener<SubtopicosListBloc, SubtopicosListState>(
        listenWhen: (previous, current) => _hasDeletingSubtopic(previous) != _hasDeletingSubtopic(current),
        listener: (context, state) => _configureShellSearch(),
      ),
    ],
    child: SafeArea(
      top: false,
      child: ResponsiveBuilder(
        builder: (context, windowClass) {
          final pagePadding = windowClass.isExpanded ? context.tokens.spacing.page : context.tokens.spacing.xl;
          return Padding(
            padding: EdgeInsets.all(pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocSelector<DisciplinasListBloc, DisciplinasListState, bool>(
                  selector: (state) => state.canMutate,
                  builder: (context, canAdd) => RepaintBoundary(
                    child: DisciplinasListHeader(
                      canAdd: canAdd,
                      onAdd: () => DisciplinasListActions.add(context),
                    ),
                  ),
                ),
                SizedBox(height: context.tokens.spacing.xxl),
                const Expanded(child: _DisciplinasWorkspace()),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _DisciplinasWorkspace extends StatelessWidget {
  const _DisciplinasWorkspace();

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < context.tokens.layout.contentSplit;
        final master = DisciplinasListView(horizontal: horizontal);
        const detail = TopicosListView();
        if (horizontal) {
          return AppScrollArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                master,
                const AppDivider(margin: EdgeInsets.zero),
                detail,
              ],
            ),
          );
        }
        return AppResizable(
          initialRatio: .25,
          first: AppScrollArea(child: master),
          second: const AppScrollArea(child: detail),
        );
      },
    ),
  );
}

bool _topicosChanged(TopicosListFeedback feedback) => switch (feedback) {
  TopicosListFeedback.created || TopicosListFeedback.renamed || TopicosListFeedback.deleted => true,
  _ => false,
};

bool _subtopicosChanged(SubtopicosListFeedback feedback) => switch (feedback) {
  SubtopicosListFeedback.created || SubtopicosListFeedback.renamed || SubtopicosListFeedback.deleted => true,
  _ => false,
};

bool _hasDeletingSubtopic(SubtopicosListState state) => state.byTopic.values.any(
  (topic) => topic.isDeleting,
);

void _showSubtopicosFeedback(
  BuildContext context,
  SubtopicosListFeedback feedback,
) {
  final (message, variant) = switch (feedback) {
    SubtopicosListFeedback.created => (AppMessages.subtopicCreated, AppToastVariant.success),
    SubtopicosListFeedback.renamed => (AppMessages.subtopicUpdated, AppToastVariant.success),
    SubtopicosListFeedback.deleted => (AppMessages.subtopicDeleted, AppToastVariant.success),
    SubtopicosListFeedback.synchronizationPending => (
      AppMessages.contentSavedSyncPending,
      AppToastVariant.info,
    ),
    SubtopicosListFeedback.operationFailed => (AppMessages.contentOperationFailed, AppToastVariant.error),
  };
  AppToast.show(context, title: message, variant: variant);
}
