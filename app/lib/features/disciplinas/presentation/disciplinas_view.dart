import 'dart:async';

import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'disciplinas_list/disciplinas_list_actions.dart';
import 'disciplinas_list/disciplinas_list_bloc.dart';
import 'disciplinas_list/disciplinas_list_event.dart';
import 'disciplinas_list/disciplinas_list_state.dart';
import 'disciplinas_list/disciplinas_list_view.dart';
import 'topicos_list/topicos_list_bloc.dart';
import 'topicos_list/topicos_list_event.dart';
import 'topicos_list/topicos_list_state.dart';
import 'topicos_list/topicos_list_view.dart';

class DisciplinasView extends StatefulWidget {
  const DisciplinasView({required this.routeQuery, super.key});

  final String routeQuery;

  @override
  State<DisciplinasView> createState() => _DisciplinasViewState();
}

class _DisciplinasViewState extends State<DisciplinasView> {
  late final TextEditingController _searchController;
  Timer? _urlTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.routeQuery);
  }

  @override
  void didUpdateWidget(DisciplinasView oldWidget) {
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
      queryParameters: {if (state.query.trim().isNotEmpty) 'busca': state.query.trim()},
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
        listener: (context, state) => context.read<TopicosListBloc>().add(
          TopicosListDisciplineChanged(state.selectedDisciplineId),
        ),
      ),
      BlocListener<DisciplinasListBloc, DisciplinasListState>(
        listenWhen: (previous, current) => previous.query != current.query,
        listener: (context, state) => _synchronizeUrl(state),
      ),
      BlocListener<DisciplinasListBloc, DisciplinasListState>(
        listenWhen: (previous, current) =>
            previous.feedback != current.feedback && current.feedback == DisciplinasListFeedback.updated,
        listener: (context, state) => context.read<TopicosListBloc>().add(
          const TopicosListRefreshRequested(),
        ),
      ),
      BlocListener<TopicosListBloc, TopicosListState>(
        listenWhen: (previous, current) =>
            previous.feedback != current.feedback && current.feedback != null && _topicosChanged(current.feedback!),
        listener: (context, state) => context.read<DisciplinasListBloc>().add(
          const DisciplinasListRefreshRequested(),
        ),
      ),
    ],
    child: AppPage.workspace(
      title: context.l10n.contentCatalog,
      description: context.l10n.contentCatalogSubtitle,
      headerAction: BlocBuilder<DisciplinasListBloc, DisciplinasListState>(
        buildWhen: (previous, current) => previous.canMutate != current.canMutate,
        builder: (context, state) => AppButton(
          label: context.l10n.newDiscipline,
          icon: AppIcons.add,
          onPressed: state.canMutate ? () => DisciplinasListActions.add(context) : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSearchField(
            controller: _searchController,
            placeholder: context.l10n.searchContent,
            onChanged: (value) => context.read<DisciplinasListBloc>().add(
              DisciplinasListSearchChanged(value),
            ),
          ),
          SizedBox(height: context.tokens.spacing.xl),
          const Expanded(child: _DisciplinasWorkspace()),
        ],
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
            if (constraints.maxWidth < context.tokens.layout.contentSplit) {
              return Column(
                children: [
                  const SizedBox(
                    height: 190,
                    child: AppScrollArea(child: DisciplinasListView()),
                  ),
                  const AppDivider(margin: EdgeInsets.zero),
                  Expanded(child: AppScrollArea(child: detail)),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  width: 310,
                  child: AppScrollArea(child: DisciplinasListView()),
                ),
                const AppDivider(
                  vertical: true,
                  margin: EdgeInsets.zero,
                ),
                Expanded(child: AppScrollArea(child: detail)),
              ],
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
