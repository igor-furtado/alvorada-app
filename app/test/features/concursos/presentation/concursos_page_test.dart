import 'package:estudos_app/app/app.dart';
import 'package:estudos_app/app/app_dependencies.dart';
import 'package:estudos_app/features/concursos/domain/models/concurso.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../disciplinas/fakes/fake_disciplinas_repository.dart';
import '../fakes/fake_concursos_repository.dart';

void main() {
  testWidgets('reorganiza a lista de Concursos nas larguras de referência', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final dependencies = AppDependencies.fromRepositories(
      concursos: FakeConcursosRepository(concursos: [_concurso()]),
      disciplinas: FakeDisciplinasRepository(),
    );

    for (final width in [390.0, 720.0, 1024.0, 1440.0]) {
      await tester.binding.setSurfaceSize(Size(width, 1000));
      tester.platformDispatcher.textScaleFactorTestValue = width == 390 ? 2 : 1;
      await tester.pumpWidget(EstudosApp(locale: const Locale('pt'), dependencies: dependencies));
      await tester.pumpAndSettle();

      expect(find.text('Tribunal Regional Federal da 5ª Região'), findsWidgets, reason: 'largura $width');
      expect(find.text('Técnico Judiciário'), findsWidgets, reason: 'largura $width');
      expect(tester.takeException(), isNull, reason: 'largura $width');
    }
  });
}

Concurso _concurso() => Concurso(
  id: 'trf5',
  instituicao: 'Tribunal Regional Federal da 5ª Região',
  cargo: 'Técnico Judiciário',
  banca: 'FCC',
  dataProva: DateTime(2027, 2, 21),
  prioritario: true,
  progressoEdital: 35,
);
