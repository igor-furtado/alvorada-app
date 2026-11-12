import 'package:bloc_test/bloc_test.dart';
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
      return ConcursosFormBloc(
        createConcurso: useCases.createConcurso,
        updateConcurso: useCases.updateConcurso,
      );
    },
    act: (bloc) => bloc.add(
      const ConcursosFormSubmitted(
        instituicao: 'Câmara dos Deputados',
        cargo: 'Analista Legislativo',
        banca: null,
        dataProva: null,
        prioritario: false,
      ),
    ),
    expect: () => [
      const ConcursosFormState(status: ConcursosFormStatus.submitting),
      const ConcursosFormState(status: ConcursosFormStatus.success),
    ],
  );

  blocTest<ConcursosFormBloc, ConcursosFormState>(
    'conclui a edição quando os dados são válidos',
    build: () {
      final useCases = ConcursosUseCases(
        FakeConcursosRepository(concursos: concursosFixture()),
      );
      return ConcursosFormBloc(
        createConcurso: useCases.createConcurso,
        updateConcurso: useCases.updateConcurso,
        concursoId: 'trf5',
      );
    },
    act: (bloc) => bloc.add(
      const ConcursosFormSubmitted(
        instituicao: 'TRF da 5ª Região',
        cargo: 'Analista Judiciário',
        banca: 'FGV',
        dataProva: null,
        prioritario: true,
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
      return ConcursosFormBloc(
        createConcurso: useCases.createConcurso,
        updateConcurso: useCases.updateConcurso,
      );
    },
    act: (bloc) => bloc.add(
      const ConcursosFormSubmitted(
        instituicao: '',
        cargo: 'Analista',
        banca: null,
        dataProva: null,
        prioritario: false,
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
      return ConcursosFormBloc(
        createConcurso: useCases.createConcurso,
        updateConcurso: useCases.updateConcurso,
      );
    },
    act: (bloc) => bloc.add(
      const ConcursosFormSubmitted(
        instituicao: 'Câmara dos Deputados',
        cargo: 'Analista Legislativo',
        banca: null,
        dataProva: null,
        prioritario: false,
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
