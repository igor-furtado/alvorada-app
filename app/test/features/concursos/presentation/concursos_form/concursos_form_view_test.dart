import 'package:estudos_app/src/core/content/app_messages.dart';
import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:estudos_app/src/features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'package:estudos_app/src/features/concursos/presentation/concursos_form/concursos_form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_concursos_repository.dart';

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

    expect(find.text(AppMessages.hiringRegime), findsOneWidget);
    expect(find.text(AppMessages.hiringRegimePlaceholder), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(AppMessages.examStartTime)).dy,
      tester.getTopLeft(find.text(AppMessages.examEndTime)).dy,
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
    await tester.tap(find.text(AppMessages.criarConcurso));
    await tester.pumpAndSettle();

    expect(find.byType(AppAlert), findsOneWidget);
    expect(find.text('Falha simulada.'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).first).forceErrorText,
      isNull,
    );
  });
}
