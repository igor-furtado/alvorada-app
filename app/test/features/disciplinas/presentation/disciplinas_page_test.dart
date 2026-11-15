import 'package:estudos_app/app/app.dart';
import 'package:estudos_app/app/app_dependencies.dart';
import 'package:estudos_app/features/disciplinas/domain/models/disciplina.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../concursos/fakes/fake_concursos_repository.dart';
import '../fakes/fake_disciplinas_repository.dart';

void main() {
  testWidgets('reorganiza catálogo e tópicos nas larguras de referência', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final dependencies = AppDependencies.fromRepositories(
      concursos: FakeConcursosRepository(),
      disciplinas: FakeDisciplinasRepository(disciplinas: [_disciplina()]),
    );

    for (final width in [390.0, 720.0, 1024.0, 1440.0]) {
      await tester.binding.setSurfaceSize(Size(width, 1000));
      tester.platformDispatcher.textScaleFactorTestValue = width == 390 ? 2 : 1;
      await tester.pumpWidget(EstudosApp(locale: const Locale('pt'), dependencies: dependencies));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('shell-destination-1')));
      await tester.pumpAndSettle();

      expect(find.text('Direito Tributário'), findsWidgets, reason: 'largura $width');
      expect(find.text('Obrigação tributária'), findsOneWidget, reason: 'largura $width');
      expect(find.text('Revisão de Véspera'), findsOneWidget, reason: 'largura $width');
      expect(tester.takeException(), isNull, reason: 'largura $width');
    }
  });
}

Disciplina _disciplina() => Disciplina(
  id: 'tributario',
  name: 'Direito Tributário',
  difficulty: DificuldadeDisciplina.hard,
  color: '#2563EB',
  topics: [
    Topico(id: 'obrigacao', name: 'Obrigação tributária', mandatory: false),
    Topico(id: 'revisao', name: nomeTopicoRevisaoVespera, mandatory: true),
  ],
);
