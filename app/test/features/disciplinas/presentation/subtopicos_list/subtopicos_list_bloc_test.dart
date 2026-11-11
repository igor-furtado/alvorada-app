import 'dart:async';

import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/subtopicos_list/subtopicos_list_bloc.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/subtopicos_list/subtopicos_list_event.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/subtopicos_list/subtopicos_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  test('mantém a identidade dos grupos de Subtópicos não alterados', () async {
    final repository = FakeDisciplinasRepository(
      disciplinas: disciplinasFixture(),
    );
    final bloc = _bloc(repository);
    addTearDown(bloc.close);
    await _load(bloc);
    final beforeTarget = bloc.state.topic('interpretacao');
    final beforeUnrelated = bloc.state.topic('morfossintaxe');

    await repository.updateSubtopico(
      subtopicId: 'tipologia',
      name: 'Tipologia textual',
    );
    final refreshed = bloc.stream.firstWhere(
      (state) => state.topic('interpretacao')?.items.first.name == 'Tipologia textual',
    );
    bloc.add(const SubtopicosListRefreshRequested());
    final state = await refreshed;

    expect(identical(state.topic('interpretacao'), beforeTarget), isFalse);
    expect(identical(state.topic('morfossintaxe'), beforeUnrelated), isTrue);
  });

  test('excluir um Subtópico atualiza somente sua lista', () async {
    final bloc = _bloc(
      FakeDisciplinasRepository(
        disciplinas: disciplinasFixture(),
      ),
    );
    addTearDown(bloc.close);
    await _load(bloc);

    final deleted = bloc.stream.firstWhere(
      (state) => state.feedback == SubtopicosListFeedback.deleted,
    );
    bloc.add(const SubtopicosListDeleteRequested('tipologia'));
    final state = await deleted;

    expect(
      state.topic('interpretacao')!.items.map((item) => item.id),
      isNot(contains('tipologia')),
    );
  });

  test('mantém a exclusão em andamento ao receber uma atualização', () async {
    final repository = FakeDisciplinasRepository(
      disciplinas: disciplinasFixture(),
    )..deleteSubtopicoGate = Completer<void>();
    final bloc = _bloc(repository);
    addTearDown(bloc.close);
    await _load(bloc);

    final deleting = bloc.stream.firstWhere(
      (state) => state.topic('interpretacao')?.isDeleting == true,
    );
    bloc.add(const SubtopicosListDeleteRequested('tipologia'));
    await deleting;

    bloc.add(const SubtopicosListRefreshRequested());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.topic('interpretacao')?.isDeleting, isTrue);

    final deleted = bloc.stream.firstWhere(
      (state) => state.feedback == SubtopicosListFeedback.deleted,
    );
    repository.deleteSubtopicoGate!.complete();
    await deleted;
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
      (state) => state.feedback == SubtopicosListFeedback.synchronizationPending,
    );
    bloc.add(const SubtopicosListDeleteRequested('tipologia'));
    final state = await failed;

    expect(state.topic('interpretacao')?.isDeleting, isFalse);
    expect(
      state.topic('interpretacao')?.items.map((subtopico) => subtopico.id),
      contains('tipologia'),
    );
  });
}

SubtopicosListBloc _bloc(FakeDisciplinasRepository repository) {
  final useCases = DisciplinasUseCases(repository);
  return SubtopicosListBloc(
    getDisciplinas: useCases.getDisciplinas,
    deleteSubtopico: useCases.deleteSubtopico,
  );
}

Future<void> _load(SubtopicosListBloc bloc) async {
  final loaded = bloc.stream.firstWhere(
    (state) => state.status == SubtopicosListStatus.success,
  );
  bloc.add(const SubtopicosListDisciplineChanged('portugues'));
  await loaded;
}
