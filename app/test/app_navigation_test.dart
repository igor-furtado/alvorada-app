import 'package:estudos_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/concursos/fakes/fake_concursos_repository.dart';
import 'features/disciplinas/fakes/fake_disciplinas_repository.dart';

void main() {
  testWidgets('mantém somente Concursos e Disciplinas na navegação principal', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      EstudosApp(
        concursosRepository: FakeConcursosRepository(),
        disciplinasRepository: FakeDisciplinasRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('shell-destination-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('shell-destination-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('shell-destination-2')), findsNothing);
    expect(find.bySemanticsLabel('Hoje'), findsNothing);
    expect(find.bySemanticsLabel('Semana'), findsNothing);
    expect(find.bySemanticsLabel('Revisões'), findsNothing);
    expect(find.bySemanticsLabel('Caderno'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('shell-destination-1')));
    await tester.pumpAndSettle();

    expect(find.text('Nova Disciplina'), findsOneWidget);
    semantics.dispose();
  });
}
