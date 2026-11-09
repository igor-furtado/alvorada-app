import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/disciplina_api_model.dart';

const defaultApiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

abstract interface class DisciplinasApi {
  Future<List<DisciplinaApiModel>> getDisciplinas();

  Future<String> createDisciplina(Map<String, Object?> body);

  Future<void> updateDisciplina(String id, Map<String, Object?> body);

  Future<void> deleteDisciplina(String id);

  Future<void> createTopico(String disciplineId, String name);

  Future<void> updateTopico(String topicId, String name);

  Future<void> deleteTopico(String topicId);

  Future<void> createSubtopico(String topicId, String name);

  Future<void> updateSubtopico(String subtopicId, String name);

  Future<void> deleteSubtopico(String subtopicId);
}

class DisciplinasApiService implements DisciplinasApi {
  DisciplinasApiService(this._client, {Uri? baseUri}) : _baseUri = baseUri ?? Uri.parse(defaultApiBaseUrl);

  final http.Client _client;
  final Uri _baseUri;

  @override
  Future<List<DisciplinaApiModel>> getDisciplinas() async {
    final response = await _client.get(_uri('/api/v1/subjects'));
    final decoded = _decode(response, expectedStatus: 200);
    if (decoded is! List<Object?>) {
      throw const FormatException('A API deve retornar uma lista de Disciplinas.');
    }
    return decoded
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Cada Disciplina retornada pela API deve ser um objeto.');
          }
          return DisciplinaApiModel.fromJson(item);
        })
        .toList(growable: false);
  }

  @override
  Future<String> createDisciplina(Map<String, Object?> body) async {
    final response = await _client.post(_uri('/api/v1/subjects'), headers: _jsonHeaders, body: jsonEncode(body));
    final decoded = _decode(response, expectedStatus: 201);
    if (decoded is Map<String, Object?>) {
      final id = decoded['id'];
      if (id is String) return id;
    }
    throw const FormatException('A API não retornou o identificador da Disciplina criada.');
  }

  @override
  Future<void> updateDisciplina(String id, Map<String, Object?> body) =>
      _sendEmpty('PATCH', '/api/v1/subjects/${Uri.encodeComponent(id)}', body: body);

  @override
  Future<void> deleteDisciplina(String id) => _sendEmpty('DELETE', '/api/v1/subjects/${Uri.encodeComponent(id)}');

  @override
  Future<void> createTopico(String disciplineId, String name) =>
      _sendCreated('/api/v1/subjects/${Uri.encodeComponent(disciplineId)}/topics', name);

  @override
  Future<void> updateTopico(String topicId, String name) =>
      _sendEmpty('PATCH', '/api/v1/topics/${Uri.encodeComponent(topicId)}', body: {'nome': name});

  @override
  Future<void> deleteTopico(String topicId) => _sendEmpty('DELETE', '/api/v1/topics/${Uri.encodeComponent(topicId)}');

  @override
  Future<void> createSubtopico(String topicId, String name) =>
      _sendCreated('/api/v1/topics/${Uri.encodeComponent(topicId)}/subtopics', name);

  @override
  Future<void> updateSubtopico(String subtopicId, String name) =>
      _sendEmpty('PATCH', '/api/v1/subtopics/${Uri.encodeComponent(subtopicId)}', body: {'nome': name});

  @override
  Future<void> deleteSubtopico(String subtopicId) =>
      _sendEmpty('DELETE', '/api/v1/subtopics/${Uri.encodeComponent(subtopicId)}');

  Future<void> _sendCreated(String path, String name) async {
    final response = await _client.post(_uri(path), headers: _jsonHeaders, body: jsonEncode({'nome': name}));
    _decode(response, expectedStatus: 201);
  }

  Future<void> _sendEmpty(String method, String path, {Map<String, Object?>? body}) async {
    final request = http.Request(method, _uri(path));
    if (body != null) {
      request.headers.addAll(_jsonHeaders);
      request.body = jsonEncode(body);
    }
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    _decode(response, expectedStatus: 204);
  }

  Uri _uri(String path) => _baseUri.resolve(path);

  Object? _decode(http.Response response, {required int expectedStatus}) {
    if (response.statusCode != expectedStatus) {
      throw DisciplinasApiException(
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
      if (decoded is Map<String, Object?>) {
        final message = decoded['erro'];
        if (message is String) return message;
      }
    } on FormatException {
      // The status code remains useful when an intermediary returns non-JSON.
    }
    return 'Não foi possível concluir a operação na API.';
  }
}

const _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8'};

class DisciplinasApiException implements Exception {
  const DisciplinasApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
