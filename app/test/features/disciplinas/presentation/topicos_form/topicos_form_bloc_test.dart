import 'package:bloc_test/bloc_test.dart';
import 'package:estudos_app/features/disciplinas/domain/models/disciplina_input.dart';
import 'package:estudos_app/features/disciplinas/domain/use_cases/disciplinas_resultado_codes.dart';
import 'package:estudos_app/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/features/disciplinas/presentation/topicos_form/topicos_form_bloc.dart';
import 'package:estudos_app/features/disciplinas/presentation/topicos_form/topicos_form_event.dart';
import 'package:estudos_app/features/disciplinas/presentation/topicos_form/topicos_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  blocTest<TopicosFormBloc, TopicosFormState>(
    'substitui a lista completa de Tópicos',
    build: () {
      final useCases = DisciplinasUseCases(
        FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      );
      return TopicosFormBloc(
        replaceTopicos: useCases.replaceTopicos,
        disciplineId: 'portugues',
      );
    },
    act: (bloc) => bloc.add(
      const TopicosFormSubmitted([
        ReplaceTopicoInput(id: 'interpretacao', name: 'Interpretação textual'),
        ReplaceTopicoInput(name: 'Pontuação'),
      ]),
    ),
    expect: () => const [
      TopicosFormState(status: TopicosFormStatus.submitting),
      TopicosFormState(status: TopicosFormStatus.success),
    ],
  );

  blocTest<TopicosFormBloc, TopicosFormState>(
    'apresenta violação quando um Tópico está vazio',
    build: () {
      final useCases = DisciplinasUseCases(FakeDisciplinasRepository());
      return TopicosFormBloc(
        replaceTopicos: useCases.replaceTopicos,
        disciplineId: 'portugues',
      );
    },
    act: (bloc) => bloc.add(
      const TopicosFormSubmitted([ReplaceTopicoInput(name: '')]),
    ),
    expect: () => [
      const TopicosFormState(status: TopicosFormStatus.submitting),
      isA<TopicosFormState>()
          .having(
            (state) => state.status,
            'status',
            TopicosFormStatus.failure,
          )
          .having(
            (state) => state.errorCode,
            'código',
            DisciplinasResultadoCodes.topicoNomeObrigatorio,
          ),
    ],
  );

  blocTest<TopicosFormBloc, TopicosFormState>(
    'conclui quando a substituição foi salva mas a sincronização ficou pendente',
    build: () {
      final repository = FakeDisciplinasRepository(
        disciplinas: disciplinasFixture(),
      )..failSynchronization = true;
      final useCases = DisciplinasUseCases(repository);
      return TopicosFormBloc(
        replaceTopicos: useCases.replaceTopicos,
        disciplineId: 'portugues',
      );
    },
    act: (bloc) => bloc.add(
      const TopicosFormSubmitted([ReplaceTopicoInput(name: 'Pontuação')]),
    ),
    expect: () => const [
      TopicosFormState(status: TopicosFormStatus.submitting),
      TopicosFormState(status: TopicosFormStatus.success),
    ],
  );
}
