import 'package:bloc_test/bloc_test.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina_input.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/bloc/disciplinas_bloc.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/bloc/disciplinas_event.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/bloc/disciplinas_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  group('DisciplinasBloc', () {
    blocTest<DisciplinasBloc, DisciplinasState>(
      'carrega Disciplinas do repository',
      build: () => DisciplinasBloc(
        repository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      ),
      act: (bloc) => bloc.add(const LoadDisciplinasRequested()),
      expect: () => [
        isA<DisciplinasState>().having(
          (state) => state.status,
          'status',
          DisciplinasStatus.loading,
        ),
        isA<DisciplinasState>()
            .having((state) => state.status, 'status', DisciplinasStatus.success)
            .having((state) => state.disciplinas.length, 'disciplinas', 3),
      ],
    );

    blocTest<DisciplinasBloc, DisciplinasState>(
      'expõe falha quando o carregamento não conclui',
      build: () {
        final repository = FakeDisciplinasRepository()..failLoad = true;
        return DisciplinasBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const LoadDisciplinasRequested()),
      expect: () => [
        isA<DisciplinasState>().having(
          (state) => state.status,
          'status',
          DisciplinasStatus.loading,
        ),
        isA<DisciplinasState>().having(
          (state) => state.status,
          'status',
          DisciplinasStatus.failure,
        ),
      ],
    );

    blocTest<DisciplinasBloc, DisciplinasState>(
      'cria Disciplina e publica o catálogo atualizado',
      build: () => DisciplinasBloc(repository: FakeDisciplinasRepository()),
      act: (bloc) => bloc.add(
        const CreateDisciplinaRequested(
          CreateDisciplinaInput(name: 'Raciocínio Lógico'),
        ),
      ),
      expect: () => [
        isA<DisciplinasState>().having((state) => state.isMutating, 'mutating', isTrue),
        isA<DisciplinasState>()
            .having((state) => state.isMutating, 'mutating', isFalse)
            .having((state) => state.disciplinas.single.name, 'nome', 'Raciocínio Lógico')
            .having(
              (state) => state.feedback,
              'feedback',
              DisciplinasFeedback.disciplinaCriada,
            ),
      ],
    );

    test('filtra por nome de Subtópico', () {
      final state = DisciplinasState(
        status: DisciplinasStatus.success,
        disciplinas: disciplinasFixture(),
        query: 'remédios constitucionais',
      );

      expect(state.disciplinasVisiveis.single.name, 'Direito Constitucional');
    });
  });
}
