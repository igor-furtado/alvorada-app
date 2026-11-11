import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantém os tokens visuais do drawer alinhados à referência', () {
    final tokens = AppTheme.light.extension<AppTokens>()!;

    expect(tokens.borders.radius3xl, 24);
    expect(tokens.layout.drawerSideFraction, .75);
    expect(tokens.opacity.drawerBarrier, .30);
    expect(tokens.motion.drawer, const Duration(milliseconds: 450));
    expect(tokens.sizes.drawerHandleLength, 100);
  });

  testWidgets('abre por baixo no compacto com a anatomia da referência', (tester) async {
    await _pumpDrawerLauncher(tester, width: 390, height: 844);

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    final surface = find.byKey(const ValueKey('app-drawer-surface'));
    final surfaceRect = tester.getRect(surface);
    final tokens = AppTheme.light.extension<AppTokens>()!;
    final container = tester.widget<Container>(surface);
    final decoration = container.decoration! as BoxDecoration;

    expect(surfaceRect.left, tokens.spacing.sm);
    expect(surfaceRect.right, 390 - tokens.spacing.sm);
    expect(surfaceRect.bottom, 844 - tokens.spacing.sm);
    expect(surfaceRect.height, lessThanOrEqualTo(844 - (tokens.spacing.huge * 2)));
    expect(decoration.borderRadius, tokens.borders.xxxl);
    expect(find.byKey(const ValueKey('app-drawer-swipe-handle')), findsOneWidget);
    expect(find.byIcon(AppIcons.close), findsNothing);
    expect(find.text('Escolha um filtro'), findsOneWidget);
    expect(find.text('Refine os resultados exibidos.'), findsOneWidget);
    expect(find.text('Aplicar filtros'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('abre pela direita no desktop com largura e margens da referência', (tester) async {
    await _pumpDrawerLauncher(tester, width: 1440, height: 900);

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    final surfaceRect = tester.getRect(find.byKey(const ValueKey('app-drawer-surface')));
    final tokens = AppTheme.light.extension<AppTokens>()!;

    expect(surfaceRect.width, tokens.layout.dialogMaxWidth);
    expect(surfaceRect.top, tokens.spacing.sm);
    expect(surfaceRect.right, 1440 - tokens.spacing.sm);
    expect(surfaceRect.bottom, 900 - tokens.spacing.sm);
    expect(find.byKey(const ValueKey('app-drawer-swipe-handle')), findsNothing);
  });

  testWidgets('cobre a janela inteira quando aberto a partir de navegação aninhada', (tester) async {
    await _pumpNestedDrawerLauncher(tester, width: 390, height: 844);

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    final surfaceRect = tester.getRect(find.byKey(const ValueKey('app-drawer-surface')));
    final tokens = AppTheme.light.extension<AppTokens>()!;

    expect(surfaceRect.bottom, 844 - tokens.spacing.sm);
    expect(surfaceRect.bottom, greaterThan(tester.getTopLeft(find.byKey(const ValueKey('bottom-bar'))).dy));
  });

  testWidgets('empilha as ações e preserva o layout com texto a 200%', (tester) async {
    await _pumpDrawerLauncher(
      tester,
      width: 390,
      height: 844,
      textScaler: const TextScaler.linear(2),
    );

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    final primaryRect = tester.getRect(find.text('Aplicar filtros'));
    final secondaryRect = tester.getRect(find.text('Cancelar'));

    expect(primaryRect.top, lessThan(secondaryRect.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('fecha com gesto na direção de saída', (tester) async {
    await _pumpDrawerLauncher(tester, width: 390, height: 844);

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('app-drawer-surface')),
      const Offset(0, 500),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-drawer-surface')), findsNothing);
    expect(find.text('Abrir drawer'), findsOneWidget);
  });
}

Future<void> _pumpDrawerLauncher(
  WidgetTester tester, {
  required double width,
  required double height,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: AppButton(
              label: 'Abrir drawer',
              onPressed: () => showAppDrawer<void>(
                context,
                title: 'Escolha um filtro',
                description: 'Refine os resultados exibidos.',
                primaryLabel: 'Aplicar filtros',
                onPrimary: () {},
                secondaryLabel: 'Cancelar',
                onSecondary: () => Navigator.pop(context),
                child: const AppRadioGroup<String>(
                  value: 'todos',
                  options: [
                    AppRadioOption(value: 'todos', label: 'Todos'),
                    AppRadioOption(value: 'ativos', label: 'Ativos'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpNestedDrawerLauncher(
  WidgetTester tester, {
  required double width,
  required double height,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        bottomNavigationBar: const SizedBox(
          key: ValueKey('bottom-bar'),
          height: 80,
        ),
        body: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Center(
              child: AppButton(
                label: 'Abrir drawer',
                onPressed: () => showAppDrawer<void>(
                  context,
                  title: 'Escolha um filtro',
                  child: const Text('Conteúdo'),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
