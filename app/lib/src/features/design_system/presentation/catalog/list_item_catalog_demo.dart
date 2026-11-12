import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';

class ListItemCatalogDemo extends StatelessWidget {
  const ListItemCatalogDemo({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogWide),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DemoBlock(
          title: 'Básico',
          child: AppListItemGroup(
            children: [
              AppListItem(
                title: 'Item básico',
                subtitle: 'Um item simples com título e descrição.',
                variant: AppListItemVariant.outline,
                trailing: AppButton(
                  label: 'Ação',
                  variant: AppButtonVariant.outline,
                  onPressed: () {},
                ),
              ),
              AppListItem(
                title: 'Seu perfil foi verificado.',
                media: const AppListItemMedia.icon(AppIcons.check),
                variant: AppListItemVariant.outline,
                trailing: const AppIcon(AppIcons.chevronRight),
                onTap: () {},
              ),
            ],
          ),
        ),
        const _DemoBlock(
          title: 'Variantes',
          child: AppListItemGroup(
            children: [
              AppListItem(
                title: 'Variante padrão',
                subtitle: 'Fundo transparente e sem borda visível.',
                media: AppListItemMedia.icon(AppIcons.book),
              ),
              AppListItem(
                title: 'Variante com contorno',
                subtitle: 'Superfície com uma borda visível.',
                media: AppListItemMedia.icon(AppIcons.book),
                variant: AppListItemVariant.outline,
              ),
              AppListItem(
                title: 'Variante suave',
                subtitle: 'Fundo semântico para conteúdo secundário.',
                media: AppListItemMedia.icon(AppIcons.book),
                variant: AppListItemVariant.muted,
              ),
              AppListItem(
                title: 'Variante primária',
                subtitle: 'Destaque para o item selecionado.',
                media: AppListItemMedia.icon(AppIcons.book),
                variant: AppListItemVariant.primary,
                selected: true,
              ),
            ],
          ),
        ),
        const _DemoBlock(
          title: 'Tamanhos',
          child: AppListItemGroup(
            children: [
              AppListItem(
                title: 'Tamanho padrão',
                subtitle: 'O tamanho recomendado para a maioria dos casos.',
                media: AppListItemMedia.icon(AppIcons.book),
                variant: AppListItemVariant.outline,
              ),
              AppListItem(
                title: 'Tamanho pequeno',
                subtitle: 'Uma opção compacta para layouts densos.',
                media: AppListItemMedia.icon(AppIcons.book),
                variant: AppListItemVariant.outline,
                size: AppListItemSize.sm,
              ),
              AppListItem(
                title: 'Tamanho extrapequeno',
                subtitle: 'A opção mais compacta disponível.',
                media: AppListItemMedia.icon(AppIcons.book, size: AppIconSize.sm),
                variant: AppListItemVariant.outline,
                size: AppListItemSize.xs,
              ),
            ],
          ),
        ),
        _DemoBlock(
          title: 'Ícone',
          child: AppListItem(
            title: 'Alerta de segurança',
            subtitle: 'Um novo acesso foi detectado em um dispositivo desconhecido.',
            media: const AppListItemMedia.icon(AppIcons.attention),
            variant: AppListItemVariant.outline,
            trailing: AppButton(
              label: 'Revisar',
              variant: AppButtonVariant.outline,
              onPressed: () {},
            ),
          ),
        ),
        _DemoBlock(
          title: 'Avatar',
          child: AppListItemGroup(
            children: [
              AppListItem(
                title: 'Ana Ribeiro',
                subtitle: 'Vista pela última vez há 5 meses',
                media: const AppListItemMedia.avatar(
                  AppAvatar(initials: 'AR', size: AppAvatarSize.lg),
                  semanticLabel: 'Ana Ribeiro',
                ),
                variant: AppListItemVariant.outline,
                trailing: AppAccessibleIconButton(
                  icon: AppIcons.add,
                  label: 'Adicionar Ana Ribeiro',
                  onPressed: () {},
                ),
              ),
              AppListItem(
                title: 'Nenhum membro na equipe',
                subtitle: 'Convide sua equipe para colaborar neste projeto.',
                media: const AppListItemMedia.avatar(
                  _AvatarStack(),
                  semanticLabel: 'Três integrantes',
                ),
                variant: AppListItemVariant.outline,
                trailing: AppButton(
                  label: 'Convidar',
                  variant: AppButtonVariant.outline,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        const _DemoBlock(
          title: 'Imagem',
          child: AppListItemGroup(
            children: [
              AppListItem(
                title: 'Luzes da cidade — Noites elétricas',
                subtitle: 'Sonhos de neon',
                media: AppListItemMedia.image(_ItemArtwork(seed: 0), semanticLabel: 'Capa cinza escura'),
                trailing: Text('3:45'),
                variant: AppListItemVariant.outline,
              ),
              AppListItem(
                title: 'Conversas no café — Histórias urbanas',
                subtitle: 'O café da manhã',
                media: AppListItemMedia.image(_ItemArtwork(seed: 1), semanticLabel: 'Capa cinza'),
                trailing: Text('4:05'),
                variant: AppListItemVariant.outline,
              ),
              AppListItem(
                title: 'Chuva digital — Batidas binárias',
                subtitle: 'Sinfonia cibernética',
                media: AppListItemMedia.image(_ItemArtwork(seed: 2), semanticLabel: 'Capa em degradê'),
                trailing: Text('3:30'),
                variant: AppListItemVariant.outline,
              ),
            ],
          ),
        ),
        _DemoBlock(
          title: 'Grupo',
          child: AppListItemGroup(
            children: [
              _memberItem('Shadcn', 'shadcn@exemplo.com', 'SH'),
              _memberItem('Max Leiter', 'maxleiter@exemplo.com', 'ML'),
              _memberItem('Evil Rabbit', 'evilrabbit@exemplo.com', 'ER'),
            ],
          ),
        ),
        const _DemoBlock(
          title: 'Cabeçalho',
          child: _HeaderItems(),
        ),
        _DemoBlock(
          title: 'Link',
          child: AppListItemGroup(
            children: [
              AppListItem(
                title: 'Visite nossa documentação',
                subtitle: 'Aprenda como começar a usar nossos componentes.',
                role: AppListItemRole.link,
                trailing: const AppIcon(AppIcons.chevronRight),
                onTap: () {},
              ),
              AppListItem(
                title: 'Recurso externo',
                subtitle: 'Abre em uma nova aba com atributos de segurança.',
                role: AppListItemRole.link,
                variant: AppListItemVariant.outline,
                trailing: const AppIcon(AppIcons.arrowRight),
                onTap: () {},
              ),
            ],
          ),
        ),
        const _DemoBlock(title: 'Dropdown', child: _ItemDropdown()),
      ],
    ),
  );

  static AppListItem _memberItem(String title, String subtitle, String initials) => AppListItem(
    title: title,
    subtitle: subtitle,
    media: AppListItemMedia.avatar(
      AppAvatar(initials: initials, size: AppAvatarSize.lg),
      semanticLabel: title,
    ),
    variant: AppListItemVariant.outline,
    trailing: AppAccessibleIconButton(
      icon: AppIcons.add,
      label: 'Adicionar $title',
      onPressed: () {},
    ),
  );
}

class _DemoBlock extends StatelessWidget {
  const _DemoBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: context.tokens.spacing.xxxl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.tokens.typography.titleMedium),
        SizedBox(height: context.tokens.spacing.lg),
        child,
      ],
    ),
  );
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: context.tokens.sizes.avatarLg,
    height: context.tokens.sizes.avatarLg,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          left: 0,
          child: AppAvatar(initials: 'A', size: AppAvatarSize.lg),
        ),
        Positioned(
          left: context.tokens.spacing.lg,
          child: const AppAvatar(initials: 'B', size: AppAvatarSize.lg),
        ),
      ],
    ),
  );
}

class _ItemArtwork extends StatelessWidget {
  const _ItemArtwork({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final colors = [
      context.tokens.colors.onSurface,
      context.tokens.colors.onSurfaceMuted,
      context.tokens.colors.border,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[seed % colors.length], context.tokens.colors.surfaceSubtle],
        ),
      ),
    );
  }
}

class _HeaderItems extends StatelessWidget {
  const _HeaderItems();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= context.tokens.layout.narrow ? 3 : 1;
      final gap = context.tokens.spacing.md;
      final width = columns == 1 ? constraints.maxWidth : (constraints.maxWidth - gap * 2) / 3;
      final items = [
        ('Modelo compacto', 'Tarefas diárias e geração de interface.', 0),
        ('Modelo avançado', 'Pensamento avançado e raciocínio.', 1),
        ('Modelo aberto', 'Uma opção aberta para todas as pessoas.', 2),
      ];
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final item in items)
            SizedBox(
              width: width,
              child: AppListItem(
                title: item.$1,
                subtitle: item.$2,
                variant: AppListItemVariant.outline,
                header: AppListItemHeader(
                  height: context.tokens.sizes.compactField,
                  child: _ItemArtwork(seed: item.$3),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _ItemDropdown extends StatelessWidget {
  const _ItemDropdown();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.center,
    child: AppPopover(
      width: context.tokens.sizes.dialogNarrow / 2,
      trigger: DecoratedBox(
        decoration: BoxDecoration(
          color: context.tokens.colors.surfaceSubtle,
          border: Border.all(color: context.tokens.colors.border),
          borderRadius: context.tokens.borders.lg,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.tokens.spacing.lg,
            vertical: context.tokens.spacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selecionar', style: context.tokens.typography.labelLarge),
              SizedBox(width: context.tokens.spacing.sm),
              const AppIcon(AppIcons.expandMore, size: AppIconSize.sm),
            ],
          ),
        ),
      ),
      content: AppListItemGroup(
        spacing: 0,
        children: [
          AppListItem(
            title: 'Shadcn',
            subtitle: 'shadcn@exemplo.com',
            media: const AppListItemMedia.avatar(AppAvatar(initials: 'SH')),
            size: AppListItemSize.xs,
            onTap: () {},
          ),
          AppListItem(
            title: 'Max Leiter',
            subtitle: 'maxleiter@exemplo.com',
            media: const AppListItemMedia.avatar(AppAvatar(initials: 'ML')),
            size: AppListItemSize.xs,
            onTap: () {},
          ),
          AppListItem(
            title: 'Evil Rabbit',
            subtitle: 'evilrabbit@exemplo.com',
            media: const AppListItemMedia.avatar(AppAvatar(initials: 'ER')),
            size: AppListItemSize.xs,
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}
