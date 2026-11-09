import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina_input.dart';
import 'package:estudos_app/src/features/disciplinas/domain/repositories/disciplinas_repository.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/create_disciplina_use_case.dart';
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

  group('CreateDisciplinaUseCase', () {
    test('normaliza o nome antes de enviar ao repositório', () async {
      final repository = _FakeRepository();
      final createDisciplina = CreateDisciplinaUseCase(repository);

      await createDisciplina(const CreateDisciplinaInput(name: '  Direito Constitucional  '));

      expect(repository.createdInput?.name, 'Direito Constitucional');
    });

    test('rejeita cor fora do contrato da API', () {
      final createDisciplina = CreateDisciplinaUseCase(_FakeRepository());

      expect(
        () => createDisciplina(const CreateDisciplinaInput(name: 'Português', color: 'laranja')),
        throwsA(isA<DisciplinaInputException>()),
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

class _FakeRepository implements DisciplinasRepository {
  CreateDisciplinaInput? createdInput;

  @override
  Future<Disciplina> createDisciplina(CreateDisciplinaInput input) async {
    createdInput = input;
    return _discipline();
  }

  @override
  Future<void> createSubtopico({required String topicId, required String name}) async {}

  @override
  Future<void> createTopico({required String disciplineId, required String name}) async {}

  @override
  Future<void> deleteDisciplina(String id) async {}

  @override
  Future<void> deleteSubtopico(String subtopicId) async {}

  @override
  Future<void> deleteTopico(String topicId) async {}

  @override
  Future<List<Disciplina>> getDisciplinas({bool forceRefresh = false}) async => [_discipline()];

  @override
  Future<void> updateDisciplina(String id, UpdateDisciplinaInput input) async {}

  @override
  Future<void> updateSubtopico({required String subtopicId, required String name}) async {}

  @override
  Future<void> updateTopico({required String topicId, required String name}) async {}
}
