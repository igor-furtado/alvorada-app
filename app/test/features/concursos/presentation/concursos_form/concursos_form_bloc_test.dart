import 'package:bloc_test/bloc_test.dart';
import 'package:estudos_app/src/features/concursos/domain/models/concurso_input.dart';
import 'package:estudos_app/src/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/src/features/concursos/presentation/concursos_form/concursos_form_bloc.dart';
import 'package:estudos_app/src/features/concursos/presentation/concursos_form/concursos_form_event.dart';
import 'package:estudos_app/src/features/concursos/presentation/concursos_form/concursos_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_concursos_repository.dart';

void main() {
  blocTest<ConcursosFormBloc, ConcursosFormState>(
    'conclui o cadastro quando os dados são válidos',
    build: () {
      final useCases = ConcursosUseCases(FakeConcursosRepository());
      return ConcursosFormBloc(createConcurso: useCases.createConcurso);
    },
    act: (bloc) => bloc.add(
      const ConcursosFormSubmitted(
        CreateConcursoInput(
          instituicao: 'Câmara dos Deputados',
          cargo: 'Analista Legislativo',
        ),
      ),
    ),
    expect: () => [
      const ConcursosFormState(status: ConcursosFormStatus.submitting),
      const ConcursosFormState(status: ConcursosFormStatus.success),
    ],
  );

  blocTest<ConcursosFormBloc, ConcursosFormState>(
    'mantém o formulário aberto quando o domínio rejeita os dados',
    build: () {
      final useCases = ConcursosUseCases(FakeConcursosRepository());
      return ConcursosFormBloc(createConcurso: useCases.createConcurso);
    },
    act: (bloc) => bloc.add(
      const ConcursosFormSubmitted(
        CreateConcursoInput(instituicao: '', cargo: 'Analista'),
      ),
    ),
    expect: () => [
      const ConcursosFormState(status: ConcursosFormStatus.submitting),
      isA<ConcursosFormState>()
          .having(
            (state) => state.status,
            'status',
            ConcursosFormStatus.failure,
          )
          .having(
            (state) => state.errorMessage,
            'mensagem',
            isNotEmpty,
          ),
    ],
  );

  blocTest<ConcursosFormBloc, ConcursosFormState>(
    'conclui o formulário quando o cadastro foi salvo mas a sincronização ficou pendente',
    build: () {
      final repository = FakeConcursosRepository()..failSynchronization = true;
      final useCases = ConcursosUseCases(repository);
      return ConcursosFormBloc(createConcurso: useCases.createConcurso);
    },
    act: (bloc) => bloc.add(
      const ConcursosFormSubmitted(
        CreateConcursoInput(
          instituicao: 'Câmara dos Deputados',
          cargo: 'Analista Legislativo',
        ),
      ),
    ),
    expect: () => [
      isA<ConcursosFormState>().having(
        (state) => state.status,
        'status',
        ConcursosFormStatus.submitting,
      ),
      isA<ConcursosFormState>().having(
        (state) => state.status,
        'status',
        ConcursosFormStatus.success,
      ),
    ],
  );
}
