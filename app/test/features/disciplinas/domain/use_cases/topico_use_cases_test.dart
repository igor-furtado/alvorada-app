import 'package:estudos_app/src/core/domain/resultado.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_resultado_codes.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  test('cria um Tópico com o nome normalizado', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );

    final createResult = await useCases.createTopico(
      disciplineId: 'portugues',
      name: '  Pontuação  ',
    );
    final catalogResult = await useCases.getDisciplinas();

    expect(createResult, isA<Sucesso<void>>());
    expect(_topicos(catalogResult, 'portugues'), contains('Pontuação'));
  });

  test('rejeita a criação de Tópico com nome vazio', () async {
    final useCases = DisciplinasUseCases(FakeDisciplinasRepository());

    final result = await useCases.createTopico(
      disciplineId: 'portugues',
      name: '   ',
    );

    expect(
      result,
      isA<ViolacaoRegra<void>>().having(
        (failure) => failure.codigo,
        'código',
        DisciplinasResultadoCodes.topicoNomeObrigatorio,
      ),
    );
  });

  test('atualiza o nome do Tópico', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );

    final updateResult = await useCases.updateTopico(
      topicId: 'interpretacao',
      name: 'Interpretação textual',
    );
    final catalogResult = await useCases.getDisciplinas();

    expect(updateResult, isA<Sucesso<void>>());
    expect(
      _topicos(catalogResult, 'portugues'),
      contains('Interpretação textual'),
    );
  });

  test('exclui o Tópico e mantém os demais no catálogo', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );

    final deleteResult = await useCases.deleteTopico('interpretacao');
    final catalogResult = await useCases.getDisciplinas();

    expect(deleteResult, isA<Sucesso<void>>());
    expect(
      _topicos(catalogResult, 'portugues'),
      isNot(contains('Compreensão e interpretação de textos')),
    );
    expect(
      _topicos(catalogResult, 'portugues'),
      contains('Domínio da estrutura morfossintática'),
    );
  });
}

List<String> _topicos(
  Resultado<List<Disciplina>> result,
  String disciplineId,
) => switch (result) {
  Sucesso(:final valor) =>
    valor.singleWhere((disciplina) => disciplina.id == disciplineId).topics.map((topico) => topico.name).toList(),
  _ => const [],
};
