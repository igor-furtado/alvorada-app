import 'dart:convert';

import 'package:estudos_app/src/features/disciplinas/data/services/disciplinas_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('carrega e converte o catálogo retornado pela API', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), 'http://api.test/api/v1/subjects');
      return http.Response(jsonEncode([_disciplineJson]), 200, headers: {'content-type': 'application/json'});
    });
    final service = DisciplinasApiService(client, baseUri: Uri.parse('http://api.test'));

    final disciplines = await service.getDisciplinas();

    expect(disciplines.single.name, 'Direito Constitucional');
    expect(disciplines.single.topics.last.mandatory, isTrue);
  });

  test('envia os dados da nova Disciplina e retorna o id', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(jsonDecode(request.body), {
        'nome': 'Português',
        'dificuldade': 3,
        'cor': '#E8742A',
      });
      return http.Response(jsonEncode({'id': 'discipline-2'}), 201);
    });
    final service = DisciplinasApiService(client, baseUri: Uri.parse('http://api.test'));

    final id = await service.createDisciplina({'nome': 'Português', 'dificuldade': 3, 'cor': '#E8742A'});

    expect(id, 'discipline-2');
  });

  test('preserva a mensagem de validação devolvida pela API', () async {
    final client = MockClient((_) async => http.Response(jsonEncode({'erro': 'informe um nome'}), 400));
    final service = DisciplinasApiService(client, baseUri: Uri.parse('http://api.test'));

    expect(
      () => service.createTopico('discipline-1', ''),
      throwsA(
        isA<DisciplinasApiException>()
            .having((error) => error.statusCode, 'statusCode', 400)
            .having((error) => error.message, 'message', 'informe um nome'),
      ),
    );
  });
}

const _disciplineJson = <String, Object?>{
  'id': 'discipline-1',
  'nome': 'Direito Constitucional',
  'dificuldade': 4,
  'cor': '#3178C6',
  'topicos': [
    {
      'id': 'topic-1',
      'nome': 'Direitos fundamentais',
      'obrigatorio': false,
      'subtopicos': [
        {'id': 'subtopic-1', 'nome': 'Direitos individuais'},
      ],
    },
    {'id': 'topic-2', 'nome': 'Revisão de Véspera', 'obrigatorio': true, 'subtopicos': <Object?>[]},
  ],
};
