import 'package:estudos_app/src/features/studies/data/models/study_catalog_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converte o catálogo aninhado recebido pela API', () {
    final subject = StudyCatalogModel.subjectFromJson({
      'id': 'subject-1',
      'name': 'Língua Portuguesa',
      'difficulty': 4,
      'color': '#6657D9',
      'topics': [
        {
          'id': 'topic-1',
          'name': 'Sintaxe',
          'subtopics': [
            {'id': 'subtopic-1', 'name': 'Concordância'},
          ],
        },
      ],
    });

    expect(subject.name, 'Língua Portuguesa');
    expect(subject.difficulty.value, 4);
    expect(subject.topics.single.name, 'Sintaxe');
    expect(subject.subtopicCount, 1);
  });
}
