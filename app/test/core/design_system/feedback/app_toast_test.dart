import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe título, descrição e ações no canto inferior direito', (tester) async {
    var actionCount = 0;

    await _pumpToastTrigger(
      tester,
      onPressed: (context) => AppToast.show(
        context,
        title: 'Evento criado',
        variant: AppToastVariant.success,
        description: 'Domingo, 3 de dezembro, às 9h',
        actionLabel: 'Desfazer',
        onAction: () => actionCount++,
      ),
    );

    await tester.tap(find.text('Mostrar toast'));
    await tester.pumpAndSettle();

    expect(find.text('Evento criado'), findsOneWidget);
    expect(find.text('Domingo, 3 de dezembro, às 9h'), findsOneWidget);
    expect(find.text('Desfazer'), findsOneWidget);
    expect(find.bySemanticsLabel('Fechar notificação'), findsOneWidget);

    final toastRect = tester.getRect(find.byType(AppToast));
    expect(toastRect.right, 784);
    expect(toastRect.bottom, 584);
    expect(toastRect.width, 384);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(actionCount, 1);
    expect(find.text('Evento criado'), findsNothing);
  });

  testWidgets('fecha manualmente e usa ícone na variante semântica', (tester) async {
    await _pumpToastTrigger(
      tester,
      onPressed: (context) => AppToast.show(
        context,
        title: 'Alterações salvas',
        variant: AppToastVariant.success,
      ),
    );

    await tester.tap(find.text('Mostrar toast'));
    await tester.pumpAndSettle();

    final icon = tester.widget<Icon>(find.byIcon(AppIcons.checkCircle));
    expect(icon.color, AppTheme.light.extension<AppTokens>()!.colors.onSurface);

    await tester.tap(find.bySemanticsLabel('Fechar notificação'));
    await tester.pumpAndSettle();

    expect(find.text('Alterações salvas'), findsNothing);
  });

  testWidgets('usa cor de status somente no ícone de erro', (tester) async {
    final tokens = AppTheme.light.extension<AppTokens>()!;
    var count = 0;

    await _pumpToastTrigger(
      tester,
      onPressed: (context) {
        final (title, variant) = switch (count++) {
          0 => ('Sucesso', AppToastVariant.success),
          1 => ('Informação', AppToastVariant.info),
          _ => ('Erro', AppToastVariant.error),
        };
        AppToast.show(context, title: title, variant: variant);
      },
    );

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.text('Mostrar toast'));
      await tester.pump(const Duration(milliseconds: 300));
    }

    final viewport = find.byKey(const ValueKey('app-toast-viewport'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await tester.pump();
    await mouse.moveTo(tester.getCenter(viewport));
    await tester.pumpAndSettle();

    expect(tester.widget<Icon>(find.byIcon(AppIcons.checkCircle)).color, tokens.colors.onSurface);
    expect(tester.widget<Icon>(find.byIcon(AppIcons.info)).color, tokens.colors.onSurface);
    expect(tester.widget<Icon>(find.byIcon(AppIcons.error)).color, tokens.colors.error);
    await mouse.removePointer();
  });

  testWidgets('limita a pilha a três e abre os toasts em coluna no hover', (tester) async {
    var count = 0;
    await _pumpToastTrigger(
      tester,
      onPressed: (context) => AppToast.show(
        context,
        title: 'Evento ${++count} criado',
        variant: AppToastVariant.success,
        description: 'Domingo, 3 de dezembro, às 9h',
        actionLabel: 'Desfazer',
        onAction: _noop,
        duration: const Duration(minutes: 1),
      ),
    );

    for (var index = 0; index < 4; index++) {
      await tester.tap(find.text('Mostrar toast'));
      await tester.pump(const Duration(milliseconds: 300));
    }

    expect(find.byType(AppToast), findsNWidgets(3));
    expect(find.text('Evento 2 criado'), findsNothing);
    expect(find.text('Evento 3 criado'), findsNothing);
    expect(find.text('Evento 4 criado'), findsOneWidget);

    Rect toastRect(String title) => tester.getRect(
      find.ancestor(of: find.text(title), matching: find.byType(AppToast)),
    );

    final collapsedToasts = find.byType(AppToast);
    final collapsedSecond = tester.getRect(collapsedToasts.at(0));
    final collapsedThird = tester.getRect(collapsedToasts.at(1));
    final collapsedFourth = tester.getRect(collapsedToasts.at(2));
    final tokens = AppTheme.light.extension<AppTokens>()!;
    final stackOffset = tokens.spacing.md;
    expect(collapsedThird.top - collapsedSecond.top, stackOffset);
    expect(collapsedFourth.top - collapsedThird.top, stackOffset);
    expect(collapsedThird.width - collapsedSecond.width, tokens.spacing.xl * 2);
    expect(collapsedFourth.width - collapsedThird.width, tokens.spacing.xl * 2);

    final viewport = find.byKey(const ValueKey('app-toast-viewport'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await tester.pump();
    await mouse.moveTo(tester.getCenter(viewport));
    await tester.pumpAndSettle();

    expect(find.text('Evento 1 criado'), findsNothing);
    expect(find.text('Evento 2 criado'), findsOneWidget);
    expect(find.text('Evento 3 criado'), findsOneWidget);
    expect(find.text('Evento 4 criado'), findsOneWidget);

    final expandedSecond = toastRect('Evento 2 criado');
    final expandedThird = toastRect('Evento 3 criado');
    final expandedFourth = toastRect('Evento 4 criado');
    expect(expandedSecond.bottom, lessThan(expandedThird.top));
    expect(expandedThird.bottom, lessThan(expandedFourth.top));
    expect(expandedSecond.width, expandedThird.width);
    expect(expandedThird.width, expandedFourth.width);

    await mouse.removePointer();
  });

  testWidgets('preserva o conteúdo estreito com texto a 200% sem overflow', (tester) async {
    await _pumpToastTrigger(
      tester,
      width: 320,
      height: 560,
      textScaler: const TextScaler.linear(2),
      onPressed: (context) => AppToast.show(
        context,
        title: 'Evento criado com sucesso',
        variant: AppToastVariant.success,
        description: 'Domingo, 3 de dezembro, às 9h',
        actionLabel: 'Desfazer',
        onAction: _noop,
      ),
    );

    await tester.tap(find.text('Mostrar toast'));
    await tester.pumpAndSettle();

    expect(find.text('Evento criado com sucesso'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}

Future<void> _pumpToastTrigger(
  WidgetTester tester, {
  required void Function(BuildContext context) onPressed,
  double width = 800,
  double height = 600,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.binding.setSurfaceSize(Size(width, height));
  addTearDown(() async {
    while (find.byIcon(AppIcons.close).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(AppIcons.close).first);
      await tester.pumpAndSettle();
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.binding.setSurfaceSize(null);
  });

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
              label: 'Mostrar toast',
              onPressed: () => onPressed(context),
            ),
          ),
        ),
      ),
    ),
  );
}
