import 'package:flutter/material.dart';

enum Difficulty {
  veryEasy(1, 'Muito fácil', Color(0xFF42A882)),
  easy(2, 'Fácil', Color(0xFF69A86A)),
  medium(3, 'Média', Color(0xFFE0A13B)),
  hard(4, 'Difícil', Color(0xFFE47A4F)),
  veryHard(5, 'Muito difícil', Color(0xFFD95562));

  const Difficulty(this.value, this.label, this.color);
  final int value;
  final String label;
  final Color color;

  static Difficulty fromValue(int value) =>
      values.firstWhere((item) => item.value == value);
}

class StudySubject {
  const StudySubject({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.colorHex,
    required this.topics,
  });
  final String id;
  final String name;
  final Difficulty difficulty;
  final String colorHex;
  final List<StudyTopic> topics;

  Color get color =>
      Color(int.parse('FF${colorHex.replaceFirst('#', '')}', radix: 16));
  int get subtopicCount =>
      topics.fold(0, (total, topic) => total + topic.subtopics.length);
}

class StudyTopic {
  const StudyTopic({
    required this.id,
    required this.name,
    required this.subtopics,
  });
  final String id;
  final String name;
  final List<StudySubtopic> subtopics;
}

class StudySubtopic {
  const StudySubtopic({required this.id, required this.name});
  final String id;
  final String name;
}
