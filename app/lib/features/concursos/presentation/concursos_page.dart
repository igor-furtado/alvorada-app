import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/use_cases/concursos_use_cases.dart';
import 'concursos_list/concursos_list_actions.dart';
import 'concursos_list/concursos_list_bloc.dart';
import 'concursos_list/concursos_list_event.dart';
import 'concursos_list/concursos_list_state.dart';
import 'concursos_list/concursos_list_view.dart';

const _pageMaxWidth = 1220.0;

class ConcursosPage extends StatelessWidget {
  const ConcursosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<ConcursosUseCases>();
    return BlocProvider(
      create: (_) => ConcursosListBloc(
        getConcursos: useCases.getConcursos,
        setConcursoPrioritario: useCases.setConcursoPrioritario,
        archiveConcurso: useCases.archiveConcurso,
        restoreConcurso: useCases.restoreConcurso,
        deleteConcurso: useCases.deleteConcurso,
      )..add(const ConcursosListLoadRequested()),
      child: const _ConcursosPageContent(),
    );
  }
}

class _ConcursosPageContent extends StatelessWidget {
  const _ConcursosPageContent();

  @override
  Widget build(BuildContext context) => AppPage.scroll(
    title: context.l10n.navigationConcursos,
    description: context.l10n.concursosSubtitle,
    maxWidth: _pageMaxWidth,
    headerAction: BlocSelector<ConcursosListBloc, ConcursosListState, bool>(
      selector: (state) => state.canMutate,
      builder: (context, canAdd) => AppButton(
        label: context.l10n.novoConcurso,
        icon: AppIcons.add,
        onPressed: canAdd ? () => ConcursosListActions.add(context) : null,
      ),
    ),
    child: const ConcursosListView(),
  );
}
