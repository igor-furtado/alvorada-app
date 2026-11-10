import 'package:estudos_app/src/app.dart';
import 'package:estudos_app/src/core/content/app_messages.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:estudos_app/src/features/administration/presentation/administration_page.dart';
import 'package:estudos_app/src/features/design_system/presentation/component_catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setWindow(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('abre o catálogo dentro da administração', (tester) async {
    await setWindow(tester, const Size(1440, 1000));
    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('shell-administration')));
    await tester.pumpAndSettle();

    expect(find.byType(AdministrationPage), findsOneWidget);
    expect(find.text(AppMessages.administration), findsOneWidget);

    await tester.tap(find.text(AppMessages.componentCatalog));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ComponentCatalogPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ComponentCatalogPage),
        matching: find.text(AppMessages.componentCatalog),
      ),
      findsNWidgets(2),
    );
    expect(find.text('Átomos'), findsOneWidget);
    expect(find.text('Moléculas'), findsOneWidget);
    expect(find.text('Organismos'), findsOneWidget);
    expect(find.text('Tokens'), findsOneWidget);
    expect(find.text('Cores semânticas'), findsOneWidget);
    expect(find.text('Tipografia'), findsOneWidget);
    expect(find.text('Espaçamento'), findsOneWidget);
    expect(find.text('Bordas'), findsOneWidget);
    expect(find.text('Sombra de overlay'), findsOneWidget);
    expect(find.text('Movimento'), findsOneWidget);
    expect(find.text('Layout'), findsOneWidget);
    expect(find.text('Ícones'), findsOneWidget);
    expect(find.text('Opacidade'), findsOneWidget);
    expect(find.text('Tamanhos semânticos'), findsOneWidget);
    expect(find.text('dialogBarrier'), findsOneWidget);
    expect(find.text('alertDialogSmallMaxWidth'), findsOneWidget);
    expect(find.text('contestPage'), findsOneWidget);

    await tester.tap(find.text('Átomos'));
    await tester.pump(const Duration(seconds: 1));
    for (final component in AppComponentRegistry.components.where(
      (component) => component.category == AppComponentCategory.atom,
    )) {
      expect(find.text(component.interfaceName), findsOneWidget);
    }

    await tester.tap(find.text('Moléculas'));
    await tester.pump(const Duration(seconds: 1));
    for (final component in AppComponentRegistry.components.where(
      (component) => component.category == AppComponentCategory.molecule,
    )) {
      expect(find.text(component.interfaceName), findsOneWidget);
    }

    await tester.tap(find.text('Organismos'));
    await tester.pump(const Duration(seconds: 1));
    for (final component in AppComponentRegistry.components.where(
      (component) => component.category == AppComponentCategory.organism,
    )) {
      expect(find.text(component.interfaceName), findsOneWidget);
    }
    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Small'), findsOneWidget);
    expect(find.text('Media'), findsOneWidget);
    expect(find.text('Small com mídia'), findsOneWidget);
    expect(find.text('Destructive'), findsOneWidget);

    await tester.tap(find.text('Tokens'));
    await tester.pump(const Duration(seconds: 1));

    tester.view.physicalSize = const Size(390, 844);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Cores semânticas'), findsOneWidget);

    expect(tester.takeException(), isNull);
    expect(find.byType(ComponentCatalogPage), findsOneWidget);
  });
}
