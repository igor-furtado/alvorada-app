import 'dart:async';

import 'package:estudos_app/src/features/concursos/domain/models/concurso.dart';
import 'package:estudos_app/src/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/src/features/concursos/presentation/edital_editor/edital_editor_bloc.dart';
import 'package:estudos_app/src/features/concursos/presentation/edital_editor/edital_editor_event.dart';
import 'package:estudos_app/src/features/concursos/presentation/edital_editor/edital_editor_state.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../disciplinas/fakes/fake_disciplinas_repository.dart';
import '../../fakes/fake_concursos_repository.dart';

void main() {
  test('protege as coleções do estado contra mutação externa', () {
    final catalogo = disciplinasFixture();
    final vinculados = <String>{'interpretacao'};
    final state = EditalEditorState(catalogo: catalogo, topicosVinculados: vinculados);

    catalogo.clear();
    vinculados.clear();

    expect(state.catalogo, isNotEmpty);
    expect(state.topicosVinculados, contains('interpretacao'));
    expect(state.catalogo.clear, throwsUnsupportedError);
    expect(state.topicosVinculados.clear, throwsUnsupportedError);
  });

  test('carrega o catálogo e permite tentar novamente após falha', () async {
    final disciplinasRepository = FakeDisciplinasRepository(disciplinas: disciplinasFixture())..failLoad = true;
    final bloc = _bloc(disciplinasRepository: disciplinasRepository);
    addTearDown(bloc.close);

    bloc.add(const EditalEditorLoaded());
    await bloc.stream.firstWhere((state) => state.status == EditalEditorStatus.failure);

    disciplinasRepository.failLoad = false;
    bloc.add(const EditalEditorRetried());
    final ready = await bloc.stream.firstWhere((state) => state.status == EditalEditorStatus.ready);

    expect(ready.catalogo, hasLength(3));
  });

  test('busca e seleção são refletidas no estado renderizável', () async {
    final bloc = _bloc(
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );
    addTearDown(bloc.close);
    bloc.add(const EditalEditorLoaded());
    await bloc.stream.firstWhere((state) => state.status == EditalEditorStatus.ready);

    bloc.add(const EditalEditorDisciplinaSearched('constitucional'));
    final searched = await bloc.stream.firstWhere((state) => state.buscaDisciplina.isNotEmpty);
    expect(searched.disciplinasFiltradas.single.name, 'Direito Constitucional');

    bloc.add(const EditalEditorTopicoSearched('direitos'));
    expect((await bloc.stream.firstWhere((state) => state.buscaTopico.isNotEmpty)).buscaTopico, 'direitos');

    bloc.add(const EditalEditorDisciplinaSelected('constitucional'));
    expect(
      (await bloc.stream.firstWhere((state) => state.disciplinaSelecionada != null)).disciplinaSelecionada,
      'constitucional',
    );
  });

  test('adiciona todos os Tópicos comuns de uma Disciplina', () async {
    final disciplinasRepository = FakeDisciplinasRepository(disciplinas: disciplinasFixture());
    final concursosRepository = FakeConcursosRepository();
    final bloc = _bloc(
      disciplinasRepository: disciplinasRepository,
      concursosRepository: concursosRepository,
    );
    addTearDown(bloc.close);
    final disciplina = await _loadFirstDisciplina(bloc);

    bloc.add(EditalEditorDisciplinaAdded(disciplina));
    final updated = await bloc.stream.firstWhere(
      (state) => state.feedback == EditalEditorFeedback.disciplinaAdicionada,
    );

    expect(updated.topicosVinculados, containsAll(['interpretacao', 'morfossintaxe']));
    expect(updated.disciplinaSelecionada, disciplina.id);
    expect(concursosRepository.addDisciplinaCalls, 1);
  });

  test('adiciona um Tópico e seleciona sua Disciplina derivada', () async {
    final repository = FakeConcursosRepository();
    final bloc = _bloc(
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      concursosRepository: repository,
    );
    addTearDown(bloc.close);
    final disciplina = await _loadFirstDisciplina(bloc);

    bloc.add(EditalEditorTopicoToggled(disciplina.topics.first));
    final updated = await bloc.stream.firstWhere(
      (state) => state.feedback == EditalEditorFeedback.topicoAdicionado,
    );

    expect(updated.topicosVinculados, contains('interpretacao'));
    expect(updated.disciplinaSelecionada, 'portugues');
    expect(repository.addTopicoCalls, 1);
  });

  test('remove o último Tópico comum e normaliza a seleção', () async {
    final repository = FakeConcursosRepository();
    final bloc = _bloc(
      concurso: _concursoComTopico(),
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      concursosRepository: repository,
    );
    addTearDown(bloc.close);
    final disciplina = await _loadFirstDisciplina(bloc);

    bloc.add(EditalEditorTopicoToggled(disciplina.topics.first));
    final updated = await bloc.stream.firstWhere(
      (state) => state.feedback == EditalEditorFeedback.topicoRemovido,
    );

    expect(updated.topicosVinculados, isEmpty);
    expect(updated.disciplinaSelecionada, isNull);
    expect(repository.removeTopicoCalls, 1);
  });

  for (final failure in [
    (label: 'violação de regra', rule: true, feedback: EditalEditorFeedback.violacaoRegra),
    (label: 'falha técnica', rule: false, feedback: EditalEditorFeedback.falhaTecnica),
  ]) {
    test('expõe ${failure.label} ao adicionar Disciplina', () async {
      final repository = FakeConcursosRepository()
        ..failRuleViolation = failure.rule
        ..failMutation = !failure.rule;
      final bloc = _bloc(
        disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
        concursosRepository: repository,
      );
      addTearDown(bloc.close);
      final disciplina = await _loadFirstDisciplina(bloc);

      bloc.add(EditalEditorDisciplinaAdded(disciplina));
      final failed = await bloc.stream.firstWhere((state) => state.feedback == failure.feedback);

      expect(failed.mutation, isNull);
      expect(failed.topicosVinculados, isEmpty);
    });

    test('expõe ${failure.label} ao alternar Tópico', () async {
      final repository = FakeConcursosRepository()
        ..failRuleViolation = failure.rule
        ..failMutation = !failure.rule;
      final bloc = _bloc(
        disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
        concursosRepository: repository,
      );
      addTearDown(bloc.close);
      final disciplina = await _loadFirstDisciplina(bloc);

      bloc.add(EditalEditorTopicoToggled(disciplina.topics.first));
      final failed = await bloc.stream.firstWhere((state) => state.feedback == failure.feedback);

      expect(failed.mutation, isNull);
      expect(failed.topicosVinculados, isEmpty);
    });
  }

  test('limpa o feedback ao iniciar uma nova operação', () async {
    final repository = FakeConcursosRepository()..failMutation = true;
    final bloc = _bloc(
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      concursosRepository: repository,
    );
    addTearDown(bloc.close);
    final disciplina = await _loadFirstDisciplina(bloc);
    bloc.add(EditalEditorDisciplinaAdded(disciplina));
    await bloc.stream.firstWhere((state) => state.feedback == EditalEditorFeedback.falhaTecnica);

    repository
      ..failMutation = false
      ..editalMutationGate = Completer<void>();
    bloc.add(EditalEditorDisciplinaAdded(disciplina));
    final pending = await bloc.stream.firstWhere((state) => state.mutation != null);

    expect(pending.feedback, isNull);
    repository.editalMutationGate!.complete();
  });

  test('ignora uma segunda mutação enquanto a primeira está em andamento', () async {
    final repository = FakeConcursosRepository()..editalMutationGate = Completer<void>();
    final bloc = _bloc(
      disciplinasRepository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      concursosRepository: repository,
    );
    addTearDown(bloc.close);
    final disciplina = await _loadFirstDisciplina(bloc);

    bloc
      ..add(EditalEditorDisciplinaAdded(disciplina))
      ..add(EditalEditorDisciplinaAdded(disciplina));
    await bloc.stream.firstWhere((state) => state.mutation != null);
    repository.editalMutationGate!.complete();
    await bloc.stream.firstWhere(
      (state) => state.feedback == EditalEditorFeedback.disciplinaAdicionada,
    );

    expect(repository.addDisciplinaCalls, 1);
  });
}

Future<Disciplina> _loadFirstDisciplina(EditalEditorBloc bloc) async {
  bloc.add(const EditalEditorLoaded());
  final ready = await bloc.stream.firstWhere((state) => state.status == EditalEditorStatus.ready);
  return ready.catalogo.first;
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
