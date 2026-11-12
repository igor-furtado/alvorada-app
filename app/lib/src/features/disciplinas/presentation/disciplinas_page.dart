import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import '../domain/use_cases/disciplinas_use_cases.dart';
import 'disciplinas_list/disciplinas_list_actions.dart';
import 'disciplinas_list/disciplinas_list_bloc.dart';
import 'disciplinas_list/disciplinas_list_event.dart';
import 'disciplinas_list/disciplinas_list_header.dart';
import 'disciplinas_list/disciplinas_list_state.dart';
import 'disciplinas_list/disciplinas_list_view.dart';
import 'topicos_list/topicos_list_bloc.dart';
import 'topicos_list/topicos_list_event.dart';
import 'topicos_list/topicos_list_state.dart';
import 'topicos_list/topicos_list_view.dart';

class DisciplinasPage extends StatelessWidget {
  const DisciplinasPage({
    this.initialQuery = '',
    super.key,
  });

  final String initialQuery;

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
          )..add(const DisciplinasListLoadRequested()),
        ),
        BlocProvider(
          create: (_) => TopicosListBloc(
            getDisciplinas: useCases.getDisciplinas,
            deleteTopico: useCases.deleteTopico,
          ),
        ),
      ],
      child: _DisciplinasPageContent(
        routeQuery: initialQuery,
      ),
    );
  }
}

class _DisciplinasPageContent extends StatefulWidget {
  const _DisciplinasPageContent({
    required this.routeQuery,
  });

  final String routeQuery;

  @override
  State<_DisciplinasPageContent> createState() => _DisciplinasPageContentState();
}

class _DisciplinasPageContentState extends State<_DisciplinasPageContent> {
  late final TextEditingController _searchController;
  Timer? _urlTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.routeQuery);
  }

  @override
  void didUpdateWidget(_DisciplinasPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bloc = context.read<DisciplinasListBloc>();
    if (oldWidget.routeQuery != widget.routeQuery && bloc.state.query != widget.routeQuery) {
      _searchController.value = TextEditingValue(
        text: widget.routeQuery,
        selection: TextSelection.collapsed(offset: widget.routeQuery.length),
      );
      bloc.add(DisciplinasListSearchChanged(widget.routeQuery));
    }
  }

  void _synchronizeUrl(DisciplinasListState state) {
    _urlTimer?.cancel();
    final uri = Uri(
      path: '/disciplinas',
      queryParameters: {
        if (state.query.trim().isNotEmpty) 'busca': state.query.trim(),
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
    _searchController.dispose();
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
        },
      ),
      BlocListener<DisciplinasListBloc, DisciplinasListState>(
        listenWhen: (previous, current) => previous.query != current.query,
        listener: (context, state) => _synchronizeUrl(state),
      ),
      BlocListener<DisciplinasListBloc, DisciplinasListState>(
        listenWhen: (previous, current) =>
            previous.feedback != current.feedback && current.feedback == DisciplinasListFeedback.updated,
        listener: (context, state) {
          context.read<TopicosListBloc>().add(
            const TopicosListRefreshRequested(),
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
        },
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
                RepaintBoundary(
                  child: DisciplinasListHeader(
                    searchController: _searchController,
                    onSearchChanged: (value) => context.read<DisciplinasListBloc>().add(
                      DisciplinasListSearchChanged(value),
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
  Widget build(BuildContext context) => BlocBuilder<DisciplinasListBloc, DisciplinasListState>(
    buildWhen: (previous, current) =>
        previous.items != current.items ||
        previous.query != current.query ||
        previous.selectedDisciplineId != current.selectedDisciplineId ||
        previous.canMutate != current.canMutate,
    builder: (context, state) {
      final selected = state.items.where((item) => item.id == state.selectedDisciplineId).firstOrNull;
      const master = DisciplinasListView();
      final detail = TopicosListView(
        disciplina: selected,
        query: state.query,
        canMutateDiscipline: state.canMutate,
        onRenameDiscipline: selected == null ? null : () => DisciplinasListActions.rename(context, selected),
        onDeleteDiscipline: selected == null ? null : () => DisciplinasListActions.delete(context, selected),
      );
      return AppCard(
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < context.tokens.layout.contentSplit;
            if (stacked) {
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
              first: const AppScrollArea(child: DisciplinasListView()),
              second: AppScrollArea(child: detail),
            );
          },
        ),
      );
    },
  );
}

bool _topicosChanged(TopicosListFeedback feedback) => switch (feedback) {
  TopicosListFeedback.created || TopicosListFeedback.renamed || TopicosListFeedback.deleted => true,
  _ => false,
};
