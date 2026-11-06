import 'package:dio/dio.dart';

import '../../domain/entities/study_catalog.dart';
import '../../domain/repositories/study_repository.dart';
import '../models/study_catalog_model.dart';

final class RemoteStudyRepository implements StudyRepository {
  const RemoteStudyRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<StudySubject>> getCatalog() async {
    final response = await _dio.get<List<dynamic>>('/subjects');
    return response.data!
        .map(
          (json) =>
              StudyCatalogModel.subjectFromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> createSubject(String name, int difficulty, String color) =>
      _dio.post<void>(
        '/subjects',
        data: {'name': name, 'difficulty': difficulty, 'color': color},
      );
  @override
  Future<void> updateSubject(
    String id, {
    String? name,
    int? difficulty,
    String? color,
  }) {
    final data = <String, Object>{};
    if (name != null) data['name'] = name;
    if (difficulty != null) data['difficulty'] = difficulty;
    if (color != null) data['color'] = color;
    return _dio.patch<void>('/subjects/$id', data: data);
  }

  @override
  Future<void> deleteSubject(String id) => _dio.delete<void>('/subjects/$id');
  @override
  Future<void> createTopic(String subjectId, String name) =>
      _dio.post<void>('/subjects/$subjectId/topics', data: {'name': name});
  @override
  Future<void> updateTopic(String id, String name) =>
      _dio.patch<void>('/topics/$id', data: {'name': name});
  @override
  Future<void> deleteTopic(String id) => _dio.delete<void>('/topics/$id');
  @override
  Future<void> createSubtopic(String topicId, String name) =>
      _dio.post<void>('/topics/$topicId/subtopics', data: {'name': name});
  @override
  Future<void> updateSubtopic(String id, String name) =>
      _dio.patch<void>('/subtopics/$id', data: {'name': name});
  @override
  Future<void> deleteSubtopic(String id) => _dio.delete<void>('/subtopics/$id');
}
