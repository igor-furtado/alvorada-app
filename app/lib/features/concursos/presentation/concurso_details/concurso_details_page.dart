import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/concursos_use_cases.dart';
import 'concurso_details_bloc.dart';
import 'concurso_details_event.dart';
import 'concurso_details_view.dart';

class ConcursoDetailsPage extends StatelessWidget {
  const ConcursoDetailsPage({required this.concursoId, super.key});

  final String concursoId;

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<ConcursosUseCases>();
    return BlocProvider(
      create: (_) => ConcursoDetailsBloc(
        concursoId: concursoId,
        getConcurso: useCases.getConcurso,
      )..add(const ConcursoDetailsLoadRequested(forceRefresh: true)),
      child: const ConcursoDetailsView(),
    );
  }
}
