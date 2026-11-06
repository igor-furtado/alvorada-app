import '../../domain/entities/study_catalog.dart';

abstract final class StudyCatalogModel {
  static StudySubject subjectFromJson(Map<String, dynamic> json) =>
      StudySubject(
        id: json['id'] as String,
        name: json['name'] as String,
        difficulty: Difficulty.fromValue(json['difficulty'] as int),
        colorHex: json['color'] as String,
        topics: (json['topics'] as List<dynamic>)
            .map((item) => topicFromJson(item as Map<String, dynamic>))
            .toList(),
      );

  static StudyTopic topicFromJson(Map<String, dynamic> json) => StudyTopic(
    id: json['id'] as String,
    name: json['name'] as String,
    subtopics: (json['subtopics'] as List<dynamic>)
        .map(
          (item) => StudySubtopic(
            id: (item as Map<String, dynamic>)['id'] as String,
            name: item['name'] as String,
          ),
        )
        .toList(),
  );
}
