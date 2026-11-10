import 'package:estudos_app/src/core/content/app_messages.dart';
import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget subject(Widget child) => MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('AppButton usa composição própria e executa a ação', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      subject(
        AppButton(
          label: 'Continuar',
          variant: AppButtonVariant.outline,
          onPressed: () => taps++,
        ),
      ),
    );

    expect(find.byType(InkWell), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    expect(taps, 1);
  });

  testWidgets('AppButton desabilita a ação durante carregamento', (tester) async {
    await tester.pumpWidget(
      subject(
        AppButton(label: 'Salvar', loading: true, onPressed: () {}),
      ),
    );

    final button = tester.widget<InkWell>(find.byType(InkWell));
    expect(button.onTap, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppButton preserva AppButtonSize na escala shadcn', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              key: const ValueKey('button-sm'),
              label: 'Pequeno',
              size: AppButtonSize.sm,
              onPressed: () {},
            ),
            AppButton(
              key: const ValueKey('button-md'),
              label: 'Médio',
              size: AppButtonSize.md,
              onPressed: () {},
            ),
            AppButton(
              key: const ValueKey('button-lg'),
              label: 'Grande',
              size: AppButtonSize.lg,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey('button-sm'))).height, 28);
    expect(tester.getSize(find.byKey(const ValueKey('button-md'))).height, 32);
    expect(tester.getSize(find.byKey(const ValueKey('button-lg'))).height, 36);
  });

  testWidgets('AppMetricOverview apresenta os dados recebidos', (tester) async {
    await tester.pumpWidget(
      subject(
        const AppMetricOverview(
          items: [
            AppMetricData(icon: AppIcons.statistics, value: '24', label: 'Registros ativos'),
          ],
        ),
      ),
    );

    expect(find.text('24'), findsOneWidget);
    expect(find.text('Registros ativos'), findsOneWidget);
  });

  testWidgets('AppAccordion informa e apresenta a expansão', (
    tester,
  ) async {
    String? toggled;
    await tester.pumpWidget(
      subject(
        AppAccordion<String>(
          expandedValues: const {},
          onToggle: (value) => toggled = value,
          items: const [
            AppAccordionItem<String>(
              value: 'edital',
              title: Text('Edital'),
              child: Text('Conteúdo do Edital'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Conteúdo do Edital'), findsNothing);
    await tester.tap(find.text('Edital'));
    await tester.pumpAndSettle();

    expect(toggled, 'edital');
    expect(find.text('Conteúdo do Edital'), findsOneWidget);

    final title = tester.renderObject<RenderParagraph>(find.text('Edital'));
    final content = tester.renderObject<RenderParagraph>(find.text('Conteúdo do Edital'));
    expect(title.text.style?.fontSize, 14);
    expect(title.text.style?.fontWeight, FontWeight.w500);
    expect(content.text.style?.fontSize, 14);
    expect(content.text.style?.fontWeight, FontWeight.w400);
    expect(tester.getTopLeft(find.text('Edital')).dx, tester.getTopLeft(find.text('Conteúdo do Edital')).dx);
  });

  testWidgets('AppTabs troca o conteúdo', (tester) async {
    await tester.pumpWidget(
      subject(
        const AppTabs<String>(
          initialValue: 'estrutura',
          items: [
            AppTabItem(
              value: 'estrutura',
              label: 'Estrutura',
              content: Text('Conteúdo estrutural'),
            ),
            AppTabItem(
              value: 'historico',
              label: 'Histórico',
              content: Text('Conteúdo histórico'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Conteúdo estrutural'), findsOneWidget);
    expect(find.text('Conteúdo histórico'), findsNothing);

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Conteúdo histórico'), findsOneWidget);
  });

  testWidgets('AppFormField expõe label, ajuda e entrada', (tester) async {
    await tester.pumpWidget(
      subject(
        const AppFormField(
          label: 'Disciplina',
          placeholder: 'Nome da disciplina',
          helperText: 'Use o nome do edital.',
        ),
      ),
    );

    expect(find.text('Disciplina'), findsOneWidget);
    expect(find.text('Nome da disciplina'), findsOneWidget);
    expect(find.text('Use o nome do edital.'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('AppDialog usa composição própria com cabeçalho e rodapé', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        Builder(
          builder: (context) => AppButton(
            label: 'Abrir',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AppDialog(
                title: 'Editar perfil',
                description: 'Faça suas alterações.',
                content: const Text('Conteúdo do formulário'),
                secondaryLabel: 'Cancelar',
                onSecondary: () => Navigator.pop(context),
                primaryLabel: 'Salvar alterações',
                onPrimary: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Faça suas alterações.'), findsOneWidget);
    expect(find.text('Conteúdo do formulário'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Salvar alterações'), findsOneWidget);

    await tester.tap(find.byTooltip(AppMessages.close));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('AppAlertDialog padrão é independente do AppDialog', (tester) async {
    await tester.pumpWidget(
      subject(
        Builder(
          builder: (context) => AppButton(
            label: 'Abrir alerta',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AppAlertDialog(
                title: 'Você tem certeza?',
                description: 'Esta ação não pode ser desfeita.',
                cancelLabel: 'Cancelar',
                actionLabel: 'Continuar',
                onCancel: () => Navigator.pop(dialogContext),
                onAction: () => Navigator.pop(dialogContext),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir alerta'));
    await tester.pumpAndSettle();

    final surface = find.byKey(const ValueKey('app-alert-dialog-surface'));
    final footer = find.byKey(const ValueKey('app-alert-dialog-footer'));
    final buttons = tester.widgetList<AppButton>(
      find.descendant(of: footer, matching: find.byType(AppButton)),
    );
    final title = tester.renderObject<RenderParagraph>(find.text('Você tem certeza?'));

    expect(find.byType(AppDialog), findsNothing);
    expect(tester.getSize(surface).width, 384);
    expect(title.text.style?.fontSize, 16);
    expect(title.text.style?.fontWeight, FontWeight.w600);
    expect(buttons.map((button) => button.variant), [
      AppButtonVariant.outline,
      AppButtonVariant.primary,
    ]);
  });

  testWidgets('AppAlertDialog pequeno centraliza mídia e expande ações destrutivas', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        Builder(
          builder: (context) => AppButton(
            label: 'Excluir conversa',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AppAlertDialog(
                title: 'Excluir conversa?',
                description: 'A conversa será excluída permanentemente.',
                cancelLabel: 'Cancelar',
                actionLabel: 'Excluir',
                size: AppAlertDialogSize.small,
                media: const Icon(AppIcons.deleteStrong),
                destructive: true,
                onCancel: () => Navigator.pop(dialogContext),
                onAction: () => Navigator.pop(dialogContext),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Excluir conversa'));
    await tester.pumpAndSettle();

    final surface = find.byKey(const ValueKey('app-alert-dialog-surface'));
    final footer = find.byKey(const ValueKey('app-alert-dialog-footer'));
    final buttonFinder = find.descendant(of: footer, matching: find.byType(AppButton));
    final buttons = tester.widgetList<AppButton>(buttonFinder).toList();
    final title = tester.widget<Text>(find.text('Excluir conversa?'));

    expect(tester.getSize(surface).width, 320);
    expect(title.textAlign, TextAlign.center);
    expect(tester.getCenter(find.byIcon(AppIcons.deleteStrong)).dx, tester.getCenter(surface).dx);
    expect(buttons.map((button) => button.variant), [
      AppButtonVariant.outline,
      AppButtonVariant.destructive,
    ]);
    expect(tester.getSize(buttonFinder.at(0)).width, tester.getSize(buttonFinder.at(1)).width);
  });

  testWidgets('seletores usam a gramática visual do projeto', (tester) async {
    await tester.pumpWidget(
      subject(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCheckbox(value: false, semanticLabel: 'Selecionar tópico'),
            AppSwitch(value: true, semanticLabel: 'Ativar lembrete'),
          ],
        ),
      ),
    );

    expect(find.byType(AppCheckbox), findsOneWidget);
    expect(find.byType(AppSwitch), findsOneWidget);
  });

  testWidgets('AppField compõe controles e agrupamentos sem acoplar o input', (tester) async {
    await tester.pumpWidget(
      subject(
        const AppFieldset(
          legend: 'Preferências',
          description: 'Escolha como deseja receber novidades.',
          child: AppFieldGroup(
            children: [
              AppField(
                label: 'E-mail',
                description: 'Usaremos seu endereço principal.',
                control: AppTextInput(placeholder: 'voce@exemplo.com'),
              ),
              AppField(
                label: 'Autenticação multifator',
                orientation: AppFieldOrientation.horizontal,
                control: AppSwitch(value: false, semanticLabel: 'Autenticação multifator'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Preferências'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.byType(AppTextInput), findsOneWidget);
    expect(find.byType(AppSwitch), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppInfiniteListView apresenta itens e encerra a paginação', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            height: AppTokens.light().sizes.overviewPanel,
            child: AppInfiniteListView<int>(
              loadPage: (_) async => const AppInfinitePage(items: [1, 2]),
              itemBuilder: (context, item, index) => Text('Item $item'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text(AppMessages.noMoreResults), findsOneWidget);
  });
}
