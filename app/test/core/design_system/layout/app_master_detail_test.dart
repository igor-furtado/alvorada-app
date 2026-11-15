import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/core/design_system/layout/app_resizable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, double width) async {
    await tester.binding.setSurfaceSize(Size(width, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: width,
            height: 500,
            child: const AppMasterDetail(
              master: SizedBox(key: ValueKey('master'), height: 100),
              detail: SizedBox(key: ValueKey('detail'), height: 100),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('empilha mestre e detalhe quando não há largura para painéis', (tester) async {
    await pump(tester, 500);

    expect(find.byType(AppResizable), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('detail'))).dy,
      greaterThan(tester.getTopLeft(find.byKey(const ValueKey('master'))).dy),
    );
  });

  testWidgets('usa painéis redimensionáveis quando há largura suficiente', (tester) async {
    await pump(tester, 1000);

    expect(find.byType(AppResizable), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('detail'))).dx,
      greaterThan(tester.getTopLeft(find.byKey(const ValueKey('master'))).dx),
    );
  });
}
