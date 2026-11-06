import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../data/repositories/remote_study_repository.dart';
import '../../domain/entities/study_catalog.dart';
import '../../domain/repositories/study_repository.dart';

final dioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 8),
      headers: const {'content-type': 'application/json'},
    ),
  ),
);

final studyRepositoryProvider = Provider<StudyRepository>(
  (ref) => RemoteStudyRepository(ref.watch(dioProvider)),
);
final studyCatalogProvider =
    AsyncNotifierProvider<StudyCatalogNotifier, List<StudySubject>>(
      StudyCatalogNotifier.new,
    );

class StudyCatalogNotifier extends AsyncNotifier<List<StudySubject>> {
  StudyRepository get _repository => ref.read(studyRepositoryProvider);

  @override
  Future<List<StudySubject>> build() => _repository.getCatalog();

  Future<void> _mutate(Future<void> Function() operation) async {
    await operation();
    state = await AsyncValue.guard(_repository.getCatalog);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getCatalog);
  }

  Future<void> createSubject(String name, int difficulty, String color) =>
      _mutate(() => _repository.createSubject(name, difficulty, color));
  Future<void> updateSubject(
    String id, {
    String? name,
    int? difficulty,
    String? color,
  }) => _mutate(
    () => _repository.updateSubject(
      id,
      name: name,
      difficulty: difficulty,
      color: color,
    ),
  );
  Future<void> deleteSubject(String id) =>
      _mutate(() => _repository.deleteSubject(id));
  Future<void> createTopic(String subjectId, String name) =>
      _mutate(() => _repository.createTopic(subjectId, name));
  Future<void> updateTopic(String id, String name) =>
      _mutate(() => _repository.updateTopic(id, name));
  Future<void> deleteTopic(String id) =>
      _mutate(() => _repository.deleteTopic(id));
  Future<void> createSubtopic(String topicId, String name) =>
      _mutate(() => _repository.createSubtopic(topicId, name));
  Future<void> updateSubtopic(String id, String name) =>
      _mutate(() => _repository.updateSubtopic(id, name));
  Future<void> deleteSubtopic(String id) =>
      _mutate(() => _repository.deleteSubtopic(id));
}
