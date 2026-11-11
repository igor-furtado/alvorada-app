import 'package:bloc_test/bloc_test.dart';
import 'package:estudos_app/src/core/domain/resultado.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/disciplinas_form/disciplinas_form_bloc.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/disciplinas_form/disciplinas_form_event.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/disciplinas_form/disciplinas_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  blocTest<DisciplinasFormBloc, DisciplinasFormState>(
    'cria uma Disciplina e conclui o formulário',
    build: () {
      final useCases = DisciplinasUseCases(FakeDisciplinasRepository());
      return DisciplinasFormBloc(
        createDisciplina: useCases.createDisciplina,
        updateDisciplina: useCases.updateDisciplina,
      );
    },
    act: (bloc) => bloc.add(
      const DisciplinasFormSubmitted('Raciocínio Lógico'),
    ),
    expect: () => [
      isA<DisciplinasFormState>().having(
        (state) => state.status,
        'status',
        DisciplinasFormStatus.submitting,
      ),
      isA<DisciplinasFormState>().having(
        (state) => state.status,
        'status',
        DisciplinasFormStatus.success,
      ),
    ],
  );

  blocTest<DisciplinasFormBloc, DisciplinasFormState>(
    'mantém o formulário aberto quando o nome viola uma regra',
    build: () {
      final useCases = DisciplinasUseCases(FakeDisciplinasRepository());
      return DisciplinasFormBloc(
        createDisciplina: useCases.createDisciplina,
        updateDisciplina: useCases.updateDisciplina,
      );
    },
    act: (bloc) => bloc.add(const DisciplinasFormSubmitted('   ')),
    expect: () => [
      isA<DisciplinasFormState>().having(
        (state) => state.status,
        'status',
        DisciplinasFormStatus.submitting,
      ),
      isA<DisciplinasFormState>()
          .having(
            (state) => state.status,
            'status',
            DisciplinasFormStatus.failure,
          )
          .having(
            (state) => state.errorMessage,
            'mensagem',
            'Informe um nome para a Disciplina.',
          ),
    ],
  );

  blocTest<DisciplinasFormBloc, DisciplinasFormState>(
    'conclui o formulário quando a criação foi salva mas a sincronização ficou pendente',
    build: () {
      final repository = FakeDisciplinasRepository()..failSynchronization = true;
      final useCases = DisciplinasUseCases(repository);
      return DisciplinasFormBloc(
        createDisciplina: useCases.createDisciplina,
        updateDisciplina: useCases.updateDisciplina,
      );
    },
    act: (bloc) => bloc.add(
      const DisciplinasFormSubmitted('Raciocínio Lógico'),
    ),
    expect: () => const [
      DisciplinasFormState(status: DisciplinasFormStatus.submitting),
      DisciplinasFormState(status: DisciplinasFormStatus.success),
    ],
  );

  test('atualiza a Disciplina selecionada', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );
    final bloc = DisciplinasFormBloc(
      createDisciplina: useCases.createDisciplina,
      updateDisciplina: useCases.updateDisciplina,
      disciplineId: 'portugues',
    );
    addTearDown(bloc.close);

    final completed = bloc.stream.firstWhere(
      (state) => state.status == DisciplinasFormStatus.success,
    );
    bloc.add(const DisciplinasFormSubmitted('Português'));
    await completed;
    final catalogResult = await useCases.getDisciplinas();

    expect(
      catalogResult,
      isA<Sucesso<List<Disciplina>>>().having(
        (success) => success.valor.first.name,
        'nome',
        'Português',
      ),
    );
  });
}
