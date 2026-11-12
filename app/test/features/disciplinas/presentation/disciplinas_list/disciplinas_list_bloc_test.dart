import 'package:bloc_test/bloc_test.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/disciplinas_list/disciplinas_list_bloc.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/disciplinas_list/disciplinas_list_event.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/disciplinas_list/disciplinas_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  group('DisciplinasListBloc', () {
    test('inicia com busca e ordenação recebidas pela rota', () {
      final repository = FakeDisciplinasRepository();
      final useCases = DisciplinasUseCases(repository);
      final bloc = DisciplinasListBloc(
        getDisciplinas: useCases.getDisciplinas,
        deleteDisciplina: useCases.deleteDisciplina,
        initialQuery: 'direito',
        initialOrder: DisciplinasListOrder.alphabetical,
      );
      addTearDown(bloc.close);

      expect(bloc.state.query, 'direito');
      expect(bloc.state.order, DisciplinasListOrder.alphabetical);
    });

    blocTest<DisciplinasListBloc, DisciplinasListState>(
      'carrega o catálogo e seleciona a primeira Disciplina',
      build: () => _bloc(
        FakeDisciplinasRepository(
          disciplinas: disciplinasFixture(),
        ),
      ),
      act: (bloc) => bloc.add(const DisciplinasListLoadRequested()),
      expect: () => [
        isA<DisciplinasListState>().having(
          (state) => state.status,
          'status',
          DisciplinasListStatus.loading,
        ),
        isA<DisciplinasListState>()
            .having(
              (state) => state.status,
              'status',
              DisciplinasListStatus.success,
            )
            .having((state) => state.items.length, 'Disciplinas', 3)
            .having(
              (state) => state.selectedDisciplineId,
              'Disciplina selecionada',
              'portugues',
            ),
      ],
    );

    blocTest<DisciplinasListBloc, DisciplinasListState>(
      'expõe falha quando o carregamento não conclui',
      build: () {
        final repository = FakeDisciplinasRepository()..failLoad = true;
        return _bloc(repository);
      },
      act: (bloc) => bloc.add(const DisciplinasListLoadRequested()),
      expect: () => [
        isA<DisciplinasListState>().having(
          (state) => state.status,
          'status',
          DisciplinasListStatus.loading,
        ),
        isA<DisciplinasListState>().having(
          (state) => state.status,
          'status',
          DisciplinasListStatus.failure,
        ),
      ],
    );

    test('filtra Disciplinas por nome de Tópico', () async {
      final bloc = _bloc(
        FakeDisciplinasRepository(
          disciplinas: disciplinasFixture(),
        ),
      );
      addTearDown(bloc.close);
      await _load(bloc);

      final filtered = bloc.stream.firstWhere(
        (state) => state.query == 'direitos e garantias fundamentais',
      );
      bloc.add(
        const DisciplinasListSearchChanged('direitos e garantias fundamentais'),
      );
      final state = await filtered;

      expect(state.items.single.name, 'Direito Constitucional');
    });

    test('ordena alfabeticamente sem alterar a ordem persistida', () async {
      final repository = FakeDisciplinasRepository(
        disciplinas: disciplinasFixture(),
      );
      final bloc = _bloc(repository);
      addTearDown(bloc.close);
      await _load(bloc);

      final ordered = bloc.stream.firstWhere(
        (state) => state.order == DisciplinasListOrder.alphabetical,
      );
      bloc.add(
        const DisciplinasListOrderChanged(
          DisciplinasListOrder.alphabetical,
        ),
      );
      final state = await ordered;

      expect(
        state.items.map((disciplina) => disciplina.name),
        [
          'Direito Administrativo',
          'Direito Constitucional',
          'Língua Portuguesa',
        ],
      );
      expect(
        (await repository.getDisciplinas()).map(
          (disciplina) => disciplina.name,
        ),
        [
          'Língua Portuguesa',
          'Direito Constitucional',
          'Direito Administrativo',
        ],
      );
    });

    test('exclui a Disciplina e publica o catálogo atualizado', () async {
      final bloc = _bloc(
        FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      );
      addTearDown(bloc.close);
      await _load(bloc);

      final deleted = bloc.stream.firstWhere(
        (state) => state.feedback == DisciplinasListFeedback.deleted,
      );
      bloc.add(const DisciplinasListDeleteRequested('constitucional'));
      final state = await deleted;

      expect(
        state.items.map((disciplina) => disciplina.id),
        isNot(contains('constitucional')),
      );
    });

    test('informa quando a exclusão aguarda sincronização', () async {
      final repository = FakeDisciplinasRepository(
        disciplinas: disciplinasFixture(),
      );
      final bloc = _bloc(repository);
      addTearDown(bloc.close);
      await _load(bloc);
      repository.failSynchronization = true;

      final failed = bloc.stream.firstWhere(
        (state) => state.feedback == DisciplinasListFeedback.synchronizationPending,
      );
      bloc.add(const DisciplinasListDeleteRequested('constitucional'));
      final state = await failed;

      expect(state.isDeleting, isFalse);
      expect(
        state.items.map((disciplina) => disciplina.id),
        contains('constitucional'),
      );
    });
  });
}

DisciplinasListBloc _bloc(FakeDisciplinasRepository repository) {
  final useCases = DisciplinasUseCases(repository);
  return DisciplinasListBloc(
    getDisciplinas: useCases.getDisciplinas,
    deleteDisciplina: useCases.deleteDisciplina,
  );
}

Future<void> _load(DisciplinasListBloc bloc) async {
  final loaded = bloc.stream.firstWhere(
    (state) => state.status == DisciplinasListStatus.success,
  );
  bloc.add(const DisciplinasListLoadRequested());
  await loaded;
}
