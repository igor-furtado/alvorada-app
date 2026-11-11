import 'package:estudos_app/src/core/domain/resultado.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina_input.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_resultado_codes.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  test('cria a Disciplina com o nome normalizado', () async {
    final useCases = DisciplinasUseCases(FakeDisciplinasRepository());

    final createResult = await useCases.createDisciplina(
      const CreateDisciplinaInput(name: '  Direito Constitucional  '),
    );
    final catalogResult = await useCases.getDisciplinas();

    expect(createResult, isA<Sucesso<Disciplina>>());
    expect(
      catalogResult,
      isA<Sucesso<List<Disciplina>>>().having(
        (success) => success.valor.single.name,
        'nome',
        'Direito Constitucional',
      ),
    );
  });

  test('rejeita a criação de Disciplina com cor inválida', () async {
    final useCases = DisciplinasUseCases(FakeDisciplinasRepository());

    final result = await useCases.createDisciplina(
      const CreateDisciplinaInput(name: 'Português', color: 'laranja'),
    );

    expect(
      result,
      isA<ViolacaoRegra<Disciplina>>().having(
        (failure) => failure.codigo,
        'código',
        DisciplinasResultadoCodes.disciplinaCorInvalida,
      ),
    );
  });

  test('converte falha de criação em FalhaTecnica', () async {
    final repository = FakeDisciplinasRepository()..failMutation = true;
    final useCases = DisciplinasUseCases(repository);

    final result = await useCases.createDisciplina(
      const CreateDisciplinaInput(name: 'Português'),
    );

    expect(
      result,
      isA<FalhaTecnica<Disciplina>>().having(
        (failure) => failure.codigo,
        'código',
        DisciplinasResultadoCodes.criacaoFalhou,
      ),
    );
  });

  test('atualiza a Disciplina com o nome normalizado', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );

    final updateResult = await useCases.updateDisciplina(
      'portugues',
      const UpdateDisciplinaInput(name: '  Português  '),
    );
    final catalogResult = await useCases.getDisciplinas();

    expect(updateResult, isA<Sucesso<void>>());
    expect(
      catalogResult,
      isA<Sucesso<List<Disciplina>>>().having(
        (success) => success.valor.first.name,
        'nome',
        'Português',
      ),
    );
  });

  test('rejeita a atualização de Disciplina com nome vazio', () async {
    final useCases = DisciplinasUseCases(FakeDisciplinasRepository());

    final result = await useCases.updateDisciplina(
      'portugues',
      const UpdateDisciplinaInput(name: '   '),
    );

    expect(
      result,
      isA<ViolacaoRegra<void>>().having(
        (failure) => failure.codigo,
        'código',
        DisciplinasResultadoCodes.disciplinaNomeObrigatorio,
      ),
    );
  });

  test('exclui a Disciplina e disponibiliza o catálogo atualizado', () async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );

    final deleteResult = await useCases.deleteDisciplina('constitucional');
    final catalogResult = await useCases.getDisciplinas();

    expect(deleteResult, isA<Sucesso<void>>());
    expect(
      catalogResult,
      isA<Sucesso<List<Disciplina>>>().having(
        (success) => success.valor.map((disciplina) => disciplina.id),
        'identificadores',
        isNot(contains('constitucional')),
      ),
    );
  });

  test('informa falha técnica quando a exclusão não sincroniza o catálogo', () async {
    final repository = FakeDisciplinasRepository()..failSynchronization = true;
    final useCases = DisciplinasUseCases(repository);

    final result = await useCases.deleteDisciplina('constitucional');

    expect(
      result,
      isA<FalhaTecnica<void>>().having(
        (failure) => failure.codigo,
        'código',
        DisciplinasResultadoCodes.sincronizacaoPendente,
      ),
    );
  });
}
