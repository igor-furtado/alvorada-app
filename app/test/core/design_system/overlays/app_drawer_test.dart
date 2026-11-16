import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('mantém os tokens visuais do drawer alinhados à referência', () {
    final tokens = AppTheme.light.extension<AppTokens>()!;

    expect(tokens.layout.drawerWidth, 460);
    expect(tokens.opacity.drawerBarrier, .30);
    expect(tokens.motion.drawer, const Duration(milliseconds: 450));
  });

  testWidgets('ocupa a lateral inteira no compacto com a anatomia da referência', (tester) async {
    await _pumpDrawerLauncher(tester, width: 390, height: 844);

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    final surface = find.byKey(const ValueKey('app-drawer-surface'));
    final surfaceRect = tester.getRect(surface);
    final container = tester.widget<Container>(surface);
    final decoration = container.decoration! as BoxDecoration;
    final header = tester.widget<Container>(find.byKey(const ValueKey('app-drawer-header')));
    final headerDecoration = header.decoration! as BoxDecoration;

    expect(surfaceRect.left, 0);
    expect(surfaceRect.right, 390);
    expect(surfaceRect.top, 0);
    expect(surfaceRect.bottom, 844);
    expect(decoration.borderRadius, isNull);
    expect((headerDecoration.border! as Border).bottom.color, AppTheme.light.extension<AppTokens>()!.colors.border);
    expect(find.byKey(const ValueKey('app-drawer-swipe-handle')), findsNothing);
    expect(find.byIcon(AppIcons.close), findsOneWidget);
    expect(find.text('Escolha um filtro'), findsOneWidget);
    expect(find.text('Refine os resultados exibidos.'), findsOneWidget);
    expect(find.text('Aplicar filtros'), findsOneWidget);
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

  testWidgets('aceita largura, corpo fixo e rodapé próprios para fluxos mestres-detalhe', (tester) async {
    await _pumpWideDrawerLauncher(tester, width: 1440, height: 900);

    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();

    final surfaceRect = tester.getRect(find.byKey(const ValueKey('app-drawer-surface')));
    final bodyRect = tester.getRect(find.byKey(const ValueKey('wide-drawer-body')));
    expect(surfaceRect.width, 980);
    expect(bodyRect.left, surfaceRect.left + 1);
    expect(bodyRect.right, surfaceRect.right);
    expect(find.byKey(const ValueKey('wide-drawer-footer')), findsOneWidget);
  });

  testWidgets('cobre a janela inteira quando aberto a partir de navegação aninhada', (tester) async {
    await _pumpNestedDrawerLauncher(tester, width: 390, height: 844);

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    final surfaceRect = tester.getRect(find.byKey(const ValueKey('app-drawer-surface')));
    expect(surfaceRect.bottom, 844);
    expect(surfaceRect.bottom, greaterThan(tester.getTopLeft(find.byKey(const ValueKey('bottom-bar'))).dy));
  });

  testWidgets('preserva a ação com texto a 200%', (tester) async {
    await _pumpDrawerLauncher(
      tester,
      width: 390,
      height: 844,
      textScaler: const TextScaler.linear(2),
    );

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    expect(find.text('Aplicar filtros'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remove transparência e blur em alto contraste', (tester) async {
    await _pumpDrawerLauncher(
      tester,
      width: 390,
      height: 844,
      highContrast: true,
    );

    await tester.tap(find.text('Abrir drawer'));
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsNothing);
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
  bool highContrast = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: textScaler,
          highContrast: highContrast,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: AppButton(
              label: 'Abrir drawer',
              onPressed: () => showAppDrawerBuilder<void>(
                context,
                builder: (_) => AppDrawer(
                  title: 'Escolha um filtro',
                  description: 'Refine os resultados exibidos.',
                  primaryLabel: 'Aplicar filtros',
                  onPrimary: () {},
                  child: const Text('Todos os resultados'),
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
                onPressed: () => showAppDrawerBuilder<void>(
                  context,
                  builder: (_) => const AppDrawer(
                    title: 'Escolha um filtro',
                    description: 'Refine os resultados exibidos.',
                    child: Text('Conteúdo'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpWideDrawerLauncher(
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
              label: 'Abrir editor',
              onPressed: () => showAppDrawerBuilder<void>(
                context,
                builder: (_) => const AppDrawer(
                  title: 'Editor amplo',
                  description: 'Conteúdo mestre-detalhe.',
                  width: 980,
                  scrollable: false,
                  bodyPadding: EdgeInsets.zero,
                  footer: SizedBox(key: ValueKey('wide-drawer-footer'), height: 72),
                  child: SizedBox.expand(key: ValueKey('wide-drawer-body')),
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
