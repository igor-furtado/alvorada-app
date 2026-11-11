import 'dart:async';

import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina_input.dart';
import 'package:estudos_app/src/features/disciplinas/domain/repositories/disciplinas_repository.dart';

class FakeDisciplinasRepository implements DisciplinasRepository {
  FakeDisciplinasRepository({List<Disciplina>? disciplinas}) : _disciplinas = [...?disciplinas];

  final List<Disciplina> _disciplinas;
  bool failLoad = false;
  bool failMutation = false;
  bool failSynchronization = false;
  Completer<void>? deleteSubtopicoGate;
  var _nextId = 100;

  @override
  Future<List<Disciplina>> getDisciplinas({bool forceRefresh = false}) async {
    if (failLoad) throw const DisciplinasRepositoryException('Falha simulada.');
    return List.unmodifiable(_disciplinas);
  }

  @override
  Future<Disciplina> createDisciplina(CreateDisciplinaInput input) async {
    _throwIfMutationFails();
    final disciplina = Disciplina(
      id: _id('disciplina'),
      name: input.name,
      difficulty: input.difficulty,
      color: input.color,
      topics: [_mandatoryTopico(_id('topico'))],
    );
    _disciplinas.add(disciplina);
    return disciplina;
  }

  @override
  Future<void> updateDisciplina(String id, UpdateDisciplinaInput input) async {
    _throwIfMutationFails();
    final index = _disciplinas.indexWhere((item) => item.id == id);
    final current = _disciplinas[index];
    _disciplinas[index] = Disciplina(
      id: current.id,
      name: input.name ?? current.name,
      difficulty: input.difficulty ?? current.difficulty,
      color: input.color ?? current.color,
      topics: current.topics,
    );
  }

  @override
  Future<void> deleteDisciplina(String id) async {
    _throwIfMutationFails();
    _disciplinas.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> createTopico({required String disciplineId, required String name}) async {
    _throwIfMutationFails();
    _replaceDisciplina(
      disciplineId,
      (disciplina) => [
        ...disciplina.topics.take(disciplina.topics.length - 1),
        Topico(id: _id('topico'), name: name, mandatory: false, subtopics: const []),
        disciplina.topics.last,
      ],
    );
  }

  @override
  Future<void> updateTopico({required String topicId, required String name}) async {
    _throwIfMutationFails();
    _mapTopico(
      topicId,
      (topico) => Topico(
        id: topico.id,
        name: name,
        mandatory: topico.mandatory,
        subtopics: topico.subtopics,
      ),
    );
  }

  @override
  Future<void> deleteTopico(String topicId) async {
    _throwIfMutationFails();
    for (final disciplina in [..._disciplinas]) {
      if (disciplina.topics.any((item) => item.id == topicId)) {
        _replaceDisciplina(
          disciplina.id,
          (current) => current.topics.where((item) => item.id != topicId).toList(),
        );
        return;
      }
    }
  }

  @override
  Future<void> createSubtopico({required String topicId, required String name}) async {
    _throwIfMutationFails();
    _mapTopico(
      topicId,
      (topico) => Topico(
        id: topico.id,
        name: topico.name,
        mandatory: topico.mandatory,
        subtopics: [
          ...topico.subtopics,
          Subtopico(id: _id('subtopico'), name: name),
        ],
      ),
    );
  }

  @override
  Future<void> updateSubtopico({required String subtopicId, required String name}) async {
    _throwIfMutationFails();
    _mapSubtopico(
      subtopicId,
      (subtopico) => Subtopico(id: subtopico.id, name: name),
    );
  }

  @override
  Future<void> deleteSubtopico(String subtopicId) async {
    _throwIfMutationFails();
    await deleteSubtopicoGate?.future;
    for (final disciplina in [..._disciplinas]) {
      for (final topico in disciplina.topics) {
        if (topico.subtopics.any((item) => item.id == subtopicId)) {
          _mapTopico(
            topico.id,
            (current) => Topico(
              id: current.id,
              name: current.name,
              mandatory: current.mandatory,
              subtopics: current.subtopics.where((item) => item.id != subtopicId).toList(),
            ),
          );
          return;
        }
      }
    }
  }

  void _mapTopico(String topicId, Topico Function(Topico) transform) {
    for (final disciplina in [..._disciplinas]) {
      if (disciplina.topics.any((item) => item.id == topicId)) {
        _replaceDisciplina(
          disciplina.id,
          (current) => current.topics.map((item) => item.id == topicId ? transform(item) : item).toList(),
        );
        return;
      }
    }
  }

  void _mapSubtopico(String subtopicId, Subtopico Function(Subtopico) transform) {
    for (final disciplina in [..._disciplinas]) {
      for (final topico in disciplina.topics) {
        if (topico.subtopics.any((item) => item.id == subtopicId)) {
          _mapTopico(
            topico.id,
            (current) => Topico(
              id: current.id,
              name: current.name,
              mandatory: current.mandatory,
              subtopics: current.subtopics.map((item) => item.id == subtopicId ? transform(item) : item).toList(),
            ),
          );
          return;
        }
      }
    }
  }

  void _replaceDisciplina(String id, List<Topico> Function(Disciplina) topics) {
    final index = _disciplinas.indexWhere((item) => item.id == id);
    final current = _disciplinas[index];
    _disciplinas[index] = Disciplina(
      id: current.id,
      name: current.name,
      difficulty: current.difficulty,
      color: current.color,
      topics: topics(current),
    );
  }

  void _throwIfMutationFails() {
    if (failSynchronization) {
      throw const DisciplinasSynchronizationException();
    }
    if (failMutation) throw const DisciplinasRepositoryException('Falha simulada.');
  }

  String _id(String prefix) => '$prefix-${_nextId++}';
}

List<Disciplina> disciplinasFixture() => [
  _disciplina(
    id: 'portugues',
    name: 'Língua Portuguesa',
    topics: [
      _topico(
        id: 'interpretacao',
        name: 'Compreensão e interpretação de textos',
        subtopics: const [
          Subtopico(id: 'tipologia', name: 'Tipologia e gêneros textuais'),
          Subtopico(id: 'inferencia', name: 'Inferência e pressupostos'),
          Subtopico(id: 'coesao', name: 'Coesão e coerência'),
        ],
      ),
      _topico(id: 'morfossintaxe', name: 'Domínio da estrutura morfossintática'),
    ],
  ),
  _disciplina(
    id: 'constitucional',
    name: 'Direito Constitucional',
    topics: [
      _topico(
        id: 'direitos',
        name: 'Direitos e garantias fundamentais',
        subtopics: const [
          Subtopico(id: 'individuais', name: 'Direitos individuais e coletivos'),
          Subtopico(id: 'remedios', name: 'Remédios constitucionais'),
        ],
      ),
      _topico(id: 'estado', name: 'Organização do Estado'),
    ],
  ),
  _disciplina(
    id: 'administrativo',
    name: 'Direito Administrativo',
    topics: [
      _topico(id: 'atos', name: 'Atos administrativos'),
      _topico(id: 'agentes', name: 'Agentes públicos'),
    ],
  ),
];

Disciplina _disciplina({required String id, required String name, required List<Topico> topics}) => Disciplina(
  id: id,
  name: name,
  difficulty: DificuldadeDisciplina.medium,
  color: '#E8742A',
  topics: [...topics, _mandatoryTopico('revisao-$id')],
);

Topico _topico({required String id, required String name, List<Subtopico> subtopics = const []}) =>
    Topico(id: id, name: name, mandatory: false, subtopics: subtopics);

Topico _mandatoryTopico(String id) =>
    Topico(id: id, name: nomeTopicoRevisaoVespera, mandatory: true, subtopics: const []);
