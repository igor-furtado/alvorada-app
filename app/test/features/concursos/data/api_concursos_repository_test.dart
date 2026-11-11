import 'package:estudos_app/src/features/concursos/data/models/concurso_api_model.dart';
import 'package:estudos_app/src/features/concursos/data/repositories/api_concursos_repository.dart';
import 'package:estudos_app/src/features/concursos/data/services/concursos_api_service.dart';
import 'package:estudos_app/src/features/concursos/domain/models/concurso_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('usa cache até que uma atualização seja solicitada', () async {
    final api = _FakeApi();
    final repository = ApiConcursosRepository(api);

    final first = await repository.getConcursos();
    final cached = await repository.getConcursos();
    await repository.getConcursos(forceRefresh: true);

    expect(identical(first, cached), isTrue);
    expect(api.getCalls, 2);
  });

  test('serializa a data e retorna o Concurso criado', () async {
    final api = _FakeApi();
    final repository = ApiConcursosRepository(api);

    final created = await repository.createConcurso(
      CreateConcursoInput(
        instituicao: 'TRF da 5ª Região',
        cargo: 'Técnico Judiciário',
        dataProva: DateTime(2026, 12, 13),
      ),
    );

    expect(created.id, 'concurso-1');
    expect(api.createdBody?['data_prova'], '2026-12-13');
  });
}

class _FakeApi implements ConcursosApi {
  int getCalls = 0;
  Map<String, Object?>? createdBody;

  @override
  Future<List<ConcursoApiModel>> getConcursos() async {
    getCalls++;
    return const [_concurso];
  }

  @override
  Future<String> createConcurso(Map<String, Object?> body) async {
    createdBody = body;
    return 'concurso-1';
  }

  @override
  Future<void> archiveConcurso(String id) async {}

  @override
  Future<void> deleteConcurso(String id) async {}

  @override
  Future<void> restoreConcurso(String id) async {}

  @override
  Future<void> setPrioritario(String id) async {}
}

const _concurso = ConcursoApiModel(
  id: 'concurso-1',
  instituicao: 'TRF da 5ª Região',
  cargo: 'Técnico Judiciário',
  banca: 'FCC',
  dataProva: '2026-12-13',
  prioritario: false,
  progressoEdital: 0,
);
