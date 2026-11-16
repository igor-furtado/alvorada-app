import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/features/concursos/presentation/concursos_form/concursos_form_view.dart';
import 'package:estudos_app/l10n/app_localization_delegates.dart';
import 'package:estudos_app/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_concursos_repository.dart';

final _pt = lookupAppLocalizations(const Locale('pt'));

void main() {
  testWidgets('organiza os horários lado a lado e amplia as áreas de texto', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RepositoryProvider<ConcursosUseCases>.value(
        value: ConcursosUseCases(FakeConcursosRepository()),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: ConcursosFormView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_pt.hiringRegime), findsOneWidget);
    expect(find.text(_pt.hiringRegimePlaceholder), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(_pt.examStartTime)).dy,
      tester.getTopLeft(find.text(_pt.examEndTime)).dy,
    );
    expect(find.text(r'R$'), findsOneWidget);

    final requirements = tester.widget<AppTextarea>(
      find.byKey(const ValueKey('requirements-textarea')),
    );
    final scoring = tester.widget<AppTextarea>(
      find.byKey(const ValueKey('scoring-criteria-textarea')),
    );
    expect(requirements.minLines, 5);
    expect(scoring.minLines, 5);
  });

  testWidgets('exibe a falha de cadastro uma única vez e fora dos campos', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = FakeConcursosRepository()..failMutation = true;
    await tester.pumpWidget(
      RepositoryProvider<ConcursosUseCases>.value(
        value: ConcursosUseCases(repository),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: ConcursosFormView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final inputs = find.byType(EditableText);
    await tester.enterText(inputs.at(0), 'Concurso Unificado do Maranhão');
    await tester.enterText(inputs.at(2), 'Auditor Estadual');
    await tester.tap(find.text(_pt.criarConcurso));
    await tester.pumpAndSettle();

    expect(find.byType(AppAlert), findsOneWidget);
    expect(find.text(_pt.concursoSaveFailed), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).first).forceErrorText,
      isNull,
    );
  });

  testWidgets('confirma antes de descartar alterações não salvas', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RepositoryProvider<ConcursosUseCases>.value(
        value: ConcursosUseCases(FakeConcursosRepository()),
        child: MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => AppButton(
                label: 'Abrir formulário',
                onPressed: () => showAppDrawerBuilder<void>(
                  context,
                  builder: (_) => const ConcursosFormView(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir formulário'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'Secretaria da Fazenda');
    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-drawer-surface')), findsOneWidget);
    expect(find.text(_pt.unsavedChangesTitle), findsOneWidget);
    await tester.tap(find.text(_pt.keepEditing));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-drawer-surface')), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_pt.discardChanges));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-drawer-surface')), findsNothing);
  });

  testWidgets('reorganiza o formulário nas larguras de referência', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final width in [390.0, 720.0, 1024.0, 1440.0]) {
      await tester.binding.setSurfaceSize(Size(width, 1200));
      tester.platformDispatcher.textScaleFactorTestValue = width == 390 ? 2 : 1;
      await tester.pumpWidget(
        RepositoryProvider<ConcursosUseCases>.value(
          value: ConcursosUseCases(FakeConcursosRepository()),
          child: MaterialApp(
            locale: const Locale('pt'),
            localizationsDelegates: appLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light,
            home: const Scaffold(body: ConcursosFormView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppField), findsWidgets, reason: 'largura $width');
      expect(find.byType(EditableText), findsWidgets, reason: 'largura $width');
      expect(find.text(_pt.criarConcurso), findsOneWidget, reason: 'largura $width');
      expect(tester.takeException(), isNull, reason: 'largura $width');
    }
  });
}
