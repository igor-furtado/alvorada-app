import 'package:estudos_app/src/core/domain/resultado.dart';
import 'package:estudos_app/src/features/concursos/domain/models/concurso.dart';
import 'package:estudos_app/src/features/concursos/domain/models/concurso_input.dart';
import 'package:estudos_app/src/features/concursos/domain/use_cases/concursos_resultado_codes.dart';
import 'package:estudos_app/src/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_concursos_repository.dart';

void main() {
  test('busca um Concurso pelo identificador da rota', () async {
    final useCases = ConcursosUseCases(
      FakeConcursosRepository(concursos: concursosFixture()),
    );

    final result = await useCases.getConcurso('trf5');

    expect(
      result,
      isA<Sucesso<Concurso>>().having(
        (success) => success.valor.id,
        'identificador',
        'trf5',
      ),
    );
  });

  test('informa quando o Concurso da rota não existe', () async {
    final useCases = ConcursosUseCases(FakeConcursosRepository());

    final result = await useCases.getConcurso('inexistente');

    expect(
      result,
      isA<ViolacaoRegra<Concurso>>().having(
        (failure) => failure.codigo,
        'código',
        ConcursosResultadoCodes.concursoNaoEncontrado,
      ),
    );
  });

  test('cria o Concurso com os textos normalizados', () async {
    final useCases = ConcursosUseCases(FakeConcursosRepository());

    final result = await useCases.createConcurso(
      const CreateConcursoInput(
        instituicao: '  TRF da 5ª Região  ',
        cargo: '  Técnico Judiciário  ',
        banca: '  FCC  ',
      ),
    );

    expect(
      result,
      isA<Sucesso<Concurso>>()
          .having(
            (success) => success.valor.instituicao,
            'instituição',
            'TRF da 5ª Região',
          )
          .having(
            (success) => success.valor.cargo,
            'cargo',
            'Técnico Judiciário',
          )
          .having(
            (success) => success.valor.banca,
            'banca',
            'FCC',
          ),
    );
  });

  test('rejeita Concurso sem instituição', () async {
    final useCases = ConcursosUseCases(FakeConcursosRepository());

    final result = await useCases.createConcurso(
      const CreateConcursoInput(instituicao: '  ', cargo: 'Analista'),
    );

    expect(
      result,
      isA<ViolacaoRegra<Concurso>>().having(
        (failure) => failure.codigo,
        'código',
        ConcursosResultadoCodes.instituicaoObrigatoria,
      ),
    );
  });

  test('traduz falha de sincronização ao arquivar', () async {
    final repository = FakeConcursosRepository(
      concursos: concursosFixture(),
    )..failSynchronization = true;
    final useCases = ConcursosUseCases(repository);

    final result = await useCases.archiveConcurso('trf5');

    expect(
      result,
      isA<FalhaTecnica<void>>().having(
        (failure) => failure.codigo,
        'código',
        ConcursosResultadoCodes.sincronizacaoPendente,
      ),
    );
  });
}
