import 'package:estudos_app/src/core/content/app_messages.dart';
import 'package:estudos_app/src/core/presentation/app_shell_controller.dart';
import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/bloc/disciplinas_bloc.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/bloc/disciplinas_event.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/pages/disciplinas_page.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/widgets/disciplinas_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_disciplinas_repository.dart';

void main() {
  testWidgets('posiciona a ação no cabeçalho e redimensiona o painel de Disciplinas', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    final bloc = DisciplinasBloc(
      repository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    )..add(const LoadDisciplinasRequested());
    final shellController = AppShellController();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      shellController.dispose();
      await bloc.close();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppShellScope(
          controller: shellController,
          child: BlocProvider.value(
            value: bloc,
            child: const Scaffold(body: DisciplinasPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text(AppMessages.contentCatalog);
    final addButton = find.byKey(const ValueKey('add-discipline'));
    expect(title, findsOneWidget);
    expect(addButton, findsOneWidget);
    expect(tester.getTopLeft(addButton).dx, greaterThan(tester.getTopRight(title).dx));
    expect(find.byType(AppResizable), findsOneWidget);

    final tokens = AppTheme.light.extension<AppTokens>()!;
    final catalog = find.byType(DisciplinasCatalog);
    final masterPanel = find.byKey(const ValueKey('disciplines-master-panel'));
    final handle = find.bySemanticsLabel('Redimensionar painéis');
    final catalogSize = tester.getSize(catalog);
    final catalogTopLeft = tester.getTopLeft(catalog);
    final catalogBottomRight = tester.getBottomRight(catalog);
    final initialWidth = tester.getSize(masterPanel).width;
    expect(catalogTopLeft.dx, anyOf(tokens.spacing.xl, tokens.spacing.page));
    expect(catalogSize.width, 1440 - (catalogTopLeft.dx * 2));
    expect(catalogBottomRight.dy, 900 - catalogTopLeft.dx);
    expect(tester.getSize(masterPanel).height, catalogSize.height);
    expect(catalogSize.height, greaterThan(tokens.layout.catalogWorkspaceHeight));

    await tester.drag(handle, const Offset(120, 0));
    await tester.pumpAndSettle();

    expect(tester.getSize(masterPanel).width, greaterThan(initialWidth));
  });

  testWidgets('mantém cabeçalho e catálogo empilhados no layout compacto', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    final bloc = DisciplinasBloc(
      repository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    )..add(const LoadDisciplinasRequested());
    final shellController = AppShellController();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      shellController.dispose();
      await bloc.close();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppShellScope(
          controller: shellController,
          child: BlocProvider.value(
            value: bloc,
            child: const Scaffold(body: DisciplinasPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('add-discipline')), findsOneWidget);
    expect(find.byType(AppResizable), findsNothing);
    final tokens = AppTheme.light.extension<AppTokens>()!;
    final catalog = find.byType(DisciplinasCatalog);
    expect(tester.getSize(catalog).width, 390 - (tokens.spacing.xl * 2));
    expect(tester.getBottomRight(catalog).dy, 800 - tokens.spacing.xl);
    expect(tester.takeException(), isNull);
  });

  for (final width in [720.0, 1024.0]) {
    testWidgets('ocupa todo o espaço disponível na largura de ${width.round()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      final bloc = DisciplinasBloc(
        repository: FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
      )..add(const LoadDisciplinasRequested());
      final shellController = AppShellController();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        shellController.dispose();
        await bloc.close();
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AppShellScope(
            controller: shellController,
            child: BlocProvider.value(
              value: bloc,
              child: const Scaffold(body: DisciplinasPage()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tokens = AppTheme.light.extension<AppTokens>()!;
      final catalog = find.byType(DisciplinasCatalog);
      final topLeft = tester.getTopLeft(catalog);
      final bottomRight = tester.getBottomRight(catalog);
      expect(topLeft.dx, anyOf(tokens.spacing.xl, tokens.spacing.page));
      expect(bottomRight.dx, width - topLeft.dx);
      expect(bottomRight.dy, 900 - topLeft.dx);
      expect(tester.takeException(), isNull);
    });
  }
}
