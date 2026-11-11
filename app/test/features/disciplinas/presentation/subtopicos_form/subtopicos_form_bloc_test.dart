import 'package:bloc_test/bloc_test.dart';
import 'package:estudos_app/src/core/domain/resultado.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/subtopicos_form/subtopicos_form_bloc.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/subtopicos_form/subtopicos_form_event.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/subtopicos_form/subtopicos_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  blocTest<SubtopicosFormBloc, SubtopicosFormState>(
    'cria um Subtópico e conclui o formulário',
    build: () {
      final useCases = DisciplinasUseCases(
        FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      );
      return SubtopicosFormBloc(
        createSubtopico: useCases.createSubtopico,
        updateSubtopico: useCases.updateSubtopico,
        topicId: 'interpretacao',
      );
    },
    act: (bloc) => bloc.add(
      const SubtopicosFormSubmitted('Elementos da comunicação'),
    ),
    expect: () => [
      isA<SubtopicosFormState>().having(
        (state) => state.status,
        'status',
        SubtopicosFormStatus.submitting,
      ),
      isA<SubtopicosFormState>().having(
        (state) => state.status,
        'status',
        SubtopicosFormStatus.success,
      ),
    ],
  );

  blocTest<SubtopicosFormBloc, SubtopicosFormState>(
    'apresenta a violação quando o nome do Subtópico está vazio',
    build: () {
      final useCases = DisciplinasUseCases(FakeDisciplinasRepository());
      return SubtopicosFormBloc(
        createSubtopico: useCases.createSubtopico,
        updateSubtopico: useCases.updateSubtopico,
        topicId: 'interpretacao',
      );
    },
    act: (bloc) => bloc.add(const SubtopicosFormSubmitted('   ')),
    expect: () => [
      isA<SubtopicosFormState>().having(
        (state) => state.status,
        'status',
        SubtopicosFormStatus.submitting,
      ),
      isA<SubtopicosFormState>()
          .having(
            (state) => state.status,
            'status',
            SubtopicosFormStatus.failure,
          )
          .having(
            (state) => state.errorMessage,
            'mensagem',
            'Informe um nome para o Subtópico.',
          ),
    ],
  );

  blocTest<SubtopicosFormBloc, SubtopicosFormState>(
    'conclui o formulário quando a criação foi salva mas a sincronização ficou pendente',
    build: () {
      final repository = FakeDisciplinasRepository(
        disciplinas: disciplinasFixture(),
      )..failSynchronization = true;
      final useCases = DisciplinasUseCases(repository);
      return SubtopicosFormBloc(
        createSubtopico: useCases.createSubtopico,
        updateSubtopico: useCases.updateSubtopico,
        topicId: 'interpretacao',
      );
    },
    act: (bloc) => bloc.add(
      const SubtopicosFormSubmitted('Elementos da comunicação'),
    ),
    expect: () => const [
      SubtopicosFormState(status: SubtopicosFormStatus.submitting),
      SubtopicosFormState(status: SubtopicosFormStatus.success),
    ],
  );

  test('atualiza o Subtópico selecionado', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );
    final bloc = SubtopicosFormBloc(
      createSubtopico: useCases.createSubtopico,
      updateSubtopico: useCases.updateSubtopico,
      topicId: 'interpretacao',
      subtopicId: 'tipologia',
    );
    addTearDown(bloc.close);

    final completed = bloc.stream.firstWhere(
      (state) => state.status == SubtopicosFormStatus.success,
    );
    bloc.add(const SubtopicosFormSubmitted('Tipologia textual'));
    await completed;
    final catalogResult = await useCases.getDisciplinas();

    expect(
      catalogResult,
      isA<Sucesso<List<Disciplina>>>().having(
        (success) => success.valor.first.topics.first.subtopics.first.name,
        'nome',
        'Tipologia textual',
      ),
    );
  });
}
