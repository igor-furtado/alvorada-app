import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import 'catalog_demo_layout.dart';

class AtomCatalogShowcase extends StatefulWidget {
  const AtomCatalogShowcase({super.key});

  @override
  State<AtomCatalogShowcase> createState() => _AtomCatalogShowcaseState();
}

class _AtomCatalogShowcaseState extends State<AtomCatalogShowcase> {
  var _checked = true;
  var _switchEnabled = false;

  @override
  Widget build(BuildContext context) => CatalogDemoGroup(
    children: [
      CatalogDemoSection(
        title: 'AppAvatar',
        description: 'Imagem, iniciais ou ícone com fallback e três tamanhos.',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppAvatar(initials: 'CN', semanticLabel: 'CN'),
            SizedBox(width: context.tokens.spacing.md),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const AppAvatar(initials: 'ER', semanticLabel: 'ER'),
                Positioned(
                  right: -context.tokens.spacing.hairline,
                  bottom: -context.tokens.spacing.hairline,
                  child: Container(
                    width: context.tokens.spacing.md,
                    height: context.tokens.spacing.md,
                    decoration: BoxDecoration(
                      color: context.tokens.colors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.tokens.colors.surface,
                        width: context.tokens.borders.widthStrong,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: context.tokens.spacing.xl),
            const _AvatarGroup(),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppBadge',
        description: 'Estados curtos em variantes semânticas.',
        child: Wrap(
          spacing: context.tokens.spacing.sm,
          runSpacing: context.tokens.spacing.sm,
          children: const [
            AppBadge(label: 'Badge'),
            AppBadge(label: 'Secondary', variant: AppBadgeVariant.secondary),
            AppBadge(label: 'Destructive', variant: AppBadgeVariant.destructive),
            AppBadge(label: 'Outline', variant: AppBadgeVariant.outline),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppButton',
        description: 'Hierarquia de ações, tamanhos e estados.',
        child: Wrap(
          spacing: context.tokens.spacing.sm,
          runSpacing: context.tokens.spacing.sm,
          children: [
            AppButton(label: 'Button', variant: AppButtonVariant.secondary, onPressed: () {}),
            AppAccessibleIconButton(
              icon: AppIcons.sortAscending,
              label: 'Mover para cima',
              onPressed: () {},
            ),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppCard',
        description: 'Superfície semântica plana, delimitada por borda e raio.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Acesse sua conta', style: context.tokens.typography.titleMedium)),
                    AppButton(label: 'Criar conta', variant: AppButtonVariant.text, onPressed: () {}),
                  ],
                ),
                Text(
                  'Digite seu e-mail abaixo para entrar na sua conta',
                  style: context.tokens.typography.bodySmall,
                ),
                SizedBox(height: context.tokens.spacing.lg),
                const AppField(
                  label: 'E-mail',
                  control: AppTextInput(placeholder: 'm@exemplo.com', semanticLabel: 'E-mail'),
                ),
                SizedBox(height: context.tokens.spacing.md),
                const AppField(
                  label: 'Senha',
                  control: AppTextInput(obscureText: true, semanticLabel: 'Senha'),
                ),
                SizedBox(height: context.tokens.spacing.lg),
                AppButton(label: 'Entrar', onPressed: () {}),
                SizedBox(height: context.tokens.spacing.sm),
                AppButton(label: 'Entrar com Google', variant: AppButtonVariant.outline, onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppCheckbox',
        description: 'Seleção booleana com área de toque acessível e estado selecionado explícito.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
          child: AppField(
            label: 'Sincronizar pastas Área de Trabalho e Documentos',
            description: 'As pastas serão sincronizadas e poderão ser acessadas em outros dispositivos.',
            orientation: AppFieldOrientation.horizontal,
            controlPlacement: AppFieldControlPlacement.leading,
            control: AppCheckbox(
              value: _checked,
              semanticLabel: 'Sincronizar pastas Área de Trabalho e Documentos',
              onChanged: (value) => setState(() => _checked = value ?? false),
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppTextInput',
        description: 'Entrada de uma linha com placeholder, ícones e estado de erro.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppField(
                label: 'Nome de usuário',
                description: 'Escolha um nome de usuário exclusivo para sua conta.',
                control: AppTextInput(placeholder: 'Max Leiter', semanticLabel: 'Nome de usuário'),
              ),
              SizedBox(height: context.tokens.spacing.lg),
              const AppField(
                label: 'Senha',
                description: 'Deve ter pelo menos 8 caracteres.',
                descriptionPlacement: AppFieldDescriptionPlacement.beforeControl,
                control: AppTextInput(
                  placeholder: '••••••••',
                  semanticLabel: 'Senha',
                  obscureText: true,
                ),
              ),
            ],
          ),
        ),
      ),
      const CatalogDemoSection(
        title: 'AppDivider',
        description: 'Separador horizontal ou vertical com borda semântica.',
        child: Column(
          children: [
            Text('shadcn/ui'),
            Text('A base do seu Design System'),
            AppDivider(),
            Text('Um conjunto de componentes bem projetados que você pode personalizar e estender.'),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppSkeleton',
        description: 'Placeholder estrutural para carregamento inicial.',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSkeleton(
              width: context.tokens.sizes.avatarLg,
              height: context.tokens.sizes.avatarLg,
              semanticLabel: 'Carregando perfil',
            ),
            SizedBox(width: context.tokens.spacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: context.tokens.sizes.overviewPanel, height: context.tokens.spacing.lg),
                SizedBox(height: context.tokens.spacing.sm),
                AppSkeleton(width: context.tokens.sizes.summaryPanel, height: context.tokens.spacing.lg),
              ],
            ),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppSpinner',
        description: 'Indicador para operações curtas sem progresso mensurável.',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppSpinner(size: AppLoadingSize.sm),
            SizedBox(width: context.tokens.spacing.md),
            const Text('Processando pagamento...'),
            SizedBox(width: context.tokens.spacing.huge),
            const Text(r'R$ 100,00'),
          ],
        ),
      ),
      CatalogDemoSection(
        title: 'AppSwitch',
        description: 'Alternância imediata entre ligado e desligado.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
          child: AppField(
            label: 'Autenticação multifator',
            orientation: AppFieldOrientation.horizontal,
            control: AppSwitch(
              value: _switchEnabled,
              semanticLabel: 'Autenticação multifator',
              onChanged: (value) => setState(() => _switchEnabled = value),
            ),
          ),
        ),
      ),
      CatalogDemoSection(
        title: 'AppTextarea',
        description: 'Entrada de texto multilinha com altura controlada.',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
          child: const AppField(
            label: 'Feedback',
            description: 'Compartilhe sua opinião sobre o serviço.',
            control: AppTextarea(
              placeholder: 'Seu feedback nos ajuda a melhorar...',
              semanticLabel: 'Feedback',
            ),
          ),
        ),
      ),
      const CatalogDemoSection(
        title: 'AppLabel',
        description: 'Rótulos de corpo, controle e apoio.',
        child: _LabeledAtomControl(
          label: 'Aceitar termos e condições',
          control: AppCheckbox(value: false, semanticLabel: 'Aceitar termos e condições'),
        ),
      ),
      CatalogDemoSection(
        title: 'AppProgress',
        description: 'Progresso determinado com variantes semânticas e valor anunciado.',
        child: Column(
          children: [
            const AppProgress(value: .13, semanticLabel: 'Progresso da tarefa'),
            SizedBox(height: context.tokens.spacing.sm),
            const AppProgress(
              value: .42,
              semanticLabel: 'Avanço informativo',
              variant: AppProgressVariant.info,
            ),
            SizedBox(height: context.tokens.spacing.sm),
            const AppProgress(
              value: .71,
              semanticLabel: 'Desempenho positivo',
              variant: AppProgressVariant.success,
            ),
          ],
        ),
      ),
    ],
  );
}

class _AvatarGroup extends StatelessWidget {
  const _AvatarGroup();

  @override
  Widget build(BuildContext context) {
    final offset = context.tokens.sizes.avatarMd - context.tokens.spacing.sm;
    return SizedBox(
      width: context.tokens.sizes.avatarMd + (offset * 3),
      height: context.tokens.sizes.avatarMd,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            child: AppAvatar(initials: 'CN', semanticLabel: 'CN'),
          ),
          Positioned(
            left: offset,
            child: const AppAvatar(initials: 'LF', semanticLabel: 'LF'),
          ),
          Positioned(
            left: offset * 2,
            child: const AppAvatar(initials: 'EF', semanticLabel: 'EF'),
          ),
          Positioned(
            left: offset * 3,
            child: const AppAvatar(initials: '+3', semanticLabel: 'Mais três pessoas'),
          ),
        ],
      ),
    );
  }
}

class _LabeledAtomControl extends StatelessWidget {
  const _LabeledAtomControl({required this.label, required this.control});

  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      control,
      SizedBox(width: context.tokens.spacing.xs),
      Text(label, style: context.tokens.typography.bodyMedium),
    ],
  );
}
