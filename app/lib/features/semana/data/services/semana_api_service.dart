import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/planejamento_semanal_api_model.dart';

const defaultSemanaApiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

abstract interface class SemanaApi {
  Future<PlanejamentoSemanalApiModel> getPlanejamento(DateTime inicio, DateTime fim);

  Future<void> planejarTopico({
    required String concursoId,
    required String topicoId,
    required DateTime data,
    required int posicaoDia,
  });

  Future<void> atualizarProgresso({
    required String concursoId,
    required String topicoId,
    required Map<String, Object?> body,
  });

  Future<void> registrarQuestao({
    required String concursoId,
    required String topicoId,
    required String resultado,
  });

  Future<void> substituirRevisoes({
    required String concursoId,
    required String topicoId,
    required List<int> intervalosDias,
  });

  Future<void> moverRevisao({
    required String revisaoId,
    required DateTime data,
    required int posicaoDia,
  });

  Future<void> concluirRevisao(String revisaoId);
}

class SemanaApiService implements SemanaApi {
  SemanaApiService(this._client, {Uri? baseUri}) : _baseUri = baseUri ?? Uri.parse(defaultSemanaApiBaseUrl);

  final http.Client _client;
  final Uri _baseUri;

  @override
  Future<PlanejamentoSemanalApiModel> getPlanejamento(DateTime inicio, DateTime fim) async {
    final uri = _uri('/api/v1/semana').replace(
      queryParameters: {'inicio': _dateOnly(inicio), 'fim': _dateOnly(fim)},
    );
    final response = await _client.get(uri);
    final decoded = _decode(response, expectedStatus: 200);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('A API deve retornar o planejamento semanal como um objeto.');
    }
    return PlanejamentoSemanalApiModel.fromJson(decoded);
  }

  @override
  Future<void> planejarTopico({
    required String concursoId,
    required String topicoId,
    required DateTime data,
    required int posicaoDia,
  }) => _sendEmpty(
    'PUT',
    '/api/v1/concursos/${Uri.encodeComponent(concursoId)}/topicos/${Uri.encodeComponent(topicoId)}/planejamento',
    body: {'data_planejada': _dateOnly(data), 'posicao_dia': posicaoDia},
  );

  @override
  Future<void> atualizarProgresso({
    required String concursoId,
    required String topicoId,
    required Map<String, Object?> body,
  }) => _sendEmpty(
    'PATCH',
    '/api/v1/concursos/${Uri.encodeComponent(concursoId)}/topicos/${Uri.encodeComponent(topicoId)}/progresso',
    body: body,
  );

  @override
  Future<void> registrarQuestao({
    required String concursoId,
    required String topicoId,
    required String resultado,
  }) => _sendEmpty(
    'POST',
    '/api/v1/concursos/${Uri.encodeComponent(concursoId)}/topicos/${Uri.encodeComponent(topicoId)}/questoes',
    body: {'resultado': resultado},
  );

  @override
  Future<void> substituirRevisoes({
    required String concursoId,
    required String topicoId,
    required List<int> intervalosDias,
  }) => _sendEmpty(
    'PUT',
    '/api/v1/concursos/${Uri.encodeComponent(concursoId)}/topicos/${Uri.encodeComponent(topicoId)}/revisoes',
    body: {'intervalos_dias': intervalosDias},
  );

  @override
  Future<void> moverRevisao({
    required String revisaoId,
    required DateTime data,
    required int posicaoDia,
  }) => _sendEmpty(
    'PATCH',
    '/api/v1/revisoes/${Uri.encodeComponent(revisaoId)}/planejamento',
    body: {'data_planejada': _dateOnly(data), 'posicao_dia': posicaoDia},
  );

  @override
  Future<void> concluirRevisao(String revisaoId) =>
      _sendEmpty('PUT', '/api/v1/revisoes/${Uri.encodeComponent(revisaoId)}/conclusao');

  Future<void> _sendEmpty(String method, String path, {Map<String, Object?>? body}) async {
    final request = http.Request(method, _uri(path));
    if (body != null) {
      request.headers.addAll(_jsonHeaders);
      request.body = jsonEncode(body);
    }
    final response = await http.Response.fromStream(await _client.send(request));
    _decode(response, expectedStatus: 204);
  }

  Uri _uri(String path) => _baseUri.resolve(path);

  Object? _decode(http.Response response, {required int expectedStatus}) {
    if (response.statusCode != expectedStatus) {
      throw SemanaApiException(statusCode: response.statusCode, message: _errorMessage(response.body));
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _errorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?> && decoded['erro'] is String) return decoded['erro']! as String;
    } on FormatException {
      // Preserve the status code when an intermediary returns non-JSON.
    }
    return 'Não foi possível concluir a operação na API.';
  }
}

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

const _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8'};

class SemanaApiException implements Exception {
  const SemanaApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
