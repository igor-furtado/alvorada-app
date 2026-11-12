import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/concurso_api_model.dart';

const defaultConcursosApiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

abstract interface class ConcursosApi {
  Future<List<ConcursoApiModel>> getConcursos();

  Future<String> createConcurso(Map<String, Object?> body);

  Future<void> updateConcurso(String id, Map<String, Object?> body);

  Future<void> setPrioritario(String id);

  Future<void> archiveConcurso(String id);

  Future<void> restoreConcurso(String id);

  Future<void> deleteConcurso(String id);

  Future<void> addDisciplinaToEdital({required String concursoId, required String disciplinaId});

  Future<void> addTopicoToEdital({required String concursoId, required String topicoId});

  Future<void> removeTopicoFromEdital({required String concursoId, required String topicoId});
}

class ConcursosApiService implements ConcursosApi {
  ConcursosApiService(this._client, {Uri? baseUri}) : _baseUri = baseUri ?? Uri.parse(defaultConcursosApiBaseUrl);

  final http.Client _client;
  final Uri _baseUri;

  @override
  Future<List<ConcursoApiModel>> getConcursos() async {
    final response = await _client.get(_uri('/api/v1/concursos'));
    final decoded = _decode(response, expectedStatus: 200);
    if (decoded is! List<Object?>) {
      throw const FormatException('A API deve retornar uma lista de Concursos.');
    }
    return decoded
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Cada Concurso retornado pela API deve ser um objeto.');
          }
          return ConcursoApiModel.fromJson(item);
        })
        .toList(growable: false);
  }

  @override
  Future<String> createConcurso(Map<String, Object?> body) async {
    final response = await _client.post(
      _uri('/api/v1/concursos'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    final decoded = _decode(response, expectedStatus: 201);
    if (decoded is Map<String, Object?> && decoded['id'] is String) {
      return decoded['id']! as String;
    }
    throw const FormatException('A API não retornou o identificador do Concurso criado.');
  }

  @override
  Future<void> updateConcurso(String id, Map<String, Object?> body) =>
      _sendEmpty('PUT', '/api/v1/concursos/${Uri.encodeComponent(id)}', body: body);

  @override
  Future<void> setPrioritario(String id) =>
      _sendEmpty('PUT', '/api/v1/concursos/${Uri.encodeComponent(id)}/prioridade');

  @override
  Future<void> archiveConcurso(String id) =>
      _sendEmpty('PUT', '/api/v1/concursos/${Uri.encodeComponent(id)}/arquivamento');

  @override
  Future<void> restoreConcurso(String id) =>
      _sendEmpty('DELETE', '/api/v1/concursos/${Uri.encodeComponent(id)}/arquivamento');

  @override
  Future<void> deleteConcurso(String id) => _sendEmpty('DELETE', '/api/v1/concursos/${Uri.encodeComponent(id)}');

  @override
  Future<void> addDisciplinaToEdital({required String concursoId, required String disciplinaId}) => _sendEmpty(
    'PUT',
    '/api/v1/concursos/${Uri.encodeComponent(concursoId)}/edital/disciplinas/${Uri.encodeComponent(disciplinaId)}',
  );

  @override
  Future<void> addTopicoToEdital({required String concursoId, required String topicoId}) => _sendEmpty(
    'PUT',
    '/api/v1/concursos/${Uri.encodeComponent(concursoId)}/edital/topicos/${Uri.encodeComponent(topicoId)}',
  );

  @override
  Future<void> removeTopicoFromEdital({required String concursoId, required String topicoId}) => _sendEmpty(
    'DELETE',
    '/api/v1/concursos/${Uri.encodeComponent(concursoId)}/edital/topicos/${Uri.encodeComponent(topicoId)}',
  );

  Future<void> _sendEmpty(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
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
      throw ConcursosApiException(
        statusCode: response.statusCode,
        message: _errorMessage(response.body),
      );
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _errorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?> && decoded['erro'] is String) {
        return decoded['erro']! as String;
      }
    } on FormatException {
      // The status code remains useful when an intermediary returns non-JSON.
    }
    return 'Não foi possível concluir a operação na API.';
  }
}

const _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8'};

class ConcursosApiException implements Exception {
  const ConcursosApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
