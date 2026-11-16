import 'dart:async';

import 'package:estudos_app/features/concursos/domain/models/concurso.dart';
import 'package:estudos_app/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/features/concursos/presentation/edital_editor/edital_editor_bloc.dart';
import 'package:estudos_app/features/concursos/presentation/edital_editor/edital_editor_event.dart';
import 'package:estudos_app/features/concursos/presentation/edital_editor/edital_editor_state.dart';
import 'package:estudos_app/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../disciplinas/fakes/fake_disciplinas_repository.dart';
import '../../fakes/fake_concursos_repository.dart';

void main() {
  test('protege as coleções do estado contra mutação externa', () {
    final catalogo = disciplinasFixture();
    final originais = <String>{'interpretacao'};
    final vinculados = <String>{'interpretacao', 'direitos'};
    final state = EditalEditorState(
      catalogo: catalogo,
      topicosOriginais: originais,
      topicosVinculados: vinculados,
    );

    catalogo.clear();
    originais.clear();
    vinculados.clear();

    expect(state.catalogo, isNotEmpty);
    expect(state.topicosOriginais, contains('interpretacao'));
    expect(state.topicosVinculados, containsAll(['interpretacao', 'direitos']));
    expect(state.catalogo.clear, throwsUnsupportedError);
    expect(state.topicosOriginais.clear, throwsUnsupportedError);
    expect(state.topicosVinculados.clear, throwsUnsupportedError);
  });

  test('carrega o catálogo, seleciona a primeira Disciplina e permite tentar novamente', () async {
    final disciplinasRepository = FakeDisciplinasRepository(disciplinas: disciplinasFixture())..failLoad = true;
    final bloc = _bloc(disciplinasRepository: disciplinasRepository);
    addTearDown(bloc.close);

    bloc.add(const EditalEditorLoaded());
    await bloc.stream.firstWhere((state) => state.status == EditalEditorStatus.failure);

    disciplinasRepository.failLoad = false;
    bloc.add(const EditalEditorRetried());
    final ready = await bloc.stream.firstWhere((state) => state.status == EditalEditorStatus.ready);

    expect(ready.catalogo, hasLength(3));
    expect(ready.disciplinaSelecionada, 'portugues');
  });

  test('mantém busca e troca de Disciplina somente no rascunho', () async {
    final bloc = _bloc(
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );
    addTearDown(bloc.close);
    await _load(bloc);

    bloc.add(const EditalEditorTopicoSearched('interpretação'));
    final searched = await bloc.stream.firstWhere((state) => state.buscaTopico.isNotEmpty);
    expect(searched.topicosAtivos.single.id, 'interpretacao');

    bloc.add(const EditalEditorDisciplinaSelected('constitucional'));
    final selected = await bloc.stream.firstWhere((state) => state.disciplinaSelecionada == 'constitucional');
    expect(selected.buscaTopico, isEmpty);
  });

  test('altera um Tópico localmente e persiste somente ao salvar', () async {
    final repository = FakeConcursosRepository();
    final bloc = _bloc(
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      concursosRepository: repository,
    );
    addTearDown(bloc.close);
    final ready = await _load(bloc);

    bloc.add(EditalEditorTopicoToggled(ready.catalogo.first.topics.first));
    final draft = await bloc.stream.firstWhere((state) => state.temAlteracoes);

    expect(draft.topicosVinculados, contains('interpretacao'));
    expect(repository.addTopicoCalls, 0);

    bloc.add(const EditalEditorSaved());
    final saved = await bloc.stream.firstWhere((state) => state.feedback == EditalEditorFeedback.editalSalvo);

    expect(repository.addTopicoCalls, 1);
    expect(saved.topicosOriginais, contains('interpretacao'));
    expect(saved.temAlteracoes, isFalse);
  });

  test('seleciona e limpa todos os Tópicos comuns da Disciplina', () async {
    final bloc = _bloc(
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );
    addTearDown(bloc.close);
    final ready = await _load(bloc);
    final disciplina = ready.catalogo.first;

    bloc.add(EditalEditorDisciplinaSelectionChanged(disciplina: disciplina, selected: true));
    final selected = await bloc.stream.firstWhere((state) => state.quantidadeSelecionada(disciplina) == 2);
    expect(selected.topicosVinculados, isNot(contains('revisao-portugues')));

    bloc.add(EditalEditorDisciplinaSelectionChanged(disciplina: disciplina, selected: false));
    final cleared = await bloc.stream.firstWhere((state) => state.quantidadeSelecionada(disciplina) == 0);
    expect(cleared.topicosVinculados, isEmpty);
  });

  test('salva remoções e adições como uma única confirmação', () async {
    final repository = FakeConcursosRepository();
    final bloc = _bloc(
      concurso: _concursoComTopico(),
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      concursosRepository: repository,
    );
    addTearDown(bloc.close);
    final ready = await _load(bloc);

    bloc
      ..add(EditalEditorTopicoToggled(ready.catalogo.first.topics.first))
      ..add(EditalEditorTopicoToggled(ready.catalogo[1].topics.first));
    await bloc.stream.firstWhere(
      (state) => !state.topicosVinculados.contains('interpretacao') && state.topicosVinculados.contains('direitos'),
    );
    bloc.add(const EditalEditorSaved());
    await bloc.stream.firstWhere((state) => state.feedback == EditalEditorFeedback.editalSalvo);

    expect(repository.removeTopicoCalls, 1);
    expect(repository.addTopicoCalls, 1);
  });

  for (final failure in [
    (label: 'violação de regra', rule: true, feedback: EditalEditorFeedback.violacaoRegra),
    (label: 'falha técnica', rule: false, feedback: EditalEditorFeedback.falhaTecnica),
  ]) {
    test('mantém o rascunho após ${failure.label} ao salvar', () async {
      final repository = FakeConcursosRepository()
        ..failRuleViolation = failure.rule
        ..failMutation = !failure.rule;
      final bloc = _bloc(
        disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
        concursosRepository: repository,
      );
      addTearDown(bloc.close);
      final ready = await _load(bloc);

      bloc.add(EditalEditorTopicoToggled(ready.catalogo.first.topics.first));
      await bloc.stream.firstWhere((state) => state.temAlteracoes);
      bloc.add(const EditalEditorSaved());
      final failed = await bloc.stream.firstWhere((state) => state.feedback == failure.feedback);

      expect(failed.saving, isFalse);
      expect(failed.temAlteracoes, isTrue);
      expect(failed.topicosVinculados, contains('interpretacao'));
    });
  }

  test('ignora alterações enquanto o salvamento está em andamento', () async {
    final repository = FakeConcursosRepository()..editalMutationGate = Completer<void>();
    final bloc = _bloc(
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      concursosRepository: repository,
    );
    addTearDown(bloc.close);
    final ready = await _load(bloc);
    final first = ready.catalogo.first.topics.first;
    final second = ready.catalogo.first.topics[1];

    bloc.add(EditalEditorTopicoToggled(first));
    await bloc.stream.firstWhere((state) => state.temAlteracoes);
    bloc.add(const EditalEditorSaved());
    await bloc.stream.firstWhere((state) => state.saving);
    bloc.add(EditalEditorTopicoToggled(second));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.topicosVinculados, isNot(contains(second.id)));
    repository.editalMutationGate!.complete();
    await bloc.stream.firstWhere((state) => state.feedback == EditalEditorFeedback.editalSalvo);
  });
}

Future<EditalEditorState> _load(EditalEditorBloc bloc) async {
  bloc.add(const EditalEditorLoaded());
  return bloc.stream.firstWhere((state) => state.status == EditalEditorStatus.ready);
}

EditalEditorBloc _bloc({
  required FakeDisciplinasRepository disciplinasRepository,
  FakeConcursosRepository? concursosRepository,
  Concurso? concurso,
}) {
  final concursoUseCases = ConcursosUseCases(concursosRepository ?? FakeConcursosRepository());
  return EditalEditorBloc(
    concurso: concurso ?? _concurso(),
    getDisciplinas: DisciplinasUseCases(disciplinasRepository).getDisciplinas,
    edital: concursoUseCases.edital,
  );
}

Concurso _concurso() => Concurso(
  id: 'concurso-1',
  instituicao: 'Receita Federal',
  cargo: 'Auditor-Fiscal',
  banca: null,
  dataProva: null,
  prioritario: false,
  progressoEdital: 0,
);

Concurso _concursoComTopico() => Concurso(
  id: 'concurso-1',
  instituicao: 'Receita Federal',
  cargo: 'Auditor-Fiscal',
  banca: null,
  dataProva: null,
  prioritario: false,
  progressoEdital: 0,
  disciplinas: [
    DisciplinaEdital(
      id: 'portugues',
      nome: 'Língua Portuguesa',
      topicos: [
        TopicoEdital(id: 'interpretacao', nome: 'Compreensão e interpretação de textos', obrigatorio: false),
        TopicoEdital(id: 'revisao-portugues', nome: 'Revisão de Véspera', obrigatorio: true),
      ],
    ),
  ],
);
