import 'package:estudos_app/src/core/content/app_messages.dart';
import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/features/concursos/domain/models/concurso.dart';
import 'package:estudos_app/src/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/src/features/concursos/presentation/concurso_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_concursos_repository.dart';

void main() {
  testWidgets('carrega um Concurso real ao abrir a rota diretamente', (
    tester,
  ) async {
    final concurso = _concurso();

    await _pump(
      tester,
      repository: FakeConcursosRepository(concursos: [concurso]),
      child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
    );

    expect(find.text(concurso.instituicao), findsWidgets);
    expect(find.text(AppMessages.concursoNaoEncontrado), findsNothing);
  });

  testWidgets('não oferece edição local sem persistência do Edital', (
    tester,
  ) async {
    await _pump(
      tester,
      repository: FakeConcursosRepository(concursos: [_concurso()]),
      child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
    );

    expect(find.text(AppMessages.newDiscipline), findsNothing);
    expect(find.text(AppMessages.seeDetails), findsNothing);
    expect(find.text(AppMessages.noDiscipline), findsOneWidget);
  });

  testWidgets('abre a edição com os dados atuais do Concurso', (
    tester,
  ) async {
    final concurso = _concurso();
    await _pump(
      tester,
      repository: FakeConcursosRepository(concursos: [concurso]),
      child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
    );

    await tester.tap(find.text(AppMessages.editarConcurso));
    await tester.pumpAndSettle();

    final inputs = tester.widgetList<EditableText>(find.byType(EditableText)).toList();
    expect(inputs.map((input) => input.controller.text), [
      concurso.instituicao,
      concurso.sigla,
      concurso.cargo,
      concurso.banca,
      '12',
      '12.345,67',
      '40',
      '21/02/2027',
      '13:00',
      '18:00',
      concurso.localProva,
      concurso.requisitos,
      concurso.criteriosPontuacao,
    ]);
    expect(find.text(AppMessages.saveChanges), findsOneWidget);
  });
}

Concurso _concurso() => Concurso(
  id: 'concurso-real',
  instituicao: 'Tribunal Regional Federal da 5ª Região',
  cargo: 'Técnico Judiciário',
  banca: 'FCC',
  dataProva: DateTime(2027, 2, 21),
  prioritario: false,
  progressoEdital: 0,
  sigla: 'TRF5',
  quantidadeVagas: 12,
  vencimentoCentavos: 1234567,
  cargaHorariaSemanal: 40,
  localProva: 'Recife/PE',
  horarioInicioProva: '13:00',
  horarioFimProva: '18:00',
  requisitos: 'Nível superior completo.',
  criteriosPontuacao: 'Provas com pesos por bloco.',
);

Future<void> _pump(
  WidgetTester tester, {
  required FakeConcursosRepository repository,
  required Widget child,
}) async {
  await tester.binding.setSurfaceSize(const Size(1440, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    RepositoryProvider<ConcursosUseCases>.value(
      value: ConcursosUseCases(repository),
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
