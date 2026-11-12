import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/features/concursos/presentation/concurso_details/edital_metrics_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('alterna entre as métricas e suas faixas', (tester) async {
    await _pump(
      tester,
      const EditalMetricsCard(
        advance: .42,
        performance: .71,
        advanceDistribution: EditalMetricDistribution(lower: 5, middle: 8, upper: 5),
        performanceDistribution: EditalMetricDistribution(lower: 4, middle: 10, upper: 4),
      ),
    );

    expect(find.text('42%'), findsOneWidget);
    expect(find.text('Até 25%'), findsOneWidget);
    expect(find.text('26% a 60%'), findsOneWidget);
    expect(find.text('Acima de 60%'), findsOneWidget);
    expect(find.text('5'), findsNWidgets(2));
    expect(find.text('8'), findsOneWidget);

    await tester.tap(find.text('Desempenho'));
    await tester.pumpAndSettle();

    expect(find.text('71%'), findsOneWidget);
    expect(find.text('Abaixo de 60%'), findsOneWidget);
    expect(find.text('60% a 79%'), findsOneWidget);
    expect(find.text('A partir de 80%'), findsOneWidget);
    expect(find.text('4'), findsNWidgets(2));
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('não inventa desempenho quando a métrica ainda não existe', (tester) async {
    await _pump(tester, const EditalMetricsCard(advance: 0));

    await tester.tap(find.text('Desempenho'));
    await tester.pumpAndSettle();

    expect(find.text('—'), findsNWidgets(4));
    expect(find.text('0%'), findsNothing);
  });
}

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(child: SizedBox(width: 300, child: child)),
    ),
  ),
);
