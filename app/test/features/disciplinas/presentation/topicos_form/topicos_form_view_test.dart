import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/src/features/disciplinas/presentation/topicos_form/topicos_form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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
          home: const TopicosFormView(disciplineId: 'portugues'),
        ),
      ),
    );

    expect(find.text('Adicionar Tópicos'), findsWidgets);
    expect(find.textContaining('Digite um Tópico por linha.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'Pontuação\n\nConcordância',
    );
    await tester.pump();

    expect(find.textContaining('2 Tópicos prontos para adicionar.'), findsOneWidget);
    expect(find.text('Adicionar 2 Tópicos'), findsOneWidget);
  });
}
