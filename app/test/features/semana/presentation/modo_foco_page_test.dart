import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/features/semana/domain/use_cases/semana_use_cases.dart';
import 'package:estudos_app/features/semana/presentation/modo_foco/modo_foco_page.dart';
import 'package:estudos_app/l10n/app_localization_delegates.dart';
import 'package:estudos_app/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes/fake_semana_repository.dart';

void main() {
  testWidgets('permite navegar livremente e registra questões somente com o cronômetro ativo', (tester) async {
    final repository = FakeSemanaRepository(items: [semanaItemFixture()]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ModoFocoPage(
          item: semanaItemFixture(),
          useCases: SemanaUseCases(repository),
        ),
      ),
    );

    expect(find.text('Estudo da teoria'), findsOneWidget);
    await tester.tap(find.text('Questões').first);
    await tester.pump();
    expect(find.text('Questões e Caderno de Erros'), findsOneWidget);

    expect(find.byKey(const ValueKey('answer-correct')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('answer-correct')));
    await tester.pump();
    expect(repository.questionCalls, 0);

    await tester.ensureVisible(find.text('Começar').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar').last);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('answer-correct')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('answer-correct')));
    await tester.pump();

    expect(repository.questionCalls, 1);
    expect(find.text('1'), findsWidgets);

    await tester.tap(find.text('Teoria').first);
    await tester.pump();
    await tester.tap(find.text('Questões').first);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('answer-correct')));
    await tester.pump();
    expect(repository.questionCalls, 1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('se adapta a uma tela compacta sem perder as etapas', (tester) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ModoFocoPage(
          item: semanaItemFixture(),
          useCases: SemanaUseCases(FakeSemanaRepository(items: [semanaItemFixture()])),
        ),
      ),
    );

    expect(find.text('Estudo da teoria'), findsOneWidget);
    expect(find.text('Salvar e sair'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conclui as três atividades centrais e salva qualquer combinação de revisões', (tester) async {
    final completed = semanaItemFixture(theory: true, memory: true, conference: true);
    final repository = FakeSemanaRepository(items: [completed]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ModoFocoPage(item: completed, useCases: SemanaUseCases(repository)),
      ),
    );

    await tester.tap(find.text('Revisões').first);
    await tester.pump();
    await tester.tap(find.text('D+1'));
    await tester.tap(find.text('D+30'));
    await tester.ensureVisible(find.text('Concluir ciclo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluir ciclo'));
    await tester.pump();

    expect(repository.selectedReviews, {1, 30});
    expect(find.text('2 revisões agendadas'), findsOneWidget);
    expect(find.text('Voltar para a semana'), findsOneWidget);
  });
}
