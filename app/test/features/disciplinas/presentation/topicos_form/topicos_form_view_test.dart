import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/features/disciplinas/presentation/topicos_form/topicos_form_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  testWidgets('permite informar vários Tópicos por linha e mostra a contagem', (tester) async {
    final useCases = DisciplinasUseCases(
      FakeDisciplinasRepository(disciplinas: disciplinasFixture()),
    );
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: useCases,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TopicosFormView(
            disciplineId: 'portugues',
            disciplineName: 'Língua Portuguesa',
          ),
        ),
      ),
    );

    expect(find.text('Adicionar Tópicos'), findsWidgets);
    expect(find.text('LÍNGUA PORTUGUESA'), findsOneWidget);
    expect(find.textContaining('Digite ou cole um Tópico por linha.'), findsOneWidget);
    expect(find.text('0 itens'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'Pontuação\n\nConcordância',
    );
    await tester.pump();

    expect(find.textContaining('Tópicos prontos para adicionar.'), findsNothing);
    expect(find.text('2 itens'), findsOneWidget);
    expect(find.text('Adicionar 2 Tópicos'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
    expect(find.text('Pontuação'), findsOneWidget);
    expect(find.text('Concordância'), findsOneWidget);
  });
}
