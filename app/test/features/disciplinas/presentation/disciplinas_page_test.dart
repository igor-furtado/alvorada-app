import 'package:estudos_app/app/app.dart';
import 'package:estudos_app/app/app_dependencies.dart';
import 'package:estudos_app/features/disciplinas/domain/models/disciplina.dart';
import 'package:flutter/gestures.dart';
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

      expect(find.text('Catálogo de Disciplinas'), findsOneWidget, reason: 'largura $width');
      expect(find.text('Nova Disciplina'), findsOneWidget, reason: 'largura $width');
      expect(find.text('Direito Tributário'), findsWidgets, reason: 'largura $width');
      if (width == 390) {
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byKey(const ValueKey('shell-destination-0')), findsOneWidget);
        expect(find.byKey(const ValueKey('shell-destination-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('shell-destination-2')), findsOneWidget);
        expect(find.byKey(const ValueKey('compact-master-detail-back')), findsNothing);
      }
      expect(find.text('Obrigação tributária'), findsOneWidget, reason: 'largura $width');
      expect(find.byTooltip('Arraste para reordenar'), findsNWidgets(2), reason: 'largura $width');
      expect(find.text('Revisão de Véspera'), findsOneWidget, reason: 'largura $width');
      expect(tester.takeException(), isNull, reason: 'largura $width');
    }
  });

  testWidgets('reposiciona Disciplinas por arrastar e soltar', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1024, 1000));
    final repository = FakeDisciplinasRepository(
      disciplinas: [
        _disciplinaNamed('portugues', 'Língua Portuguesa'),
        _disciplinaNamed('constitucional', 'Direito Constitucional'),
        _disciplinaNamed('administrativo', 'Direito Administrativo'),
      ],
    );
    final dependencies = AppDependencies.fromRepositories(
      concursos: FakeConcursosRepository(),
      disciplinas: repository,
    );
    await tester.pumpWidget(
      EstudosApp(locale: const Locale('pt'), dependencies: dependencies),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shell-destination-1')));
    await tester.pumpAndSettle();

    final handles = find.byTooltip('Arraste para reordenar a Disciplina');
    expect(handles, findsNWidgets(3));
    final gesture = await tester.startGesture(tester.getCenter(handles.first));
    await tester.pump(kPressTimeout);
    await gesture.moveBy(const Offset(0, 180));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final disciplinas = await repository.getDisciplinas();
    expect(
      disciplinas.map((disciplina) => disciplina.id),
      ['constitucional', 'administrativo', 'portugues'],
    );
    expect(find.text('Ordem das Disciplinas atualizada.'), findsOneWidget);
  });
}

Disciplina _disciplina() => Disciplina(
  id: 'tributario',
  name: 'Direito Tributário',
  difficulty: DificuldadeDisciplina.hard,
  color: '#2563EB',
  topics: [
    Topico(id: 'obrigacao', name: 'Obrigação tributária', mandatory: false),
    Topico(id: 'credito', name: 'Crédito tributário', mandatory: false),
    Topico(id: 'revisao', name: nomeTopicoRevisaoVespera, mandatory: true),
  ],
);

Disciplina _disciplinaNamed(String id, String name) => Disciplina(
  id: id,
  name: name,
  difficulty: DificuldadeDisciplina.medium,
  color: '#E8742A',
  topics: [
    Topico(
      id: 'revisao-$id',
      name: nomeTopicoRevisaoVespera,
      mandatory: true,
    ),
  ],
);
