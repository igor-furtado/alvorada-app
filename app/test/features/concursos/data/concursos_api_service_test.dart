import 'dart:convert';

import 'package:estudos_app/src/features/concursos/data/services/concursos_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('carrega os Concursos retornados pela API', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), 'http://api.test/api/v1/concursos');
      return http.Response(
        jsonEncode([_concursoJson]),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = ConcursosApiService(client, baseUri: Uri.parse('http://api.test'));

    final concursos = await service.getConcursos();

    expect(concursos.single.instituicao, 'Câmara dos Deputados');
    expect(concursos.single.progressoEdital, 48);
  });

  test('envia dados em português e retorna o id criado', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(jsonDecode(request.body), {
        'instituicao': 'TRF da 5ª Região',
        'cargo': 'Técnico Judiciário',
        'banca': 'FCC',
        'data_prova': '2026-12-13',
        'prioritario': true,
      });
      return http.Response(jsonEncode({'id': 'concurso-2'}), 201);
    });
    final service = ConcursosApiService(client, baseUri: Uri.parse('http://api.test'));

    final id = await service.createConcurso({
      'instituicao': 'TRF da 5ª Região',
      'cargo': 'Técnico Judiciário',
      'banca': 'FCC',
      'data_prova': '2026-12-13',
      'prioritario': true,
    });

    expect(id, 'concurso-2');
  });

  test('usa operação explícita para definir o Concurso prioritário', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PUT');
      expect(request.url.path, '/api/v1/concursos/concurso-2/prioridade');
      return http.Response('', 204);
    });
    final service = ConcursosApiService(client, baseUri: Uri.parse('http://api.test'));

    await service.setPrioritario('concurso-2');
  });
}

const _concursoJson = <String, Object?>{
  'id': 'concurso-1',
  'instituicao': 'Câmara dos Deputados',
  'cargo': 'Analista Legislativo',
  'banca': 'Cebraspe',
  'data_prova': '2027-02-21',
  'prioritario': true,
  'progresso_edital': 48,
};
