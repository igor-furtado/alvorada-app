import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe a anatomia padrão e aciona os dois botões', (tester) async {
    var primaryTaps = 0;
    var secondaryTaps = 0;

    await _pumpStateView(
      tester,
      AppStateView(
        variant: AppStateVariant.empty,
        title: 'Nenhum Concurso ainda',
        message: 'Comece adicionando o primeiro.',
        actionLabel: 'Criar Concurso',
        onAction: () => primaryTaps++,
        secondaryActionLabel: 'Importar Concurso',
        onSecondaryAction: () => secondaryTaps++,
        footer: const Text('Saiba mais'),
      ),
    );

    expect(find.byIcon(AppIcons.folderDashed), findsOneWidget);
    expect(find.text('Nenhum Concurso ainda'), findsOneWidget);
    expect(find.text('Comece adicionando o primeiro.'), findsOneWidget);
    expect(find.text('Saiba mais'), findsOneWidget);

    await tester.tap(find.text('Criar Concurso'));
    await tester.tap(find.text('Importar Concurso'));

    expect(primaryTaps, 1);
    expect(secondaryTaps, 1);
  });

  testWidgets('oferece contorno, fundo suave, mídia e conteúdo personalizados', (tester) async {
    await _pumpStateView(
      tester,
      const AppStateView(
        variant: AppStateVariant.empty,
        surface: AppStateSurface.outline,
        media: AppAvatar(initials: 'LM', semanticLabel: 'Lucas Martins'),
        mediaVariant: AppStateMediaVariant.custom,
        title: 'Pessoa offline',
        message: 'Tente novamente mais tarde.',
        content: AppInputGroup(
          placeholder: 'Buscar páginas...',
          leading: AppIcon(AppIcons.search),
        ),
      ),
    );

    expect(find.byType(AppDashedContainer), findsOneWidget);
    expect(find.byType(AppAvatar), findsOneWidget);
    expect(find.byType(AppInputGroup), findsOneWidget);
    expect(find.byIcon(AppIcons.folderDashed), findsNothing);

    await _pumpStateView(
      tester,
      const AppStateView(
        variant: AppStateVariant.empty,
        surface: AppStateSurface.muted,
        showMedia: false,
        title: 'Nenhuma notificação',
      ),
      theme: AppTheme.dark,
    );

    expect(find.byType(AppDashedContainer), findsNothing);
    expect(find.byIcon(AppIcons.folderDashed), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserva o layout compacto com texto a 200%', (tester) async {
    await _pumpStateView(
      tester,
      AppStateView(
        variant: AppStateVariant.error,
        title: 'Não foi possível carregar',
        message: 'Tente novamente; seus dados foram preservados.',
        actionLabel: 'Tentar novamente',
        onAction: () {},
        secondaryActionLabel: 'Voltar ao início',
        onSecondaryAction: () {},
      ),
      width: 320,
      height: 560,
      textScaler: const TextScaler.linear(2),
    );

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('anuncia estados que exigem atenção como região viva', (tester) async {
    await _pumpStateView(
      tester,
      const AppStateView(variant: AppStateVariant.error),
    );

    final liveRegion = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.container && widget.properties.liveRegion == true,
      ),
    );

    expect(liveRegion.properties.liveRegion, isTrue);
  });
}

Future<void> _pumpStateView(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  double width = 800,
  double height = 600,
  TextScaler textScaler = TextScaler.noScaling,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme ?? AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        textScaler: textScaler,
      ),
      child: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    ),
  ),
);
