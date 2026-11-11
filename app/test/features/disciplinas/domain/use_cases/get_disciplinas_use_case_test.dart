import 'package:estudos_app/src/core/domain/resultado.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_resultado_codes.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/get_disciplinas_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  test('retorna as Disciplinas disponíveis com sucesso', () async {
    final useCase = GetDisciplinasUseCase(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );

    final result = await useCase();

    expect(
      result,
      isA<Sucesso<List<Disciplina>>>().having(
        (success) => success.valor.map((disciplina) => disciplina.name),
        'Disciplinas',
        [
          'Língua Portuguesa',
          'Direito Constitucional',
          'Direito Administrativo',
        ],
      ),
    );
  });

  test('retorna FalhaTecnica quando não consegue carregar as Disciplinas', () async {
    final repository = FakeDisciplinasRepository()..failLoad = true;
    final useCase = GetDisciplinasUseCase(repository);

    final result = await useCase();

    expect(
      result,
      isA<FalhaTecnica<List<Disciplina>>>().having(
        (failure) => failure.codigo,
        'código',
        DisciplinasResultadoCodes.carregamentoFalhou,
      ),
    );
  });
}
