import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/features/concursos/domain/models/concurso.dart';
import 'package:estudos_app/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/features/concursos/presentation/concurso_details/concurso_details_page.dart';
import 'package:estudos_app/l10n/app_localization_delegates.dart';
import 'package:estudos_app/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes/fake_concursos_repository.dart';

final _pt = lookupAppLocalizations(const Locale('pt'));

void main() {
  testWidgets('carrega um Concurso real ao abrir a rota diretamente', (
    tester,
  ) async {
    final concurso = _concurso();

    await _pump(
      tester,
      repository: FakeConcursosRepository(concursos: [concurso]),
      child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
    );

    expect(find.text(concurso.instituicao), findsWidgets);
    expect(find.text(_pt.syllabusContentButton), findsWidgets);
    expect(find.byKey(const ValueKey('edit-exam-button')), findsOneWidget);
    expect(find.text(_pt.concursoNaoEncontrado), findsNothing);
    expect(find.byType(AppBreadcrumbs), findsOneWidget);
    expect(find.byKey(const ValueKey('discipline-search')), findsOneWidget);
  });

  testWidgets('não oferece edição local sem persistência do Edital', (
    tester,
  ) async {
    await _pump(
      tester,
      repository: FakeConcursosRepository(concursos: [_concurso()]),
      child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
    );

    expect(find.text(_pt.newDiscipline), findsNothing);
    expect(find.text(_pt.seeDetails), findsNothing);
    expect(find.text(_pt.noDiscipline), findsOneWidget);
  });

  testWidgets('abre a edição com os dados atuais do Concurso', (
    tester,
  ) async {
    final concurso = _concurso();
    await _pump(
      tester,
      repository: FakeConcursosRepository(concursos: [concurso]),
      child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
    );

    await tester.tap(find.byKey(const ValueKey('edit-exam-button')));
    await tester.pumpAndSettle();

    final inputs = tester.widgetList<EditableText>(find.byType(EditableText)).toList();
    expect(inputs.map((input) => input.controller.text).where((text) => text.isNotEmpty), [
      concurso.instituicao,
      concurso.sigla,
      concurso.cargo,
      concurso.banca,
      _pt.statutoryHiringRegime,
      '12',
      '12.345,67',
      '40',
      '21/02/2027',
      '13:00',
      '18:00',
      concurso.localProva,
      concurso.requisitos,
      concurso.criteriosPontuacao,
    ]);
    expect(find.text(_pt.saveChanges), findsOneWidget);
    expect(find.text(_pt.statutoryHiringRegime), findsOneWidget);
    expect(find.text(_pt.cancel), findsNothing);
  });

  testWidgets('alterna métricas sem inventar avanço ou desempenho por Disciplina', (tester) async {
    await _pump(
      tester,
      repository: FakeConcursosRepository(concursos: [_concursoComEdital()]),
      child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
    );

    expect(find.text('Direito Tributário'), findsOneWidget);
    expect(find.byKey(const ValueKey('discipline-weight-tributario')), findsOneWidget);

    await tester.tap(find.text(_pt.advance));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('discipline-weight-tributario')), findsNothing);
    expect(find.text('—'), findsWidgets);

    await tester.tap(find.text(_pt.performance).first);
    await tester.pumpAndSettle();
    expect(find.text('—'), findsWidgets);
  });

  testWidgets('reorganiza cabeçalho e conteúdo nas larguras de referência', (tester) async {
    final repository = FakeConcursosRepository(concursos: [_concursoComEdital()]);

    for (final width in [390.0, 720.0, 1024.0, 1440.0]) {
      await _pump(
        tester,
        repository: repository,
        child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
        size: Size(width, 1200),
        textScaleFactor: width == 390 ? 2 : 1,
      );

      expect(find.text('Receita Federal'), findsWidgets, reason: 'largura $width');
      expect(find.text(_pt.syllabusContentButton), findsOneWidget, reason: 'largura $width');
      expect(find.byKey(const ValueKey('edit-exam-button')), findsOneWidget, reason: 'largura $width');
      final exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason: exception is FlutterError ? 'largura $width\n${exception.toStringDeep()}' : 'largura $width',
      );
    }
  });

  testWidgets('distingue falha técnica e permite tentar novamente', (tester) async {
    final repository = FakeConcursosRepository(concursos: [_concurso()])..failLoad = true;
    await _pump(
      tester,
      repository: repository,
      child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
    );

    expect(find.text(_pt.genericErrorTitle), findsOneWidget);
    expect(find.text(_pt.concursoNaoEncontrado), findsNothing);

    repository.failLoad = false;
    await tester.tap(find.text(_pt.tryAgain));
    await tester.pumpAndSettle();

    expect(find.text('Tribunal Regional Federal da 5ª Região'), findsWidgets);
    expect(find.text(_pt.genericErrorTitle), findsNothing);
  });

  testWidgets('filtra Disciplinas e persiste peso decimal inline', (tester) async {
    final repository = FakeConcursosRepository(concursos: [_concursoComEdital()]);
    await _pump(
      tester,
      repository: repository,
      child: const ConcursoDetailsPage(concursoId: 'concurso-real'),
    );

    await tester.enterText(find.byKey(const ValueKey('discipline-search')), 'tributário');
    await tester.pumpAndSettle();
    expect(find.text('Direito Tributário'), findsOneWidget);

    final weight = find.byKey(const ValueKey('discipline-weight-tributario'));
    await tester.enterText(weight, '2,5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.updateDisciplinaPesoCalls, 1);
    expect(tester.widget<AppTextInput>(weight).controller?.text, '2.5');
  });
}

Concurso _concurso() => Concurso(
  id: 'concurso-real',
  instituicao: 'Tribunal Regional Federal da 5ª Região',
  cargo: 'Técnico Judiciário',
  banca: 'FCC',
  dataProva: DateTime(2027, 2, 21),
  prioritario: false,
  progressoEdital: 0,
  sigla: 'TRF5',
  regimeContratacao: RegimeContratacao.estatutario,
  quantidadeVagas: 12,
  vencimentoCentavos: 1234567,
  cargaHorariaSemanal: 40,
  localProva: 'Recife/PE',
  horarioInicioProva: '13:00',
  horarioFimProva: '18:00',
  requisitos: 'Nível superior completo.',
  criteriosPontuacao: 'Provas com pesos por bloco.',
);

Concurso _concursoComEdital() => Concurso(
  id: 'concurso-real',
  instituicao: 'Receita Federal',
  cargo: 'Auditor-Fiscal',
  banca: 'FGV',
  dataProva: null,
  prioritario: true,
  progressoEdital: 42,
  disciplinas: [
    DisciplinaEdital(
      id: 'tributario',
      nome: 'Direito Tributário',
      peso: 2,
      topicos: [
        TopicoEdital(id: 'obrigacao', nome: 'Obrigação tributária', obrigatorio: false),
        TopicoEdital(id: 'revisao', nome: 'Revisão de Véspera', obrigatorio: true),
      ],
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester, {
  required FakeConcursosRepository repository,
  required Widget child,
  Size size = const Size(1440, 1200),
  double textScaleFactor = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    RepositoryProvider<ConcursosUseCases>.value(
      value: ConcursosUseCases(repository),
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
