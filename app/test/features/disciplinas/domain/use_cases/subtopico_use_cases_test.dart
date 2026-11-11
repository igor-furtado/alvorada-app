import 'package:estudos_app/src/core/domain/resultado.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_resultado_codes.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  test('cria um Subtópico com o nome normalizado', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );

    final createResult = await useCases.createSubtopico(
      topicId: 'interpretacao',
      name: '  Elementos da comunicação  ',
    );
    final catalogResult = await useCases.getDisciplinas();

    expect(createResult, isA<Sucesso<void>>());
    expect(
      _subtopicos(catalogResult, 'interpretacao'),
      contains('Elementos da comunicação'),
    );
  });

  test('rejeita a criação de Subtópico com nome vazio', () async {
    final useCases = DisciplinasUseCases(FakeDisciplinasRepository());

    final result = await useCases.createSubtopico(
      topicId: 'interpretacao',
      name: '   ',
    );

    expect(
      result,
      isA<ViolacaoRegra<void>>().having(
        (failure) => failure.codigo,
        'código',
        DisciplinasResultadoCodes.subtopicoNomeObrigatorio,
      ),
    );
  });

  test('atualiza o nome do Subtópico', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );

    final updateResult = await useCases.updateSubtopico(
      subtopicId: 'tipologia',
      name: 'Tipologia textual',
    );
    final catalogResult = await useCases.getDisciplinas();

    expect(updateResult, isA<Sucesso<void>>());
    expect(
      _subtopicos(catalogResult, 'interpretacao'),
      contains('Tipologia textual'),
    );
  });

  test('exclui somente o Subtópico solicitado', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );

    final deleteResult = await useCases.deleteSubtopico('tipologia');
    final catalogResult = await useCases.getDisciplinas();

    expect(deleteResult, isA<Sucesso<void>>());
    expect(
      _subtopicos(catalogResult, 'interpretacao'),
      isNot(contains('Tipologia e gêneros textuais')),
    );
    expect(
      _subtopicos(catalogResult, 'interpretacao'),
      contains('Inferência e pressupostos'),
    );
  });
}

List<String> _subtopicos(
  Resultado<List<Disciplina>> result,
  String topicId,
) => switch (result) {
  Sucesso(:final valor) =>
    valor
        .expand((disciplina) => disciplina.topics)
        .singleWhere((topico) => topico.id == topicId)
        .subtopics
        .map((subtopico) => subtopico.name)
        .toList(),
  _ => const [],
};
