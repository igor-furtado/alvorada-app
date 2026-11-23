import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/core/result.dart';
import 'package:estudos_app/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/features/disciplinas/presentation/topicos_form/topicos_form_view.dart';
import 'package:estudos_app/features/disciplinas/presentation/topicos_list/topicos_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_disciplinas_repository.dart';

void main() {
  testWidgets('mostra todos os Tópicos no editor com a Disciplina no eyebrow', (
    tester,
  ) async {
    await _pumpForm(tester);

    expect(find.text('LÍNGUA PORTUGUESA'), findsOneWidget);
    expect(find.text('Editar Tópicos'), findsWidgets);
    expect(find.text('Tópicos atuais'), findsOneWidget);
    expect(find.text('Compreensão e interpretação de textos'), findsOneWidget);
    expect(find.text('Domínio da estrutura morfossintática'), findsOneWidget);
    expect(find.text(nomeTopicoRevisaoVespera), findsOneWidget);
    expect(find.text('Protegido'), findsOneWidget);
    expect(find.text('Novos Tópicos'), findsOneWidget);
  });

  testWidgets('edita, remove e adiciona vários Tópicos antes de salvar', (
    tester,
  ) async {
    final repository = FakeDisciplinasRepository(
      disciplinas: disciplinasFixture(),
    );
    await _pumpForm(tester, repository: repository);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Interpretação textual',
    );
    await tester.tap(
      find.byTooltip('Remover Domínio da estrutura morfossintática'),
    );
    await tester.pump();
    await tester.enterText(
      find.byType(TextFormField).last,
      'Pontuação\nConcordância',
    );

    await tester.tap(find.widgetWithText(AppButton, 'Salvar alterações'));
    await tester.pumpAndSettle();

    final result = await DisciplinasUseCases(repository).getDisciplinas();
    final topics = (result as Sucesso<List<Disciplina>>).valor.first.topics;
    expect(
      topics.map((topic) => topic.name),
      [
        'Interpretação textual',
        'Pontuação',
        'Concordância',
        nomeTopicoRevisaoVespera,
      ],
    );
  });

  testWidgets('mostra a prévia normalizada dos novos Tópicos enquanto digita', (
    tester,
  ) async {
    await _pumpForm(tester);

    expect(find.text('Prévia'), findsOneWidget);
    expect(find.text('0 itens'), findsOneWidget);
    expect(
      find.text('Os Tópicos aparecerão aqui conforme você digitar.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextFormField).last,
      '1. RAG\n- Engenharia de prompt\nRAG',
    );
    await tester.pump();

    expect(find.text('2 itens'), findsOneWidget);
    expect(find.text('RAG'), findsOneWidget);
    expect(find.text('Engenharia de prompt'), findsOneWidget);
    expect(find.text('03'), findsOneWidget);
    expect(find.text('04'), findsOneWidget);
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  FakeDisciplinasRepository? repository,
}) async {
  final effectiveRepository = repository ?? FakeDisciplinasRepository(disciplinas: disciplinasFixture());
  final useCases = DisciplinasUseCases(effectiveRepository);
  final disciplina = disciplinasFixture().first;
  await tester.pumpWidget(
    RepositoryProvider.value(
      value: useCases,
      child: MaterialApp(
        theme: AppTheme.light,
        home: TopicosFormView(
          disciplineId: disciplina.id,
          disciplineName: disciplina.name,
          topics: [
            for (final topic in disciplina.topics)
              TopicoListItemData(
                id: topic.id,
                name: topic.name,
                mandatory: topic.mandatory,
              ),
          ],
        ),
      ),
    ),
  );
}
