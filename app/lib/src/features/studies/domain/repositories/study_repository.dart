import '../entities/study_catalog.dart';

abstract interface class StudyRepository {
  Future<List<StudySubject>> getCatalog();
  Future<void> createSubject(String name, int difficulty, String color);
  Future<void> updateSubject(
    String id, {
    String? name,
    int? difficulty,
    String? color,
  });
  Future<void> deleteSubject(String id);
  Future<void> createTopic(String subjectId, String name);
  Future<void> updateTopic(String id, String name);
  Future<void> deleteTopic(String id);
  Future<void> createSubtopic(String topicId, String name);
  Future<void> updateSubtopic(String id, String name);
  Future<void> deleteSubtopic(String id);
}
