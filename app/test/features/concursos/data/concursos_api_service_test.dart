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
    expect(concursos.single.sigla, 'CD');
    expect(concursos.single.vencimentoCentavos, 2200000);
    expect(concursos.single.horarioInicioProva, '13:00');
    expect(concursos.single.disciplinas.single.nome, 'Direito Tributário');
    expect(concursos.single.disciplinas.single.topicos.last.obrigatorio, isTrue);
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

  test('atualiza o Concurso com os campos editáveis', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PUT');
      expect(request.url.path, '/api/v1/concursos/concurso-2');
      expect(jsonDecode(request.body), {
        'instituicao': 'TRF da 5ª Região',
        'cargo': 'Analista Judiciário',
        'banca': null,
        'data_prova': null,
        'prioritario': false,
      });
      return http.Response('', 204);
    });
    final service = ConcursosApiService(
      client,
      baseUri: Uri.parse('http://api.test'),
    );

    await service.updateConcurso('concurso-2', {
      'instituicao': 'TRF da 5ª Região',
      'cargo': 'Analista Judiciário',
      'banca': null,
      'data_prova': null,
      'prioritario': false,
    });
  });

  test('vincula Disciplina e adiciona ou remove Tópico do Edital', () async {
    final requests = <String>[];
    final client = MockClient((request) async {
      requests.add('${request.method} ${request.url.path}');
      return http.Response('', 204);
    });
    final service = ConcursosApiService(client, baseUri: Uri.parse('http://api.test'));

    await service.addDisciplinaToEdital(concursoId: 'concurso-1', disciplinaId: 'disciplina-1');
    await service.addTopicoToEdital(concursoId: 'concurso-1', topicoId: 'topico-1');
    await service.removeTopicoFromEdital(concursoId: 'concurso-1', topicoId: 'topico-1');

    expect(requests, [
      'PUT /api/v1/concursos/concurso-1/edital/disciplinas/disciplina-1',
      'PUT /api/v1/concursos/concurso-1/edital/topicos/topico-1',
      'DELETE /api/v1/concursos/concurso-1/edital/topicos/topico-1',
    ]);
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
  'sigla': 'CD',
  'quantidade_vagas': 100,
  'vencimento_centavos': 2200000,
  'carga_horaria_semanal': 40,
  'local_prova': 'Brasília/DF',
  'horario_inicio_prova': '13:00',
  'horario_fim_prova': '18:00',
  'requisitos': 'Nível superior',
  'criterios_pontuacao': 'Pesos por bloco',
  'disciplinas': <Object?>[
    {
      'id': 'disciplina-1',
      'nome': 'Direito Tributário',
      'topicos': <Object?>[
        {'id': 'topico-1', 'nome': 'Obrigação tributária', 'obrigatorio': false},
        {'id': 'topico-revisao', 'nome': 'Revisão de Véspera', 'obrigatorio': true},
      ],
    },
  ],
};
