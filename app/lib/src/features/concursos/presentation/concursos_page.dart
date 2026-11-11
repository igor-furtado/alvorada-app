import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import '../domain/use_cases/concursos_use_cases.dart';
import 'concursos_list/concursos_list_actions.dart';
import 'concursos_list/concursos_list_bloc.dart';
import 'concursos_list/concursos_list_event.dart';
import 'concursos_list/concursos_list_header.dart';
import 'concursos_list/concursos_list_state.dart';
import 'concursos_list/concursos_list_view.dart';

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
  Widget build(BuildContext context) => AppPageTemplate(
    maxWidth: context.tokens.sizes.concursosPage,
    builder: (context, desktop) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocSelector<ConcursosListBloc, ConcursosListState, bool>(
          selector: (state) => state.canMutate,
          builder: (context, canAdd) => RepaintBoundary(
            child: ConcursosListHeader(
              onAdd: canAdd ? () => ConcursosListActions.add(context) : null,
            ),
          ),
        ),
        SizedBox(height: context.tokens.spacing.xxxl),
        const ConcursosListView(),
      ],
    ),
  );
}
