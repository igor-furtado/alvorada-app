import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import 'catalog_demo_layout.dart';
import 'field_catalog_demo.dart';
import 'list_item_catalog_demo.dart';

class MoleculeCatalogShowcase extends StatefulWidget {
  const MoleculeCatalogShowcase({super.key});

  @override
  State<MoleculeCatalogShowcase> createState() => _MoleculeCatalogShowcaseState();
}

class _MoleculeCatalogShowcaseState extends State<MoleculeCatalogShowcase> {
  String? _radioValue = 'mensal';
  String? _comboboxValue;
  String? _clearableComboboxValue = 'Next.js';
  List<String> _comboboxValues = const ['Next.js'];
  var _page = 2;

  @override
  Widget build(BuildContext context) => CatalogDemoGroup(
    children: [
      CatalogDemoSection(
        title: 'AppAlert',
        description: 'Mensagem persistente com título, descrição, ícone e ação opcional.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogWide),
          child: Column(
            children: [
              const AppAlert(
                title: 'Pagamento realizado',
                description: r'Seu pagamento de R$ 29,99 foi processado. Enviamos o recibo por e-mail.',
                icon: AppIcons.observation,
              ),
              SizedBox(height: context.tokens.spacing.md),
              const AppAlert(
                title: 'Sua assinatura expira em 3 dias.',
                description:
                    'Renove agora para evitar a interrupção do serviço ou faça upgrade para continuar usando o serviço.',
                icon: AppIcons.attention,
                variant: AppAlertVariant.warning,
              ),
              SizedBox(height: context.tokens.spacing.md),
              const AppAlert(
                title: 'Não foi possível concluir',
                description: 'Revise os campos indicados e tente novamente.',
                icon: AppIcons.attention,
                variant: AppAlertVariant.destructive,
              ),
            ],
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppAttachment',
        description: 'Arquivo com tamanhos, estados do ciclo de envio e ações independentes.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estados', style: context.tokens.typography.titleSmall),
              SizedBox(height: context.tokens.spacing.sm),
              AppAttachment(
                title: 'arquivo-selecionado.pdf',
                description: 'Pronto para enviar',
                state: AppAttachmentState.idle,
                actions: [
                  AppAccessibleIconButton(
                    icon: AppIcons.close,
                    label: 'Remover arquivo-selecionado.pdf',
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: context.tokens.spacing.sm),
              AppAttachment(
                title: 'design-system.zip',
                description: 'Enviando · 64%',
                state: AppAttachmentState.uploading,
                actions: [
                  AppAccessibleIconButton(
                    icon: AppIcons.close,
                    label: 'Cancelar envio de design-system.zip',
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: context.tokens.spacing.sm),
              AppAttachment(
                title: 'pesquisa-de-mercado.pdf',
                description: 'Processando documento',
                state: AppAttachmentState.processing,
                actions: [
                  AppAccessibleIconButton(
                    icon: AppIcons.close,
                    label: 'Remover pesquisa-de-mercado.pdf',
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: context.tokens.spacing.sm),
              AppAttachment(
                title: 'modelo-financeiro.xlsx',
                description: 'Falha no envio. Tente novamente.',
                state: AppAttachmentState.error,
                actions: [
                  AppAccessibleIconButton(
                    icon: AppIcons.refresh,
                    label: 'Tentar enviar modelo-financeiro.xlsx novamente',
                    onPressed: () {},
                  ),
                  AppAccessibleIconButton(
                    icon: AppIcons.close,
                    label: 'Remover modelo-financeiro.xlsx',
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: context.tokens.spacing.sm),
              AppAttachment(
                title: 'relatorio-enviado.pdf',
                description: 'Enviado · 1,8 MB',
                state: AppAttachmentState.done,
                actions: [
                  AppAccessibleIconButton(
                    icon: AppIcons.close,
                    label: 'Remover relatorio-enviado.pdf',
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: context.tokens.spacing.xxl),
              Text('Tamanhos', style: context.tokens.typography.titleSmall),
              SizedBox(height: context.tokens.spacing.md),
              const AppAttachment(
                title: 'Anexo padrão',
                description: 'PDF · 2,4 MB',
                media: AppIcon(AppIcons.fileText, size: AppIconSize.sm),
              ),
              SizedBox(height: context.tokens.spacing.md),
              const AppAttachment(
                title: 'Anexo pequeno',
                description: 'PDF · 2,4 MB',
                media: AppIcon(AppIcons.fileText, size: AppIconSize.sm),
                size: AppAttachmentSize.sm,
              ),
              SizedBox(height: context.tokens.spacing.md),
              const AppAttachment(
                title: 'Anexo extrapequeno',
                media: AppIcon(AppIcons.fileText, size: AppIconSize.sm),
                size: AppAttachmentSize.xs,
              ),
            ],
          ),
        ),
      ),
      const CatalogDemoSection(
        title: 'AppBreadcrumbs',
        description: 'Caminho hierárquico com links anteriores, níveis omitidos e página atual.',
        child: AppBreadcrumbs(
          items: [
            AppBreadcrumbItem(label: 'Início', route: '/'),
            AppBreadcrumbItem.ellipsis(),
            AppBreadcrumbItem(label: 'Componentes', route: '/administracao/componentes'),
            AppBreadcrumbItem(label: 'Breadcrumb'),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppButtonGroup',
        description: 'Ações relacionadas apresentadas como uma unidade visual.',
        child: AppButtonGroup(
          children: [
            AppButton(
              label: 'Anterior',
              icon: AppIcons.chevronLeft,
              variant: AppButtonVariant.outline,
              onPressed: () {},
            ),
            AppButton(
              label: 'Próximo',
              icon: AppIcons.chevronRight,
              variant: AppButtonVariant.outline,
              onPressed: () {},
            ),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppCombobox',
        description: 'Seleção pesquisável com valor simples, múltiplos valores, limpeza e estado desabilitado.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Básico', style: context.tokens.typography.titleSmall),
              SizedBox(height: context.tokens.spacing.sm),
              AppCombobox<String>(
                options: const ['Next.js', 'SvelteKit', 'Nuxt.js', 'Remix', 'Astro'],
                displayStringForOption: (option) => option,
                value: _comboboxValue,
                placeholder: 'Selecione um framework',
                semanticLabel: 'Framework',
                onChanged: (value) => setState(() => _comboboxValue = value),
              ),
              SizedBox(height: context.tokens.spacing.xxl),
              Text('Múltiplo', style: context.tokens.typography.titleSmall),
              SizedBox(height: context.tokens.spacing.sm),
              AppCombobox<String>.multiple(
                options: const ['Next.js', 'SvelteKit', 'Nuxt.js', 'Remix', 'Astro'],
                displayStringForOption: (option) => option,
                values: _comboboxValues,
                placeholder: 'Selecione frameworks',
                semanticLabel: 'Frameworks',
                showClear: true,
                onValuesChanged: (values) => setState(() => _comboboxValues = values),
              ),
              SizedBox(height: context.tokens.spacing.xxl),
              Text('Botão de limpar', style: context.tokens.typography.titleSmall),
              SizedBox(height: context.tokens.spacing.sm),
              AppCombobox<String>(
                options: const ['Next.js', 'SvelteKit', 'Nuxt.js', 'Remix', 'Astro'],
                displayStringForOption: (option) => option,
                value: _clearableComboboxValue,
                placeholder: 'Selecione um framework',
                semanticLabel: 'Framework com limpeza',
                showClear: true,
                onChanged: (value) => setState(() => _clearableComboboxValue = value),
              ),
              SizedBox(height: context.tokens.spacing.xxl),
              Text('Desabilitado', style: context.tokens.typography.titleSmall),
              SizedBox(height: context.tokens.spacing.sm),
              AppCombobox<String>(
                options: const ['Next.js', 'SvelteKit', 'Nuxt.js', 'Remix', 'Astro'],
                displayStringForOption: (option) => option,
                placeholder: 'Selecione um framework',
                semanticLabel: 'Framework desabilitado',
                disabled: true,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
      const CatalogDemoSection(
        title: 'AppField',
        description: 'Composição acessível de rótulo, descrição, erro, controle e agrupamentos de formulário.',
        child: FieldCatalogDemo(),
      ),
      CatalogDemoSection(
        title: 'AppInputGroup',
        description: 'Entrada composta com complementos antes e depois do campo.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
          child: AppInputGroup(
            placeholder: 'Buscar...',
            leading: const Icon(AppIcons.search),
            trailing: Padding(
              padding: EdgeInsets.all(context.tokens.spacing.sm),
              child: const AppBadge(label: '12 resultados'),
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppToast',
        description: 'Mensagem transitória anunciada com ação opcional.',
        child: AppButton(
          label: 'Mostrar toast',
          variant: AppButtonVariant.outline,
          onPressed: () {
            AppToast.show(
              context,
              title: 'Criando evento',
              description: 'Domingo, 3 de dezembro, às 9h',
              variant: AppToastVariant.error,
            );
          },
        ),
      ),
      const CatalogDemoSection(
        title: 'AppListItem',
        description: 'Conteúdo composto com variantes, tamanhos, mídia, cabeçalho, agrupamento, link e dropdown.',
        child: ListItemCatalogDemo(),
      ),
      CatalogDemoSection(
        title: 'AppPagination',
        description: 'Navegação entre páginas com anterior, próxima e página atual.',
        child: AppPagination(
          currentPage: _page,
          totalPages: 8,
          onPageChanged: (page) => setState(() => _page = page),
        ),
      ),
      CatalogDemoSection(
        title: 'AppRadioGroup',
        description: 'Escolha única com opções associadas a um mesmo grupo acessível.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
          child: AppField(
            label: 'Plano de assinatura',
            description: 'Os planos anual e vitalício oferecem economia significativa.',
            control: AppRadioGroup<String>(
              value: _radioValue,
              options: const [
                AppRadioOption(value: 'mensal', label: r'Mensal (R$ 9,99/mês)'),
                AppRadioOption(value: 'anual', label: r'Anual (R$ 99,99/ano)'),
                AppRadioOption(value: 'vitalicio', label: r'Vitalício (R$ 299,99)'),
              ],
              onChanged: (value) => setState(() => _radioValue = value),
            ),
          ),
        ),
      ),
    ],
  );
}
