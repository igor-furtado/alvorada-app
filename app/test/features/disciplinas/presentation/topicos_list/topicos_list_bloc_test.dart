import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/topicos_list/topicos_list_bloc.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/topicos_list/topicos_list_event.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/topicos_list/topicos_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  test('carrega apenas os Tópicos da Disciplina selecionada', () async {
    final bloc = _bloc(
      FakeDisciplinasRepository(
        disciplinas: disciplinasFixture(),
      ),
    );
    addTearDown(bloc.close);

    final loaded = bloc.stream.firstWhere(
      (state) => state.status == TopicosListStatus.success,
    );
    bloc.add(const TopicosListDisciplineChanged('constitucional'));
    final state = await loaded;

    expect(state.disciplineId, 'constitucional');
    expect(
      state.regularItems.map((topico) => topico.id),
      ['direitos', 'estado'],
    );
    expect(state.mandatoryItems.single.mandatory, isTrue);
  });

  test('expande um Tópico preservando os itens carregados', () async {
    final repository = FakeDisciplinasRepository(
      disciplinas: disciplinasFixture(),
    );
    final bloc = _bloc(repository);
    addTearDown(bloc.close);
    await _load(bloc);
    final items = bloc.state.items;

    final toggled = bloc.stream.firstWhere(
      (state) => state.expandedTopicIds.contains('interpretacao'),
    );
    bloc.add(const TopicosListToggleRequested('interpretacao'));
    final state = await toggled;

    expect(state.items, items);
  });

  test('exclui o Tópico e atualiza somente sua lista', () async {
    final bloc = _bloc(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );
    addTearDown(bloc.close);
    await _load(bloc);

    final deleted = bloc.stream.firstWhere(
      (state) => state.feedback == TopicosListFeedback.deleted,
    );
    bloc.add(const TopicosListDeleteRequested('interpretacao'));
    final state = await deleted;

    expect(
      state.items.map((topico) => topico.id),
      isNot(contains('interpretacao')),
    );
    expect(
      state.items.map((topico) => topico.id),
      contains('morfossintaxe'),
    );
  });

  test('encerra a exclusão quando a sincronização fica pendente', () async {
    final repository = FakeDisciplinasRepository(
      disciplinas: disciplinasFixture(),
    );
    final bloc = _bloc(repository);
    addTearDown(bloc.close);
    await _load(bloc);
    repository.failSynchronization = true;

    final failed = bloc.stream.firstWhere(
      (state) => state.feedback == TopicosListFeedback.synchronizationPending,
    );
    bloc.add(const TopicosListDeleteRequested('interpretacao'));
    final state = await failed;

    expect(state.isDeleting, isFalse);
    expect(
      state.items.map((topico) => topico.id),
      contains('interpretacao'),
    );
  });
}

TopicosListBloc _bloc(FakeDisciplinasRepository repository) {
  final useCases = DisciplinasUseCases(repository);
  return TopicosListBloc(
    getDisciplinas: useCases.getDisciplinas,
    deleteTopico: useCases.deleteTopico,
  );
}

Future<void> _load(TopicosListBloc bloc) async {
  final loaded = bloc.stream.firstWhere(
    (state) => state.status == TopicosListStatus.success,
  );
  bloc.add(const TopicosListDisciplineChanged('portugues'));
  await loaded;
}
