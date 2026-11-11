import 'package:bloc_test/bloc_test.dart';
import 'package:estudos_app/src/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/src/features/concursos/presentation/concursos_list/concursos_list_bloc.dart';
import 'package:estudos_app/src/features/concursos/presentation/concursos_list/concursos_list_event.dart';
import 'package:estudos_app/src/features/concursos/presentation/concursos_list/concursos_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_concursos_repository.dart';

void main() {
  blocTest<ConcursosListBloc, ConcursosListState>(
    'carrega Concursos em estados observáveis',
    build: () => _bloc(
      FakeConcursosRepository(concursos: concursosFixture()),
    ),
    act: (bloc) => bloc.add(const ConcursosListLoadRequested()),
    expect: () => [
      isA<ConcursosListState>().having(
        (state) => state.status,
        'status',
        ConcursosListStatus.loading,
      ),
      isA<ConcursosListState>()
          .having(
            (state) => state.status,
            'status',
            ConcursosListStatus.success,
          )
          .having((state) => state.items.length, 'Concursos', 2),
    ],
  );

  blocTest<ConcursosListBloc, ConcursosListState>(
    'arquiva e preserva o Concurso no feedback para desfazer',
    build: () => _bloc(
      FakeConcursosRepository(concursos: concursosFixture()),
    ),
    seed: () => ConcursosListState(
      status: ConcursosListStatus.success,
      items: concursosFixture(),
    ),
    act: (bloc) => bloc.add(const ConcursoArchiveRequested('trf5')),
    expect: () => [
      isA<ConcursosListState>().having(
        (state) => state.isMutating,
        'isMutating',
        isTrue,
      ),
      isA<ConcursosListState>()
          .having((state) => state.items.length, 'Concursos', 1)
          .having(
            (state) => state.feedback?.type,
            'feedback',
            ConcursosListFeedbackType.archived,
          )
          .having(
            (state) => state.feedback?.concurso?.id,
            'Concurso arquivado',
            'trf5',
          ),
    ],
  );

  blocTest<ConcursosListBloc, ConcursosListState>(
    'troca o Concurso prioritário sem manter duas prioridades',
    build: () => _bloc(
      FakeConcursosRepository(concursos: concursosFixture()),
    ),
    seed: () => ConcursosListState(
      status: ConcursosListStatus.success,
      items: concursosFixture(),
    ),
    act: (bloc) => bloc.add(
      const ConcursoPrioritarioSetRequested('trf5'),
    ),
    verify: (bloc) {
      final priority = bloc.state.items.where((item) => item.prioritario);
      expect(priority.single.id, 'trf5');
    },
  );
}

ConcursosListBloc _bloc(FakeConcursosRepository repository) {
  final useCases = ConcursosUseCases(repository);
  return ConcursosListBloc(
    getConcursos: useCases.getConcursos,
    setConcursoPrioritario: useCases.setConcursoPrioritario,
    archiveConcurso: useCases.archiveConcurso,
    restoreConcurso: useCases.restoreConcurso,
    deleteConcurso: useCases.deleteConcurso,
  );
}
