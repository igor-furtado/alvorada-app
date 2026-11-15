import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/use_cases/disciplinas_use_cases.dart';
import 'disciplinas_list/disciplinas_list_bloc.dart';
import 'disciplinas_list/disciplinas_list_event.dart';
import 'disciplinas_view.dart';
import 'topicos_list/topicos_list_bloc.dart';

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
      child: DisciplinasView(routeQuery: initialQuery),
    );
  }
}
