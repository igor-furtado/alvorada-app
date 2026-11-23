import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/features/concursos/domain/models/concurso.dart';
import 'package:estudos_app/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/features/concursos/presentation/edital_editor/edital_editor_view.dart';
import 'package:estudos_app/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:estudos_app/l10n/app_localization_delegates.dart';
import 'package:estudos_app/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../disciplinas/fakes/fake_disciplinas_repository.dart';
import '../../fakes/fake_concursos_repository.dart';

void main() {
  testWidgets('reproduz a Mesa de triagem em duas colunas no desktop', (tester) async {
    await _pumpLauncher(tester, width: 1440, height: 900);

    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();

    expect(find.text('Conteúdo Programático do Edital'), findsOneWidget);
    expect(find.text('Receita Federal'), findsOneWidget);
    expect(find.text('Auditor-Fiscal'), findsOneWidget);
    expect(find.text('Receita Federal · Auditor-Fiscal'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Receita Federal')).dy,
      lessThan(tester.getTopLeft(find.text('Conteúdo Programático do Edital')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Conteúdo Programático do Edital')).dy,
      lessThan(tester.getTopLeft(find.text('Auditor-Fiscal')).dy),
    );
    expect(find.text('DISCIPLINAS'), findsNothing);
    expect(find.text('Língua Portuguesa'), findsWidgets);
    expect(find.text('Selecionar todos'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
    expect(find.text('Revisão de Véspera'), findsOneWidget);
    expect(find.text('Você pode voltar a qualquer Disciplina sem perder a seleção.'), findsNothing);

    final revisionCheckbox = tester.widget<AppCheckbox>(
      find.byWidgetPredicate(
        (widget) => widget is AppCheckbox && widget.semanticLabel == 'Revisão de Véspera',
      ),
    );
    expect(revisionCheckbox.value, isTrue);
    expect(revisionCheckbox.onChanged, isNull);

    final railLabel = tester.getTopLeft(find.text('DEMAIS DISCIPLINAS'));
    final search = tester.getTopLeft(find.byKey(const ValueKey('catalog-topic-search')));
    expect(search.dy, lessThan(railLabel.dy));
    expect(find.text('Buscar tópicos'), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('app-drawer-surface'))).width, 980);
  });

  testWidgets('reforça a Disciplina ativa e usa a mesma família com menos peso nos Tópicos', (tester) async {
    await _pumpLauncher(tester, width: 1440, height: 900);

    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();

    final tokens = AppTheme.light.extension<AppTokens>()!;
    Text discipline(String id) => tester.widget<Text>(find.byKey(ValueKey('discipline-name-$id')));
    final active = discipline('portugues');
    final inactive = discipline('constitucional');
    final topic = tester.widget<Text>(find.byKey(const ValueKey('topic-name-interpretacao')));

    expect(active.style?.fontWeight, FontWeight.w700);
    expect(active.style?.color, tokens.colors.onSurface);
    expect(inactive.style?.fontWeight, FontWeight.w600);
    expect(inactive.style?.color, tokens.colors.onSurfaceMuted);
    expect(topic.style?.fontWeight, FontWeight.w500);
    expect(topic.style?.fontFamily, active.style?.fontFamily);

    await tester.tap(find.byKey(const ValueKey('discipline-name-constitucional')));
    await tester.pump();

    expect(discipline('portugues').style?.color, tokens.colors.onSurfaceMuted);
    expect(discipline('constitucional').style?.color, tokens.colors.onSurface);
  });

  testWidgets('separa Disciplinas do conteúdo programático e atualiza as seções no rascunho', (tester) async {
    await _pumpLauncher(
      tester,
      width: 1440,
      height: 900,
      concurso: _concursoComTopico(),
    );

    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();

    final includedSection = find.text('NO EDITAL');
    final otherSection = find.text('DEMAIS DISCIPLINAS');
    final portugues = find.byKey(const ValueKey('discipline-name-portugues'));
    final constitucional = find.byKey(const ValueKey('discipline-name-constitucional'));

    expect(includedSection, findsOneWidget);
    expect(otherSection, findsOneWidget);
    expect(tester.getTopLeft(includedSection).dy, lessThan(tester.getTopLeft(portugues).dy));
    expect(tester.getTopLeft(portugues).dy, lessThan(tester.getTopLeft(otherSection).dy));
    expect(tester.getTopLeft(otherSection).dy, lessThan(tester.getTopLeft(constitucional).dy));

    await tester.tap(constitucional);
    await tester.pump();
    await tester.tap(find.text('Selecionar todos'));
    await tester.pump();

    expect(tester.getTopLeft(constitucional).dy, lessThan(tester.getTopLeft(otherSection).dy));
    expect(find.text('Salvar 3 Tópicos'), findsOneWidget);
  });

  testWidgets('busca em todas as Disciplinas, seleciona em lote e salva o rascunho', (tester) async {
    final repository = FakeConcursosRepository();
    await _pumpLauncher(
      tester,
      width: 1440,
      height: 900,
      concursosRepository: repository,
    );

    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'garantias');
    await tester.pump();
    expect(find.text('Direitos e garantias fundamentais'), findsOneWidget);
    expect(find.text('Compreensão e interpretação de textos'), findsNothing);
    expect(find.byKey(const ValueKey('discipline-name-constitucional')), findsOneWidget);
    expect(find.byKey(const ValueKey('discipline-name-portugues')), findsNothing);
    expect(find.byKey(const ValueKey('discipline-name-administrativo')), findsNothing);

    await tester.tap(find.text('Selecionar todos'));
    await tester.pump();
    expect(find.text('Salvar 2 Tópicos'), findsOneWidget);
    expect(repository.addTopicoCalls, 0);

    await tester.tap(find.text('Salvar 2 Tópicos'));
    await tester.pumpAndSettle();

    expect(repository.addTopicoCalls, 2);
    expect(find.byKey(const ValueKey('app-drawer-surface')), findsNothing);
    expect(find.text('Salvo'), findsOneWidget);
  });

  testWidgets('mantém a triagem utilizável em largura compacta e texto ampliado', (tester) async {
    await _pumpLauncher(
      tester,
      width: 390,
      height: 844,
      textScaler: const TextScaler.linear(1.5),
    );

    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();

    expect(find.text('Conteúdo Programático do Edital'), findsOneWidget);
    expect(find.text('Selecionar todos'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('app-drawer-surface'))).width, 390);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpLauncher(
  WidgetTester tester, {
  required double width,
  required double height,
  FakeConcursosRepository? concursosRepository,
  Concurso? concurso,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final concursos = concursosRepository ?? FakeConcursosRepository();
  final disciplinas = FakeDisciplinasRepository(disciplinas: disciplinasFixture());
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ConcursosUseCases>.value(value: ConcursosUseCases(concursos)),
        RepositoryProvider<DisciplinasUseCases>.value(value: DisciplinasUseCases(disciplinas)),
      ],
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: AppButton(
                label: 'Abrir editor',
                onPressed: () async {
                  final saved = await showAppDrawerBuilder<bool>(
                    context,
                    builder: (_) => EditalEditorView(concurso: concurso ?? _concurso()),
                  );
                  if (saved == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvo')));
                  }
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Concurso _concurso() => Concurso(
  id: 'concurso-1',
  instituicao: 'Receita Federal',
  cargo: 'Auditor-Fiscal',
  banca: null,
  dataProva: null,
  prioritario: false,
  progressoEdital: 0,
);

Concurso _concursoComTopico() => Concurso(
  id: 'concurso-1',
  instituicao: 'Receita Federal',
  cargo: 'Auditor-Fiscal',
  banca: null,
  dataProva: null,
  prioritario: false,
  progressoEdital: 0,
  disciplinas: [
    DisciplinaEdital(
      id: 'portugues',
      nome: 'Língua Portuguesa',
      topicos: [
        TopicoEdital(
          id: 'interpretacao',
          nome: 'Compreensão e interpretação de textos',
          obrigatorio: false,
        ),
        TopicoEdital(
          id: 'revisao-portugues',
          nome: 'Revisão de Véspera',
          obrigatorio: true,
        ),
      ],
    ),
  ],
);
