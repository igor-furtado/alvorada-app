import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/features/semana/domain/models/planejamento_semanal.dart';
import 'package:estudos_app/features/semana/domain/use_cases/semana_use_cases.dart';
import 'package:estudos_app/features/semana/presentation/semana/semana_page.dart';
import 'package:estudos_app/l10n/app_localization_delegates.dart';
import 'package:estudos_app/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes/fake_semana_repository.dart';

void main() {
  testWidgets('adicionar estudo planeja o Tópico e abre o modo foco', (tester) async {
    final repository = FakeSemanaRepository(
      available: const [
        TopicoDisponivelSemana(
          concursoId: 'tce',
          concursoNome: 'Tribunal de Contas do Estado',
          concursoSigla: 'TCE-CE',
          topicoId: 'atos',
          topicoNome: 'Atos administrativos',
          disciplinaNome: 'Direito Administrativo',
        ),
      ],
    );

    await tester.pumpWidget(
      RepositoryProvider.value(
        value: SemanaUseCases(repository),
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('pt'),
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SemanaPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar estudo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atos administrativos'));
    await tester.pumpAndSettle();

    expect(find.text('Estudo da teoria'), findsOneWidget);
    expect(find.text('TCE-CE'), findsOneWidget);
    expect(repository.loadCalls, 1);
  });

  testWidgets('abrir um Tópico da semana inicia o modo foco', (tester) async {
    final repository = FakeSemanaRepository(items: [semanaItemFixture()]);

    await tester.pumpWidget(
      RepositoryProvider.value(
        value: SemanaUseCases(repository),
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('pt'),
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SemanaPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Atos administrativos'));
    await tester.pumpAndSettle();

    expect(find.text('Estudo da teoria'), findsOneWidget);
    expect(find.text('TCE-CE'), findsOneWidget);
  });
}
