import 'package:bloc_test/bloc_test.dart';
import 'package:estudos_app/src/core/domain/resultado.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/topicos_form/topicos_form_bloc.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/topicos_form/topicos_form_event.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/topicos_form/topicos_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  blocTest<TopicosFormBloc, TopicosFormState>(
    'cria vários Tópicos e conclui o formulário',
    build: () {
      final useCases = DisciplinasUseCases(
        FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      );
      return TopicosFormBloc(
        createTopicos: useCases.createTopicos,
        updateTopico: useCases.updateTopico,
        disciplineId: 'portugues',
      );
    },
    act: (bloc) => bloc.add(const TopicosFormSubmitted(['Pontuação', 'Concordância'])),
    expect: () => [
      isA<TopicosFormState>().having(
        (state) => state.status,
        'status',
        TopicosFormStatus.submitting,
      ),
      isA<TopicosFormState>().having(
        (state) => state.status,
        'status',
        TopicosFormStatus.success,
      ),
    ],
  );

  blocTest<TopicosFormBloc, TopicosFormState>(
    'apresenta a violação quando o nome do Tópico está vazio',
    build: () {
      final useCases = DisciplinasUseCases(FakeDisciplinasRepository());
      return TopicosFormBloc(
        createTopicos: useCases.createTopicos,
        updateTopico: useCases.updateTopico,
        disciplineId: 'portugues',
      );
    },
    act: (bloc) => bloc.add(const TopicosFormSubmitted([])),
    expect: () => [
      isA<TopicosFormState>().having(
        (state) => state.status,
        'status',
        TopicosFormStatus.submitting,
      ),
      isA<TopicosFormState>()
          .having(
            (state) => state.status,
            'status',
            TopicosFormStatus.failure,
          )
          .having(
            (state) => state.errorMessage,
            'mensagem',
            'Informe ao menos um Tópico.',
          ),
    ],
  );

  blocTest<TopicosFormBloc, TopicosFormState>(
    'conclui o formulário quando a criação foi salva mas a sincronização ficou pendente',
    build: () {
      final repository = FakeDisciplinasRepository(
        disciplinas: disciplinasFixture(),
      )..failSynchronization = true;
      final useCases = DisciplinasUseCases(repository);
      return TopicosFormBloc(
        createTopicos: useCases.createTopicos,
        updateTopico: useCases.updateTopico,
        disciplineId: 'portugues',
      );
    },
    act: (bloc) => bloc.add(const TopicosFormSubmitted(['Pontuação'])),
    expect: () => const [
      TopicosFormState(status: TopicosFormStatus.submitting),
      TopicosFormState(status: TopicosFormStatus.success),
    ],
  );

  test('atualiza o Tópico selecionado', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );
    final bloc = TopicosFormBloc(
      createTopicos: useCases.createTopicos,
      updateTopico: useCases.updateTopico,
      disciplineId: 'portugues',
      topicId: 'interpretacao',
    );
    addTearDown(bloc.close);

    final completed = bloc.stream.firstWhere(
      (state) => state.status == TopicosFormStatus.success,
    );
    bloc.add(const TopicosFormSubmitted(['Interpretação textual']));
    await completed;
    final catalogResult = await useCases.getDisciplinas();

    expect(
      catalogResult,
      isA<Sucesso<List<Disciplina>>>().having(
        (success) => success.valor.first.topics.first.name,
        'nome',
        'Interpretação textual',
      ),
    );
  });
}
