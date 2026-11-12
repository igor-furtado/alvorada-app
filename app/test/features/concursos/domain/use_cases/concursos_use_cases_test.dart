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

  test('edita o Concurso sem alterar o progresso do Edital', () async {
    final repository = FakeConcursosRepository(concursos: concursosFixture());
    final useCases = ConcursosUseCases(repository);

    final result = await useCases.updateConcurso(
      'trf5',
      const UpdateConcursoInput(
        instituicao: '  TRF da 5ª Região  ',
        cargo: '  Analista Judiciário  ',
        banca: '  FGV  ',
        prioritario: true,
        sigla: '  TRF5  ',
        quantidadeVagas: 25,
        vencimentoCentavos: 1234567,
        cargaHorariaSemanal: 40,
        localProva: '  Recife/PE  ',
        horarioInicioProva: ' 13:00 ',
        horarioFimProva: ' 18:00 ',
        requisitos: '  Nível superior  ',
        criteriosPontuacao: '  Pesos por bloco  ',
      ),
    );
    final concursos = await repository.getConcursos();
    final updated = concursos.firstWhere((item) => item.id == 'trf5');
    final previousPriority = concursos.firstWhere((item) => item.id == 'camara');

    expect(result, isA<Sucesso<void>>());
    expect(updated.instituicao, 'TRF da 5ª Região');
    expect(updated.cargo, 'Analista Judiciário');
    expect(updated.banca, 'FGV');
    expect(updated.progressoEdital, 72);
    expect(updated.prioritario, isTrue);
    expect(previousPriority.prioritario, isFalse);
    expect(updated.sigla, 'TRF5');
    expect(updated.quantidadeVagas, 25);
    expect(updated.vencimentoCentavos, 1234567);
    expect(updated.localProva, 'Recife/PE');
    expect(updated.horarioInicioProva, '13:00');
    expect(updated.requisitos, 'Nível superior');
  });

  test('rejeita horários de prova incompletos', () async {
    final useCases = ConcursosUseCases(FakeConcursosRepository());

    final result = await useCases.createConcurso(
      const CreateConcursoInput(
        instituicao: 'TRF da 5ª Região',
        cargo: 'Técnico Judiciário',
        horarioInicioProva: '13:00',
      ),
    );

    expect(
      result,
      isA<ViolacaoRegra<Concurso>>().having(
        (failure) => failure.codigo,
        'código',
        ConcursosResultadoCodes.horariosProvaInvalidos,
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
