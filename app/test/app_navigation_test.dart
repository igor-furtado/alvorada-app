import 'package:estudos_app/app/app.dart';
import 'package:estudos_app/app/app_dependencies.dart';
import 'package:estudos_app/core/design_system/design_system.dart';
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
        locale: const Locale('pt'),
        dependencies: AppDependencies.fromRepositories(
          concursos: FakeConcursosRepository(),
          disciplinas: FakeDisciplinasRepository(),
        ),
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
    expect(find.byType(EditableText), findsNothing);
    expect(find.byKey(const ValueKey('theme-toggle')), findsOneWidget);
    expect(find.byType(AppBreadcrumbs), findsNothing);
    expect(find.text('Concursos'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('shell-destination-1')));
    await tester.pumpAndSettle();

    expect(find.text('Nova Disciplina'), findsOneWidget);
    expect(find.byType(EditableText), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('mantém o seletor de tema no shell compacto', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      EstudosApp(
        locale: const Locale('pt'),
        dependencies: AppDependencies.fromRepositories(
          concursos: FakeConcursosRepository(),
          disciplinas: FakeDisciplinasRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('theme-toggle')), findsOneWidget);
    expect(find.byType(AppBreadcrumbs), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('shell-destination-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('theme-toggle')), findsOneWidget);
    expect(find.byType(AppBreadcrumbs), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resolve a navegação no locale em inglês', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      EstudosApp(
        locale: const Locale('en'),
        dependencies: AppDependencies.fromRepositories(
          concursos: FakeConcursosRepository(),
          disciplinas: FakeDisciplinasRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exams'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('shell-destination-1')));
    await tester.pumpAndSettle();
    expect(find.text('Subjects'), findsWidgets);
  });
}
