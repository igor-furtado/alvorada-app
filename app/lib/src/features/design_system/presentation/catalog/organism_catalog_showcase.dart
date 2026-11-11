import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import 'catalog_demo_layout.dart';

class OrganismCatalogShowcase extends StatefulWidget {
  const OrganismCatalogShowcase({super.key});

  @override
  State<OrganismCatalogShowcase> createState() => _OrganismCatalogShowcaseState();
}

class _OrganismCatalogShowcaseState extends State<OrganismCatalogShowcase> {
  DateTime? _calendarDate = DateTime(2026, 11, 10);
  DateTime? _pickerDate;
  String _sidebarValue = 'inicio';

  Color _barrierColor(BuildContext context) => context.tokens.colors.scrim.withValues(
    alpha: context.tokens.opacity.dialogBarrier,
  );

  Future<void> _showAlertDialog({
    required String title,
    required String description,
    required String cancelLabel,
    required String actionLabel,
    AppAlertDialogSize size = AppAlertDialogSize.standard,
    Widget? media,
    bool destructive = false,
  }) => showDialog<void>(
    context: context,
    barrierColor: _barrierColor(context),
    builder: (dialogContext) => AppAlertDialog(
      title: title,
      description: description,
      cancelLabel: cancelLabel,
      actionLabel: actionLabel,
      size: size,
      media: media,
      destructive: destructive,
      onCancel: () => Navigator.pop(dialogContext),
      onAction: () => Navigator.pop(dialogContext),
    ),
  );

  @override
  Widget build(BuildContext context) => CatalogDemoGroup(
    children: [
      CatalogDemoSection(
        title: 'AppAccordion',
        description: 'Seções expansíveis que revelam uma área de conteúdo por vez.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogMedium),
          child: AppAccordion<String>(
            expandedValues: const {'produto'},
            onToggle: (_) {},
            items: const [
              AppAccordionItem<String>(
                value: 'produto',
                title: Text('O produto é acessível?'),
                child: Text('Sim. Ele segue os padrões WAI-ARIA e oferece navegação por teclado.'),
              ),
              AppAccordionItem<String>(
                value: 'estilo',
                title: Text('Posso personalizar o estilo?'),
                child: Text('Sim. Cores, bordas, raios e tipografia são definidos pelos tokens.'),
              ),
              AppAccordionItem<String>(
                value: 'animacao',
                title: Text('A animação respeita preferências do sistema?'),
                child: Text('Sim. O movimento é reduzido quando essa preferência está ativa.'),
              ),
            ],
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppAlertDialog',
        description: 'As cinco composições oficiais para decisões que exigem resposta explícita.',
        child: Wrap(
          spacing: context.tokens.spacing.sm,
          runSpacing: context.tokens.spacing.sm,
          alignment: WrapAlignment.center,
          children: [
            AppButton(
              label: 'Basic',
              variant: AppButtonVariant.outline,
              onPressed: () => _showAlertDialog(
                title: 'Você tem certeza?',
                description:
                    'Esta ação não pode ser desfeita. Ela excluirá permanentemente sua conta e removerá seus dados dos nossos servidores.',
                cancelLabel: 'Cancelar',
                actionLabel: 'Continuar',
              ),
            ),
            AppButton(
              label: 'Small',
              variant: AppButtonVariant.outline,
              onPressed: () => _showAlertDialog(
                title: 'Permitir conexão do acessório?',
                description: 'Deseja permitir que o acessório USB se conecte a este dispositivo?',
                cancelLabel: 'Não permitir',
                actionLabel: 'Permitir',
                size: AppAlertDialogSize.small,
              ),
            ),
            AppButton(
              label: 'Media',
              variant: AppButtonVariant.outline,
              onPressed: () => _showAlertDialog(
                title: 'Compartilhar este projeto?',
                description: 'Qualquer pessoa com o link poderá visualizar e editar este projeto.',
                cancelLabel: 'Cancelar',
                actionLabel: 'Compartilhar',
                media: const Icon(AppIcons.bluetooth),
              ),
            ),
            AppButton(
              label: 'Small com mídia',
              variant: AppButtonVariant.outline,
              onPressed: () => _showAlertDialog(
                title: 'Permitir conexão do acessório?',
                description: 'Deseja permitir que o acessório USB se conecte a este dispositivo?',
                cancelLabel: 'Não permitir',
                actionLabel: 'Permitir',
                size: AppAlertDialogSize.small,
                media: const Icon(AppIcons.bluetooth),
              ),
            ),
            AppButton(
              label: 'Destructive',
              variant: AppButtonVariant.destructive,
              onPressed: () => _showAlertDialog(
                title: 'Excluir conversa?',
                description:
                    'Esta conversa será excluída permanentemente, inclusive as memórias salvas durante a conversa.',
                cancelLabel: 'Cancelar',
                actionLabel: 'Excluir',
                size: AppAlertDialogSize.small,
                media: const Icon(AppIcons.deleteStrong),
                destructive: true,
              ),
            ),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppCalendar',
        description: 'Calendário mensal para seleção de uma única data.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.overviewPanel),
          child: AppCalendar(
            selectedDate: _calendarDate,
            displayedMonth: DateTime(2026, 11),
            onSelected: (date) => setState(() => _calendarDate = date),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppDataTable',
        description: 'Tabela com filtro, colunas configuráveis, seleção, ações e paginação.',
        child: AppDataTable<_CatalogPayment>(
          rows: _catalogPayments,
          selectable: true,
          pageSize: 5,
          filterPlaceholder: 'Filtrar e-mails...',
          filterValueBuilder: (payment) => payment.email,
          rowActionsBuilder: (payment) => [
            AppDataTableAction(
              label: 'Copiar ID do pagamento',
              onPressed: () => Clipboard.setData(ClipboardData(text: payment.id)),
            ),
            AppDataTableAction(
              label: 'Ver cliente',
              separatedBefore: true,
              onPressed: () {},
            ),
            AppDataTableAction(
              label: 'Ver detalhes do pagamento',
              onPressed: () {},
            ),
          ],
          columns: [
            AppTableColumn<_CatalogPayment>(
              label: 'Status',
              cellBuilder: (context, payment) => Text(
                payment.status,
                style: context.tokens.typography.bodySmall,
              ),
            ),
            AppTableColumn<_CatalogPayment>(
              label: 'E-mail',
              flex: 2,
              compare: (left, right) => left.email.compareTo(right.email),
              cellBuilder: (context, payment) => Text(
                payment.email,
                style: context.tokens.typography.bodySmall,
              ),
            ),
            AppTableColumn<_CatalogPayment>(
              label: 'Valor',
              alignment: Alignment.centerRight,
              cellBuilder: (context, payment) => Text(
                '\$${payment.amount.toStringAsFixed(2)}',
                style: context.tokens.typography.labelMedium,
              ),
            ),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppDatePicker',
        description: 'Acionador de data composto com o calendário do design system.',
        child: AppDatePicker(
          value: _pickerDate,
          onChanged: (date) => setState(() => _pickerDate = date),
        ),
      ),
      CatalogDemoSection(
        title: 'AppDialog',
        description: 'Modal com cabeçalho, conteúdo rolável e rodapé de ações.',
        child: AppButton(
          label: 'Abrir dialog',
          variant: AppButtonVariant.outline,
          onPressed: () => showDialog<void>(
            context: context,
            barrierColor: _barrierColor(context),
            builder: (dialogContext) => AppDialog(
              title: 'Editar perfil',
              description: 'Faça suas alterações e salve para continuar.',
              content: const AppFormField(label: 'Nome', placeholder: 'Nome completo'),
              secondaryLabel: 'Cancelar',
              onSecondary: () => Navigator.pop(dialogContext),
              primaryLabel: 'Salvar alterações',
              onPrimary: () => Navigator.pop(dialogContext),
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppDrawer',
        description: 'Painel inferior para conteúdo complementar em contexto compacto.',
        child: AppButton(
          label: 'Abrir drawer',
          variant: AppButtonVariant.outline,
          onPressed: () => showAppDrawer<void>(
            context,
            title: 'Filtros',
            description: 'Refine os resultados exibidos.',
            child: const AppRadioGroup<String>(
              value: 'todos',
              options: [
                AppRadioOption(value: 'todos', label: 'Todos'),
                AppRadioOption(value: 'ativos', label: 'Ativos'),
              ],
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppStateView — padrão',
        description: 'Estado vazio com mídia, explicação, ações e link complementar.',
        child: _StateDemoFrame(
          child: AppStateView(
            variant: AppStateVariant.empty,
            title: 'Nenhum Concurso ainda',
            message: 'Você ainda não criou um Concurso. Comece adicionando o primeiro.',
            actionLabel: 'Criar Concurso',
            onAction: () {},
            secondaryActionLabel: 'Importar Concurso',
            onSecondaryAction: () {},
            footer: AppButton(
              label: 'Saiba mais',
              variant: AppButtonVariant.text,
              onPressed: () {},
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppStateView — contorno',
        description: 'Superfície tracejada para destacar um estado vazio dentro de outra área.',
        child: _StateDemoFrame(
          child: AppStateView(
            variant: AppStateVariant.empty,
            icon: AppIcons.cloud,
            surface: AppStateSurface.outline,
            title: 'Armazenamento vazio',
            message: 'Envie arquivos para acessá-los em qualquer lugar.',
            content: AppButton(
              label: 'Enviar arquivos',
              variant: AppButtonVariant.outline,
              onPressed: () {},
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppStateView — fundo',
        description: 'Fundo suave para separar o estado do restante da superfície.',
        child: _StateDemoFrame(
          child: AppStateView(
            variant: AppStateVariant.empty,
            icon: AppIcons.notification,
            surface: AppStateSurface.muted,
            title: 'Nenhuma notificação',
            message: 'Tudo certo por aqui. Novas notificações aparecerão neste espaço.',
            content: AppButton(
              label: 'Atualizar',
              icon: AppIcons.refresh,
              variant: AppButtonVariant.outline,
              onPressed: () {},
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppStateView — avatar',
        description: 'Mídia livre para representar uma pessoa sem o contêiner de ícone.',
        child: _StateDemoFrame(
          child: AppStateView(
            variant: AppStateVariant.offline,
            media: const AppAvatar(
              initials: 'LM',
              size: AppAvatarSize.lg,
              semanticLabel: 'Lucas Martins',
            ),
            mediaVariant: AppStateMediaVariant.custom,
            title: 'Pessoa offline',
            message: 'Esta pessoa está offline. Deixe uma mensagem ou tente novamente mais tarde.',
            actionLabel: 'Deixar mensagem',
            onAction: () {},
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppStateView — grupo de avatares',
        description: 'Mídia composta para representar pessoas relacionadas ao estado.',
        child: _StateDemoFrame(
          child: AppStateView(
            variant: AppStateVariant.empty,
            media: const _StateAvatarGroup(),
            mediaVariant: AppStateMediaVariant.custom,
            title: 'Nenhuma pessoa na equipe',
            message: 'Convide sua equipe para colaborar neste Concurso.',
            actionLabel: 'Convidar pessoas',
            onAction: () {},
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppStateView — campo de busca',
        description: 'Conteúdo livre para busca, formulários curtos e ajuda contextual.',
        child: _StateDemoFrame(
          child: AppStateView(
            variant: AppStateVariant.error,
            showMedia: false,
            title: '404 — Página não encontrada',
            message: 'A página procurada não existe. Busque abaixo o que você precisa.',
            content: const AppInputGroup(
              placeholder: 'Buscar páginas...',
              leading: AppIcon(AppIcons.search, size: AppIconSize.sm),
              trailing: _KeyboardHint('/'),
            ),
            footer: AppButton(
              label: 'Precisa de ajuda? Fale com o suporte',
              variant: AppButtonVariant.text,
              onPressed: () {},
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppHoverCard',
        description: 'Conteúdo contextual revelado ao manter o ponteiro sobre o acionador.',
        child: AppHoverCard(
          width: context.tokens.sizes.overviewPanel,
          trigger: const _OverlayTrigger(label: 'Passe o ponteiro'),
          content: const Text('Informações complementares sem interromper o fluxo atual.'),
        ),
      ),
      CatalogDemoSection(
        title: 'AppSheet',
        description: 'Painel lateral sobreposto para tarefas auxiliares.',
        child: AppButton(
          label: 'Abrir sheet',
          variant: AppButtonVariant.outline,
          onPressed: () => showAppSheet<void>(
            context,
            title: 'Editar perfil',
            description: 'Atualize os dados e feche o painel ao terminar.',
            child: const AppTextInput(placeholder: 'Nome completo'),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppPopover',
        description: 'Superfície flutuante acionada sem tirar o usuário do contexto.',
        child: AppPopover(
          width: context.tokens.sizes.overviewPanel,
          trigger: const _OverlayTrigger(label: 'Abrir popover'),
          content: const Text('Use esta área para ações e informações compactas.'),
        ),
      ),

      CatalogDemoSection(
        title: 'AppSidebar',
        description: 'Navegação lateral expansível, tematizável e composta por destinos.',
        child: SizedBox(
          height: context.tokens.sizes.reviewAccentHeight,
          child: AppSidebar<String>(
            selectedValue: _sidebarValue,
            onSelected: (value) => setState(() => _sidebarValue = value),
            header: const AppLabel('Navegação', style: AppLabelStyle.control),
            items: const [
              AppSidebarItem(value: 'inicio', label: 'Início', icon: AppIcons.today),
              AppSidebarItem(value: 'agenda', label: 'Agenda', icon: AppIcons.calendar),
              AppSidebarItem(value: 'ajustes', label: 'Ajustes', icon: AppIcons.settings),
            ],
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppTable',
        description: 'Tabela responsiva básica para comparação de dados.',
        child: AppTable<int>(
          rows: const [1, 2, 3],
          columns: [
            AppTableColumn<int>(
              label: 'Disciplina',
              cellBuilder: (context, value) => Text(['Português', 'Direito', 'Lógica'][value - 1]),
            ),
            AppTableColumn<int>(
              label: 'Progresso',
              alignment: Alignment.centerRight,
              cellBuilder: (context, value) => Text('${value * 20}%'),
            ),
          ],
        ),
      ),
      const CatalogDemoSection(
        title: 'AppTabs',
        description: 'Painéis relacionados apresentados um de cada vez.',
        child: AppTabs<String>(
          initialValue: 'visao',
          items: [
            AppTabItem(value: 'visao', label: 'Visão geral', content: Text('Resumo do conteúdo.')),
            AppTabItem(value: 'historico', label: 'Histórico', content: Text('Alterações recentes.')),
          ],
        ),
      ),

      CatalogDemoSection(
        title: 'AppResizable',
        description: 'Painéis aninhados redimensionáveis por ponteiro ou teclado.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
          child: SizedBox(
            height: context.tokens.sizes.overviewPanel,
            child: const AppCard(
              padding: EdgeInsets.zero,
              child: AppResizable(
                first: _ResizablePane(label: 'Um'),
                second: AppResizable(
                  direction: Axis.vertical,
                  initialRatio: .25,
                  first: _ResizablePane(label: 'Dois'),
                  second: _ResizablePane(label: 'Três'),
                ),
              ),
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppScrollArea',
        description: 'Área rolável com barra visível e comportamento nativo preservado.',
        child: SizedBox(
          height: context.tokens.sizes.overviewPanel,
          child: AppScrollArea(
            child: Column(
              children: [
                for (var index = 1; index <= 12; index++)
                  AppListItem(
                    title: 'Item $index',
                    subtitle: 'Conteúdo rolável',
                    leadingIcon: AppIcons.bookText,
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _StateDemoFrame extends StatelessWidget {
  const _StateDemoFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: context.tokens.sizes.guideMaxWidth,
    child: child,
  );
}

class _StateAvatarGroup extends StatelessWidget {
  const _StateAvatarGroup();

  @override
  Widget build(BuildContext context) {
    final avatarSize = context.tokens.sizes.avatarLg;
    final offset = avatarSize - context.tokens.spacing.xs;
    return SizedBox(
      width: avatarSize + (offset * 2),
      height: avatarSize,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            child: AppAvatar(
              initials: 'LM',
              size: AppAvatarSize.lg,
              semanticLabel: 'Lucas Martins',
            ),
          ),
          Positioned(
            left: offset,
            child: const AppAvatar(
              initials: 'AS',
              size: AppAvatarSize.lg,
              semanticLabel: 'Ana Souza',
            ),
          ),
          Positioned(
            left: offset * 2,
            child: const AppAvatar(
              initials: 'RC',
              size: AppAvatarSize.lg,
              semanticLabel: 'Rafael Costa',
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardHint extends StatelessWidget {
  const _KeyboardHint(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: context.tokens.sizes.avatarSm,
    height: context.tokens.sizes.avatarSm,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.tokens.colors.surfaceSubtle,
      borderRadius: context.tokens.borders.xs,
    ),
    child: Text(label, style: context.tokens.typography.labelMedium),
  );
}

class _CatalogPayment {
  const _CatalogPayment({
    required this.id,
    required this.amount,
    required this.status,
    required this.email,
  });

  final String id;
  final double amount;
  final String status;
  final String email;
}

const _catalogPayments = [
  _CatalogPayment(id: 'm5gr84i9', amount: 316, status: 'Sucesso', email: 'ken99@example.com'),
  _CatalogPayment(id: '3u1reuv4', amount: 242, status: 'Sucesso', email: 'abe45@example.com'),
  _CatalogPayment(id: 'derv1ws0', amount: 837, status: 'Processando', email: 'monserrat44@example.com'),
  _CatalogPayment(id: '5kma53ae', amount: 874, status: 'Sucesso', email: 'silas22@example.com'),
  _CatalogPayment(id: 'bhqecj4p', amount: 721, status: 'Falhou', email: 'carmella@example.com'),
  _CatalogPayment(id: 'q1w2e3r4', amount: 128, status: 'Pendente', email: 'maria@example.com'),
  _CatalogPayment(id: 't5y6u7i8', amount: 459, status: 'Sucesso', email: 'joao@example.com'),
];

class _ResizablePane extends StatelessWidget {
  const _ResizablePane({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    color: context.tokens.colors.card,
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: context.tokens.typography.titleSmall,
    ),
  );
}

class _OverlayTrigger extends StatelessWidget {
  const _OverlayTrigger({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.tokens.colors.surface,
      border: Border.all(color: context.tokens.colors.border),
      borderRadius: context.tokens.borders.lg,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.tokens.spacing.lg,
        vertical: context.tokens.spacing.sm,
      ),
      child: Text(label, style: context.tokens.typography.labelLarge),
    ),
  );
}
