import 'dart:io';

import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget subject(Widget child) => MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );

  test('não depende do pacote shadcn_ui', () {
    expect(File('pubspec.yaml').readAsStringSync(), isNot(contains('shadcn_ui')));
    expect(File('pubspec.lock').readAsStringSync(), isNot(contains('shadcn_ui')));
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      expect(file.readAsStringSync(), isNot(contains('package:shadcn_ui')), reason: file.path);
    }
  });

  test('registra a lista completa de componentes aprovada', () {
    expect(
      AppComponentRegistry.components.map((component) => component.name),
      [
        'Accordion',
        'Alert',
        'Alert Dialog',
        'Attachment',
        'Avatar',
        'Badge',
        'Breadcrumb',
        'Button',
        'Button Group',
        'Calendar',
        'Card',
        'Checkbox',
        'Combobox',
        'Data Table',
        'Date Picker',
        'Dialog',
        'Drawer',
        'Empty',
        'Field',
        'Hover Card',
        'Input',
        'Input Group',
        'Separator',
        'Sheet',
        'Sidebar',
        'Skeleton',
        'Spinner',
        'Switch',
        'Table',
        'Tabs',
        'Textarea',
        'Toast',
        'Item',
        'Label',
        'Pagination',
        'Popover',
        'Progress',
        'Radio Group',
        'Resizable',
        'Scroll Area',
        'Select',
      ],
    );
  });

  testWidgets('componentes de conteúdo usam a interface própria', (tester) async {
    await tester.pumpWidget(
      subject(
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppAlert(title: 'Aviso', description: 'Descrição do aviso.'),
              const AppAttachment(title: 'edital.pdf', description: 'PDF · 2 MB'),
              const AppProgress(value: .5),
              const AppTextarea(placeholder: 'Observação'),
              AppSelect<String>(
                placeholder: 'Selecione',
                options: const [AppSelectOption(value: 'a', label: 'Opção A')],
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppAlert), findsOneWidget);
    expect(find.byType(AppAttachment), findsOneWidget);
    expect(find.byType(AppProgress), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(AppSelect<String>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('select abre overlay compacto com todas as opções', (tester) async {
    String? selected;
    await tester.pumpWidget(
      subject(
        SizedBox(
          width: 320,
          child: AppSelect<String>(
            placeholder: 'Escolha um departamento',
            options: const [
              AppSelectOption(value: 'engenharia', label: 'Engenharia'),
              AppSelectOption(value: 'design', label: 'Design'),
              AppSelectOption(value: 'marketing', label: 'Marketing'),
            ],
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Escolha um departamento'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha um departamento'), findsNWidgets(2));
    expect(find.text('Engenharia'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Marketing'), findsOneWidget);

    await tester.tap(find.text('Design'));
    await tester.pumpAndSettle();
    expect(selected, 'design');
    expect(find.text('Design'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('select fecha o overlay quando fica desabilitado', (tester) async {
    var enabled = true;
    late StateSetter setHostState;
    await tester.pumpWidget(
      subject(
        StatefulBuilder(
          builder: (context, setState) {
            setHostState = setState;
            return AppSelect<String>(
              placeholder: 'Escolha uma opção',
              options: const [AppSelectOption(value: 'a', label: 'Opção A')],
              onChanged: enabled ? (_) {} : null,
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Escolha uma opção'));
    await tester.pumpAndSettle();
    expect(find.text('Opção A'), findsOneWidget);

    setHostState(() => enabled = false);
    await tester.pumpAndSettle();
    expect(find.text('Opção A'), findsNothing);
  });

  testWidgets('popover abre e fecha pelo teclado', (tester) async {
    await tester.pumpWidget(
      subject(
        const AppPopover(
          trigger: Text('Abrir detalhes'),
          content: Text('Detalhes adicionais'),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Detalhes adicionais'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Detalhes adicionais'), findsNothing);
  });

  testWidgets('grupo de rádio muda a seleção com as setas', (tester) async {
    var value = 'primeira';
    await tester.pumpWidget(
      subject(
        StatefulBuilder(
          builder: (context, setState) => AppRadioGroup<String>(
            value: value,
            options: const [
              AppRadioOption(value: 'primeira', label: 'Primeira'),
              AppRadioOption(value: 'segunda', label: 'Segunda'),
            ],
            onChanged: (next) => setState(() => value = next!),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(value, 'segunda');
  });

  testWidgets('anexo representa estados e tamanhos do ciclo de envio', (tester) async {
    await tester.pumpWidget(
      subject(
        const SizedBox(
          width: 384,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppAttachment(
                key: ValueKey('idle'),
                title: 'selecionado.pdf',
                description: 'Pronto para enviar',
                state: AppAttachmentState.idle,
              ),
              AppAttachment(
                key: ValueKey('uploading'),
                title: 'enviando.zip',
                description: 'Enviando · 64%',
                state: AppAttachmentState.uploading,
                size: AppAttachmentSize.sm,
              ),
              AppAttachment(
                key: ValueKey('error'),
                title: 'falhou.xlsx',
                description: 'Falha no envio. Tente novamente.',
                state: AppAttachmentState.error,
                size: AppAttachmentSize.xs,
              ),
            ],
          ),
        ),
      ),
    );

    final media = find.byKey(const ValueKey('app-attachment-media'));
    final idle = find.byKey(const ValueKey('idle'));
    final error = find.byKey(const ValueKey('error'));
    final errorSurface = find.descendant(
      of: error,
      matching: find.byKey(const ValueKey('app-attachment-surface')),
    );
    final material = tester.widget<Material>(errorSurface);
    final shape = material.shape! as RoundedRectangleBorder;

    expect(tester.getSize(media.at(0)).height, 40);
    expect(tester.getSize(media.at(1)).height, 32);
    expect(tester.getSize(media.at(2)).height, 28);
    expect(find.descendant(of: idle, matching: find.byType(CustomPaint)), findsWidgets);
    expect(
      find.descendant(of: find.byKey(const ValueKey('uploading')), matching: find.byType(AppSpinner)),
      findsOneWidget,
    );
    expect(shape.side.color, AppTokens.light().colors.error.withValues(alpha: .30));
    expect(find.text('Falha no envio. Tente novamente.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('item compõe variantes, tamanhos, mídia, cabeçalho e agrupamento', (tester) async {
    await tester.pumpWidget(
      subject(
        const SizedBox(
          width: 420,
          child: AppListItemGroup(
            children: [
              AppListItem(
                key: ValueKey('plain-item'),
                title: 'Item padrão',
                subtitle: 'Sem borda visível',
              ),
              AppListItem(
                key: ValueKey('outline-item'),
                title: 'Item com contorno',
                subtitle: 'Com mídia e cabeçalho',
                variant: AppListItemVariant.outline,
                media: AppListItemMedia.image(
                  ColoredBox(color: Colors.black),
                  semanticLabel: 'Capa do item',
                ),
                header: AppListItemHeader(
                  height: 80,
                  child: ColoredBox(color: Colors.black),
                ),
              ),
              AppListItem(
                key: ValueKey('muted-item'),
                title: 'Item suave',
                subtitle: 'Tamanho extrapequeno',
                variant: AppListItemVariant.muted,
                size: AppListItemSize.xs,
              ),
            ],
          ),
        ),
      ),
    );

    BoxDecoration decorationOf(Key key) {
      final surface = find.descendant(
        of: find.byKey(key),
        matching: find.byKey(const ValueKey('app-list-item-surface')),
      );
      return tester.widget<AnimatedContainer>(surface).decoration! as BoxDecoration;
    }

    final tokens = AppTokens.light();
    expect(decorationOf(const ValueKey('plain-item')).color, tokens.colors.transparent);
    expect(decorationOf(const ValueKey('outline-item')).border!.top.color, tokens.colors.border);
    expect(decorationOf(const ValueKey('muted-item')).color, tokens.colors.surfaceSubtle);
    expect(tester.getSize(find.byKey(const ValueKey('muted-item'))).height, lessThan(60));
    expect(tester.getSize(find.byKey(const ValueKey('app-list-item-media'))).width, tokens.sizes.identityIcon);
    expect(find.byType(AppListItemHeader), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('breadcrumb representa níveis omitidos e página atual', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      subject(
        AppBreadcrumbs(
          items: [
            const AppBreadcrumbItem(label: 'Início', route: '/'),
            AppBreadcrumbItem.ellipsis(onPressed: () => opened = true),
            const AppBreadcrumbItem(label: 'Componentes', route: '/componentes'),
            const AppBreadcrumbItem(label: 'Breadcrumb'),
          ],
        ),
      ),
    );

    expect(find.byIcon(AppIcons.more), findsOneWidget);
    expect(find.byIcon(AppIcons.chevronRight), findsNWidgets(3));
    expect(find.text('Breadcrumb'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.more));
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendário seleciona uma data', (tester) async {
    DateTime? selected;
    await tester.pumpWidget(
      subject(
        AppCalendar(
          displayedMonth: DateTime(2026, 11),
          onSelected: (date) => selected = date,
        ),
      ),
    );

    await tester.tap(find.text('10'));
    expect(selected, DateTime(2026, 11, 10));
  });

  testWidgets('calendário limita o mês inicial ao intervalo futuro', (tester) async {
    await tester.pumpWidget(
      subject(
        AppCalendar(
          firstDate: DateTime(2100, 3, 10),
          onSelected: (_) {},
        ),
      ),
    );

    expect(find.text('mar.'), findsOneWidget);
    expect(find.text('2100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendário mostra dias externos e permite selecionar mês e ano', (tester) async {
    DateTime? selected;
    DateTime? displayedMonth;
    await tester.pumpWidget(
      subject(
        SizedBox(
          width: 240,
          child: AppCalendar(
            displayedMonth: DateTime(2026, 11),
            firstDate: DateTime(2025),
            lastDate: DateTime(2027, 12, 31),
            onSelected: (date) => selected = date,
            onMonthChanged: (month) => displayedMonth = month,
          ),
        ),
      ),
    );

    final firstDecember = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == '1/12/2026',
    );
    expect(firstDecember, findsOneWidget);
    await tester.tap(firstDecember);
    await tester.pump();
    expect(selected, DateTime(2026, 12, 1));
    expect(displayedMonth, DateTime(2026, 12));

    await tester.tap(find.text('dez.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('nov.').last);
    await tester.pumpAndSettle();
    expect(displayedMonth, DateTime(2026, 11));

    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2025').last);
    await tester.pumpAndSettle();
    expect(displayedMonth, DateTime(2025, 11));
  });

  testWidgets('tabela de dados ordena pela coluna', (tester) async {
    await tester.pumpWidget(
      subject(
        AppDataTable<int>(
          rows: const [2, 1],
          columns: [
            AppTableColumn<int>(
              label: 'Número',
              compare: (left, right) => left.compareTo(right),
              cellBuilder: (context, value) => Text('$value'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Número'));
    await tester.pump();
    final values = tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).toList();
    expect(values.indexOf('1'), lessThan(values.indexOf('2')));
  });

  testWidgets('tabela de dados filtra, seleciona, configura colunas e abre ações', (tester) async {
    const rows = [
      (email: 'ana@example.com', status: 'Sucesso'),
      (email: 'bia@example.com', status: 'Pendente'),
    ];

    await tester.pumpWidget(
      subject(
        AppDataTable<({String email, String status})>(
          rows: rows,
          selectable: true,
          filterPlaceholder: 'Filtrar e-mails...',
          filterValueBuilder: (row) => row.email,
          rowActionsBuilder: (row) => [
            AppDataTableAction(label: 'Copiar ID', onPressed: () {}),
          ],
          columns: [
            AppTableColumn<({String email, String status})>(
              label: 'Status',
              cellBuilder: (context, row) => Text(row.status),
            ),
            AppTableColumn<({String email, String status})>(
              label: 'E-mail',
              compare: (left, right) => left.email.compareTo(right.email),
              cellBuilder: (context, row) => Text(row.email),
            ),
          ],
        ),
      ),
    );

    expect(find.text('0 de 2 linha(s) selecionada(s).'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Selecionar linha').first);
    await tester.pump();
    expect(find.text('1 de 2 linha(s) selecionada(s).'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.more).first);
    await tester.pumpAndSettle();
    expect(find.text('Copiar ID'), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Colunas'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckedPopupMenuItem<int>, 'Status'));
    await tester.pumpAndSettle();
    expect(find.text('Status'), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'não-existe');
    await tester.pump();
    expect(find.text('Nenhum resultado.'), findsOneWidget);
    expect(find.text('0 de 0 linha(s) selecionada(s).'), findsOneWidget);
  });
}
