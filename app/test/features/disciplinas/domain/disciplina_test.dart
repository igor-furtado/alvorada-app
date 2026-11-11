import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Disciplina', () {
    test('aceita exatamente uma Revisão de Véspera na última posição', () {
      final discipline = _discipline();

      expect(discipline.topics.last.mandatory, isTrue);
      expect(discipline.subtopicCount, 1);
    });

    test('rejeita catálogo sem Revisão de Véspera', () {
      expect(
        () => Disciplina(
          id: 'discipline-1',
          name: 'Direito Constitucional',
          difficulty: DificuldadeDisciplina.hard,
          color: '#3178C6',
          topics: [Topico(id: 'topic-1', name: 'Direitos fundamentais', mandatory: false, subtopics: const [])],
        ),
        throwsFormatException,
      );
    });
  });
}

Disciplina _discipline() => Disciplina(
  id: 'discipline-1',
  name: 'Direito Constitucional',
  difficulty: DificuldadeDisciplina.hard,
  color: '#3178C6',
  topics: [
    Topico(
      id: 'topic-1',
      name: 'Direitos fundamentais',
      mandatory: false,
      subtopics: const [Subtopico(id: 'subtopic-1', name: 'Direitos individuais')],
    ),
    Topico(id: 'topic-2', name: nomeTopicoRevisaoVespera, mandatory: true, subtopics: const []),
  ],
);
