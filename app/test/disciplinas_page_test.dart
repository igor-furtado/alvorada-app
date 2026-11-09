import 'package:estudos_app/src/app.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'features/disciplinas/fakes/fake_disciplinas_repository.dart';

void main() {
  Future<void> openCatalog(
    WidgetTester tester, {
    Size size = const Size(1440, 1000),
    FakeDisciplinasRepository? repository,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EstudosApp(
        disciplinasRepository: repository ?? FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disciplinas').first);
    await tester.pumpAndSettle();
  }

  testWidgets('abre o catálogo compartilhado pela navegação principal', (tester) async {
    await openCatalog(tester);

    expect(find.text('Disciplinas e Tópicos'), findsWidgets);
    expect(find.text('Língua Portuguesa'), findsOneWidget);
    expect(find.text('Compreensão e interpretação de textos'), findsOneWidget);
    expect(find.text('Revisão de Véspera'), findsNWidgets(3));
    expect(find.text('Tópico obrigatório'), findsNWidgets(3));
    final disciplineItem = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Disciplinas'),
    );
    expect(disciplineItem.selected, isTrue);
  });

  testWidgets('adiciona Disciplina com Revisão de Véspera obrigatória', (tester) async {
    await openCatalog(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Adicionar Disciplina').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(ShadInput).last, 'Raciocínio Lógico');
    await tester.tap(find.widgetWithText(AppButton, 'Adicionar').last);
    await tester.pumpAndSettle();

    expect(find.text('Raciocínio Lógico'), findsOneWidget);
    expect(find.text('1 Tópicos · 0 Subtópicos'), findsOneWidget);
    expect(find.text('Revisão de Véspera'), findsNWidgets(4));
  });

  testWidgets('adiciona Tópico e Subtópico pela hierarquia', (tester) async {
    await openCatalog(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Adicionar Tópico').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(ShadInput).last, 'Pontuação');
    await tester.tap(find.widgetWithText(AppButton, 'Adicionar').last);
    await tester.pumpAndSettle();

    expect(find.text('Pontuação'), findsOneWidget);
    final topicMenu = find.ancestor(
      of: find.byTooltip('Mais ações: Pontuação'),
      matching: find.byType(ShadContextMenuRegion),
    );
    await tester.tap(topicMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar Subtópico').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(ShadInput).last, 'Uso da vírgula');
    await tester.tap(find.widgetWithText(AppButton, 'Adicionar').last);
    await tester.pumpAndSettle();

    expect(find.text('Uso da vírgula'), findsOneWidget);
  });

  testWidgets('filtra por Subtópico e permanece legível no celular', (tester) async {
    await openCatalog(tester, size: const Size(390, 844));

    await tester.enterText(find.byType(ShadInput).first, 'Remédios constitucionais');
    await tester.pumpAndSettle();

    expect(find.text('Direito Constitucional'), findsOneWidget);
    expect(find.text('Língua Portuguesa'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('informa falha de carregamento e permite tentar novamente', (tester) async {
    final repository = FakeDisciplinasRepository(disciplinas: disciplinasFixture())..failLoad = true;
    await openCatalog(tester, repository: repository);

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    repository.failLoad = false;
    await tester.tap(find.widgetWithText(AppButton, 'Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Língua Portuguesa'), findsOneWidget);
  });
}
