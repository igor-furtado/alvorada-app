import 'dart:async';

import 'package:estudos_app/src/app.dart';
import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/src/features/disciplinas/domain/models/disciplina_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/disciplinas/fakes/fake_disciplinas_repository.dart';

void main() {
  Future<void> openCatalog(
    WidgetTester tester, {
    Size size = const Size(1440, 1000),
    FakeDisciplinasRepository? repository,
  }) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
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
    final navigationBar = find.byType(NavigationBar);
    final disciplineDestination = navigationBar.evaluate().isNotEmpty
        ? find.descendant(
            of: navigationBar,
            matching: find.byIcon(AppIcons.bookText),
          )
        : find.byKey(const ValueKey('shell-destination-3'));
    await tester.tap(disciplineDestination);
    await tester.pumpAndSettle();
  }

  testWidgets('abre o catálogo compartilhado pela navegação principal', (tester) async {
    await openCatalog(tester);

    expect(find.text('Disciplinas'), findsWidgets);
    expect(find.text('Língua Portuguesa'), findsOneWidget);
    expect(find.text('Compreensão e interpretação de textos'), findsOneWidget);
    expect(find.text('Revisão de Véspera'), findsOneWidget);
    expect(find.text('Tópico obrigatório'), findsOneWidget);
    expect(find.text('Tópicos'), findsOneWidget);
    expect(find.text('Conteúdo compartilhado'), findsNothing);
    expect(find.text('01 DISCIPLINA'), findsNothing);
    expect(find.byKey(const ValueKey('shell-search-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('add-discipline')), findsOneWidget);
    expect(find.text('Estrutura'), findsNothing);
    expect(find.text('Editais relacionados'), findsNothing);
    expect(find.text('Histórico'), findsNothing);
    final disciplineItem = tester.widget<AppListItem>(
      find.byKey(const ValueKey('discipline-selector-portugues')),
    );
    expect(disciplineItem.selected, isTrue);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('discipline-selector-portugues')),
        matching: find.byWidgetPredicate((widget) => widget is AppMenuButton),
      ),
      findsOneWidget,
    );
    final refreshCenter = tester.getCenter(find.byKey(const ValueKey('shell-search-action')));
    final themeCenter = tester.getCenter(find.byKey(const ValueKey('theme-toggle')));
    expect(refreshCenter.dx, lessThan(themeCenter.dx));
    expect(themeCenter.dx - refreshCenter.dx, lessThan(60));
  });

  testWidgets('troca o painel de detalhe pela disciplina selecionada', (tester) async {
    await openCatalog(tester);

    await tester.tap(find.byKey(const ValueKey('discipline-selector-constitucional')));
    await tester.pumpAndSettle();

    final selected = tester.widget<AppListItem>(
      find.byKey(const ValueKey('discipline-selector-constitucional')),
    );
    expect(selected.selected, isTrue);
    expect(find.text('Direitos e garantias fundamentais'), findsOneWidget);
    expect(find.text('Compreensão e interpretação de textos'), findsNothing);
  });

  testWidgets('usa o Alert Dialog da biblioteca para confirmar exclusão', (tester) async {
    await openCatalog(tester);

    final disciplineMenu = find.descendant(
      of: find.byKey(const ValueKey('discipline-selector-portugues')),
      matching: find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.tap(disciplineMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();

    expect(find.byType(AppAlertDialog), findsOneWidget);
    expect(find.text('Excluir Disciplina?'), findsOneWidget);
  });

  testWidgets('adiciona Disciplina com Revisão de Véspera obrigatória', (tester) async {
    await openCatalog(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Nova Disciplina').first);
    await tester.pumpAndSettle();
    expect(find.text('Adicione uma Disciplina para organizar seus Tópicos.'), findsOneWidget);
    expect(find.text('Nome da Disciplina *'), findsOneWidget);
    expect(find.text('Ex.: Língua Portuguesa'), findsOneWidget);
    expect(find.text('Use o nome adotado no Edital.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, 'Raciocínio Lógico');
    await tester.tap(find.widgetWithText(AppButton, 'Adicionar Disciplina').last);
    await tester.pumpAndSettle();

    expect(find.text('Raciocínio Lógico'), findsOneWidget);
    expect(find.text('1 Tópico'), findsOneWidget);
    await tester.tap(find.text('Raciocínio Lógico'));
    await tester.pumpAndSettle();
    expect(find.text('Revisão de Véspera'), findsOneWidget);
  });

  testWidgets('adiciona Tópico e Subtópico pela hierarquia', (tester) async {
    await openCatalog(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Adicionar Tópico').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Pontuação');
    await tester.tap(find.widgetWithText(AppButton, 'Adicionar').last);
    await tester.pumpAndSettle();

    expect(find.text('Pontuação'), findsOneWidget);
    final topic = find.text('Pontuação');
    await tester.ensureVisible(topic);
    await tester.pumpAndSettle();
    await tester.tap(topic);
    await tester.pumpAndSettle();
    final addSubtopic = find.byKey(const ValueKey('add-subtopic-topico-100'));
    await tester.ensureVisible(addSubtopic);
    await tester.pumpAndSettle();
    await tester.tap(addSubtopic);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Uso da vírgula');
    await tester.tap(find.widgetWithText(AppButton, 'Adicionar').last);
    await tester.pumpAndSettle();

    expect(find.text('Uso da vírgula'), findsOneWidget);
  });

  testWidgets('filtra por Subtópico e permanece legível em viewport estreito', (tester) async {
    await openCatalog(tester, size: const Size(390, 844));

    await tester.enterText(find.byType(TextFormField).first, 'Remédios constitucionais');
    await tester.pumpAndSettle();

    expect(find.text('Direito Constitucional'), findsOneWidget);
    expect(find.text('Língua Portuguesa'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adapta o catálogo às larguras suportadas', (tester) async {
    for (final size in const [
      Size(390, 844),
      Size(720, 900),
      Size(1024, 900),
      Size(1440, 1000),
    ]) {
      await openCatalog(tester, size: size);

      expect(
        tester.takeException(),
        isNull,
        reason: 'A tela não deve produzir overflow em ${size.width}px.',
      );
    }
  });

  testWidgets('permanece legível em viewport estreito com texto a 200%', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await openCatalog(tester, size: const Size(390, 844));

    expect(tester.takeException(), isNull);
    expect(find.text('Disciplinas'), findsWidgets);
  });

  testWidgets('mantém rótulos acessíveis em viewport estreito', (tester) async {
    final handle = tester.ensureSemantics();
    await openCatalog(tester, size: const Size(390, 844));

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('informa falha de carregamento e permite tentar novamente', (tester) async {
    final repository = FakeDisciplinasRepository(disciplinas: disciplinasFixture())..failLoad = true;
    await openCatalog(tester, repository: repository);

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    repository.failLoad = false;
    await tester.tap(find.widgetWithText(AppButton, 'Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Língua Portuguesa'), findsWidgets);
  });

  testWidgets('desabilita todas as mutações enquanto uma operação está em andamento', (tester) async {
    final repository = _BlockingDisciplinasRepository(
      disciplinas: disciplinasFixture(),
    );
    await openCatalog(tester, repository: repository);

    await tester.tap(find.widgetWithText(AppButton, 'Nova Disciplina').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Raciocínio Lógico');
    await tester.tap(
      find.widgetWithText(AppButton, 'Adicionar Disciplina').last,
    );
    await tester.pump();

    expect(
      tester.widget<AppButton>(find.byKey(const ValueKey('add-discipline'))).onPressed,
      isNull,
    );
    expect(
      tester.widget<AppButton>(find.widgetWithText(AppButton, 'Adicionar Tópico')).onPressed,
      isNull,
    );
    final disciplineMenu = find.descendant(
      of: find.byKey(const ValueKey('discipline-selector-portugues')),
      matching: find.byType(AppAccessibleIconButton),
    );
    expect(
      tester.widget<AppAccessibleIconButton>(disciplineMenu).onPressed,
      isNull,
    );

    repository.completeMutation();
    await tester.pumpAndSettle();
  });
}

class _BlockingDisciplinasRepository extends FakeDisciplinasRepository {
  _BlockingDisciplinasRepository({required super.disciplinas});

  final _mutation = Completer<void>();

  @override
  Future<Disciplina> createDisciplina(CreateDisciplinaInput input) async {
    await _mutation.future;
    return super.createDisciplina(input);
  }

  void completeMutation() => _mutation.complete();
}
