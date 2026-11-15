import 'package:estudos_app/features/concursos/domain/models/concurso.dart';
import 'package:estudos_app/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/features/concursos/presentation/concurso_details/concurso_details_bloc.dart';
import 'package:estudos_app/features/concursos/presentation/concurso_details/concurso_details_event.dart';
import 'package:estudos_app/features/concursos/presentation/concurso_details/concurso_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_concursos_repository.dart';

void main() {
  group('ConcursoDetailsBloc', () {
    test('carrega o Concurso identificado pela rota', () async {
      final concurso = _concurso();
      final useCases = ConcursosUseCases(FakeConcursosRepository(concursos: [concurso]));
      final bloc = ConcursoDetailsBloc(concursoId: concurso.id, getConcurso: useCases.getConcurso);
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ConcursoDetailsState>().having(
            (state) => state.status,
            'status',
            ConcursoDetailsStatus.loading,
          ),
          isA<ConcursoDetailsState>()
              .having((state) => state.status, 'status', ConcursoDetailsStatus.success)
              .having((state) => state.concurso, 'concurso', concurso),
        ]),
      );

      bloc.add(const ConcursoDetailsLoadRequested(forceRefresh: true));

      await expectation;
    });

    test('mantém busca e aba ativa no estado renderizável', () async {
      final concurso = _concurso();
      final useCases = ConcursosUseCases(FakeConcursosRepository(concursos: [concurso]));
      final bloc = ConcursoDetailsBloc(concursoId: concurso.id, getConcurso: useCases.getConcurso);
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ConcursoDetailsState>().having((state) => state.query, 'query', 'tributário'),
          isA<ConcursoDetailsState>().having(
            (state) => state.tab,
            'tab',
            ConcursoDetailsTab.informacoes,
          ),
        ]),
      );

      bloc
        ..add(const ConcursoDetailsQueryChanged('tributário'))
        ..add(const ConcursoDetailsTabChanged(ConcursoDetailsTab.informacoes));

      await expectation;
    });

    test('representa um identificador inexistente como notFound', () async {
      final useCases = ConcursosUseCases(FakeConcursosRepository());
      final bloc = ConcursoDetailsBloc(concursoId: 'inexistente', getConcurso: useCases.getConcurso);
      addTearDown(bloc.close);

      bloc.add(const ConcursoDetailsLoadRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<ConcursoDetailsState>().having(
            (state) => state.status,
            'status',
            ConcursoDetailsStatus.notFound,
          ),
        ),
      );
    });

    test('representa falha técnica inicial sem confundir com ausência', () async {
      final repository = FakeConcursosRepository()..failLoad = true;
      final useCases = ConcursosUseCases(repository);
      final bloc = ConcursoDetailsBloc(concursoId: 'concurso-real', getConcurso: useCases.getConcurso);
      addTearDown(bloc.close);

      bloc.add(const ConcursoDetailsLoadRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<ConcursoDetailsState>().having(
            (state) => state.status,
            'status',
            ConcursoDetailsStatus.failure,
          ),
        ),
      );
    });

    test('preserva o Concurso quando um refresh falha', () async {
      final concurso = _concurso();
      final repository = FakeConcursosRepository(concursos: [concurso]);
      final useCases = ConcursosUseCases(repository);
      final bloc = ConcursoDetailsBloc(concursoId: concurso.id, getConcurso: useCases.getConcurso);
      addTearDown(bloc.close);

      bloc.add(const ConcursoDetailsLoadRequested());
      await bloc.stream.firstWhere((state) => state.status == ConcursoDetailsStatus.success);
      repository.failLoad = true;
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ConcursoDetailsState>()
              .having((state) => state.concurso, 'concurso', concurso)
              .having((state) => state.isRefreshing, 'isRefreshing', isTrue),
          isA<ConcursoDetailsState>()
              .having((state) => state.status, 'status', ConcursoDetailsStatus.success)
              .having((state) => state.concurso, 'concurso', concurso)
              .having((state) => state.refreshFailed, 'refreshFailed', isTrue),
        ]),
      );

      bloc.add(const ConcursoDetailsLoadRequested(forceRefresh: true));

      await expectation;
    });
  });
}

Concurso _concurso() => Concurso(
  id: 'concurso-real',
  instituicao: 'Receita Federal',
  cargo: 'Auditor-Fiscal',
  banca: 'FGV',
  dataProva: null,
  prioritario: true,
  progressoEdital: 42,
);
