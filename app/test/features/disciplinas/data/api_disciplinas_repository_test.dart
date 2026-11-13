import 'package:estudos_app/src/features/disciplinas/data/models/disciplina_api_model.dart';
import 'package:estudos_app/src/features/disciplinas/data/repositories/api_disciplinas_repository.dart';
import 'package:estudos_app/src/features/disciplinas/data/services/disciplinas_api_service.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina_input.dart';
import 'package:estudos_app/src/features/disciplinas/domain/repositories/disciplinas_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('usa cache até que uma atualização seja solicitada', () async {
    final api = _FakeApi();
    final repository = ApiDisciplinasRepository(api);

    final first = await repository.getDisciplinas();
    final cached = await repository.getDisciplinas();
    final refreshed = await repository.getDisciplinas(forceRefresh: true);

    expect(first.single.name, 'Português');
    expect(identical(first, cached), isTrue);
    expect(refreshed.single.topics.last.mandatory, isTrue);
    expect(api.getCalls, 2);
  });

  test('atualiza o catálogo depois de uma mutação', () async {
    final api = _FakeApi();
    final repository = ApiDisciplinasRepository(api);
    await repository.getDisciplinas();

    await repository.createTopicos(
      disciplineId: 'discipline-1',
      names: const ['Pontuação', 'Concordância'],
    );

    expect(api.createdTopicos, ['Pontuação', 'Concordância']);
    expect(api.getCalls, 2);
  });

  test('distingue mutação confirmada de falha ao sincronizar o catálogo', () async {
    final api = _FakeApi();
    final repository = ApiDisciplinasRepository(api);
    await repository.getDisciplinas();
    api.failGet = true;

    await expectLater(
      repository.createTopicos(
        disciplineId: 'discipline-1',
        names: const ['Pontuação'],
      ),
      throwsA(isA<DisciplinasSynchronizationException>()),
    );

    expect(api.createdTopicos, ['Pontuação']);
  });

  test('retorna a Disciplina criada depois de sincronizar com a API', () async {
    final api = _FakeApi();
    final repository = ApiDisciplinasRepository(api);

    final discipline = await repository.createDisciplina(const CreateDisciplinaInput(name: 'Português'));

    expect(discipline.id, 'discipline-1');
    expect(api.createdDisciplina?['dificuldade'], DificuldadeDisciplina.medium.apiValue);
  });

  test('traduz erro 4xx da API em violação de regra', () async {
    final api = _FakeApi()
      ..mutationError = const DisciplinasApiException(
        statusCode: 409,
        message: 'Já existe um Tópico com esse nome.',
      );
    final repository = ApiDisciplinasRepository(api);

    await expectLater(
      repository.createTopicos(
        disciplineId: 'discipline-1',
        names: const ['Pontuação'],
      ),
      throwsA(
        isA<DisciplinasRuleViolationException>()
            .having(
              (failure) => failure.code,
              'código',
              'disciplinas.api.409',
            )
            .having(
              (failure) => failure.message,
              'mensagem',
              'Já existe um Tópico com esse nome.',
            ),
      ),
    );
  });
}

class _FakeApi implements DisciplinasApi {
  int getCalls = 0;
  List<String>? createdTopicos;
  Map<String, Object?>? createdDisciplina;
  bool failGet = false;
  Exception? mutationError;

  @override
  Future<List<DisciplinaApiModel>> getDisciplinas() async {
    getCalls++;
    if (failGet) throw StateError('Falha simulada ao atualizar catálogo.');
    return [_discipline];
  }

  @override
  Future<String> createDisciplina(Map<String, Object?> body) async {
    createdDisciplina = body;
    return 'discipline-1';
  }

  @override
  Future<void> createTopicos(String disciplineId, List<String> names) async {
    final error = mutationError;
    if (error != null) throw error;
    createdTopicos = names;
  }

  @override
  Future<void> deleteDisciplina(String id) async {}

  @override
  Future<void> deleteTopico(String topicId) async {}

  @override
  Future<void> updateDisciplina(String id, Map<String, Object?> body) async {}

  @override
  Future<void> updateTopico(String topicId, String name) async {}
}

const _discipline = DisciplinaApiModel(
  id: 'discipline-1',
  name: 'Português',
  difficulty: 3,
  color: '#E8742A',
  topics: [
    TopicoApiModel(id: 'topic-1', name: nomeTopicoRevisaoVespera, mandatory: true),
  ],
);
