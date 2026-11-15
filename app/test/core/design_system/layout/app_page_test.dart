import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reposiciona a ação do cabeçalho no espaço compacto', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppPage.scroll(
            title: 'Disciplinas',
            description: 'Catálogo compartilhado entre Concursos.',
            headerAction: SizedBox(key: ValueKey('action'), height: 40),
            child: SizedBox(key: ValueKey('content'), height: 100),
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('action'))).dy,
      greaterThan(tester.getBottomLeft(find.text('Catálogo compartilhado entre Concursos.')).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
