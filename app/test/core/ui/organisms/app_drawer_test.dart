import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantém os tokens visuais do drawer alinhados à referência', () {
    final tokens = AppTheme.light.extension<AppTokens>()!;

    expect(tokens.layout.drawerWidth, 460);
    expect(tokens.opacity.drawerBarrier, .30);
    expect(tokens.motion.drawer, const Duration(milliseconds: 450));
    expect(tokens.sizes.drawerHandleLength, 100);
  });

  testWidgets('ocupa a lateral inteira no compacto com a anatomia da referência', (tester) async {
    await _pumpDrawerLauncher(tester, width: 390, height: 844);

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    final surface = find.byKey(const ValueKey('app-drawer-surface'));
    final surfaceRect = tester.getRect(surface);
    final container = tester.widget<Container>(surface);
    final decoration = container.decoration! as BoxDecoration;

    expect(surfaceRect.left, 0);
    expect(surfaceRect.right, 390);
    expect(surfaceRect.top, 0);
    expect(surfaceRect.bottom, 844);
    expect(decoration.borderRadius, isNull);
    expect(find.byKey(const ValueKey('app-drawer-swipe-handle')), findsNothing);
    expect(find.byIcon(AppIcons.close), findsOneWidget);
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

    expect(surfaceRect.width, tokens.layout.drawerWidth);
    expect(surfaceRect.top, 0);
    expect(surfaceRect.right, 1440);
    expect(surfaceRect.bottom, 900);
    expect(find.byKey(const ValueKey('app-drawer-swipe-handle')), findsNothing);
  });

  testWidgets('cobre a janela inteira quando aberto a partir de navegação aninhada', (tester) async {
    await _pumpNestedDrawerLauncher(tester, width: 390, height: 844);

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    final surfaceRect = tester.getRect(find.byKey(const ValueKey('app-drawer-surface')));
    expect(surfaceRect.bottom, 844);
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
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-drawer-surface')), findsNothing);
    expect(find.text('Abrir drawer'), findsOneWidget);
  });

  testWidgets('bloqueia clique externo e Esc durante loading sem impedir conclusão programática', (tester) async {
    await _pumpDismissibilityLauncher(tester, width: 1440, height: 900);

    await tester.tap(find.text('Abrir formulário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    await tester.tapAt(const Offset(100, 450));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('app-drawer-surface')), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('app-drawer-surface')), findsOneWidget);

    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-drawer-surface')), findsNothing);
  });

  testWidgets('clique no fundo interno remove o foco sem fechar o formulário', (tester) async {
    await _pumpDismissibilityLauncher(tester, width: 390, height: 844);

    await tester.tap(find.text('Abrir formulário'));
    await tester.pumpAndSettle();
    final input = tester.widget<EditableText>(find.byType(EditableText));
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    expect(input.focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(200, 400));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('app-drawer-surface')), findsOneWidget);
    expect(input.focusNode.hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-drawer-surface')), findsNothing);
  });

  testWidgets('clique fora fecha o formulário quando está ocioso', (tester) async {
    await _pumpDismissibilityLauncher(tester, width: 1440, height: 900);

    await tester.tap(find.text('Abrir formulário'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(100, 450));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-drawer-surface')), findsNothing);
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
                  description: 'Refine os resultados exibidos.',
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

Future<void> _pumpDismissibilityLauncher(
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
        body: Builder(
          builder: (context) => Center(
            child: AppButton(
              label: 'Abrir formulário',
              onPressed: () => showAppDrawerBuilder<void>(
                context,
                builder: (_) => const _DismissibilityDrawer(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DismissibilityDrawer extends StatefulWidget {
  const _DismissibilityDrawer();

  @override
  State<_DismissibilityDrawer> createState() => _DismissibilityDrawerState();
}

class _DismissibilityDrawerState extends State<_DismissibilityDrawer> {
  var _loading = false;

  @override
  Widget build(BuildContext context) => AppDrawer(
    title: 'Formulário',
    description: 'Preencha os dados solicitados.',
    dismissible: !_loading,
    primaryLabel: 'Salvar',
    onPrimary: () => setState(() => _loading = true),
    loading: _loading,
    child: Column(
      children: [
        const AppTextInput(autofocus: true),
        AppButton(
          label: 'Concluir',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
