import 'package:flutter/material.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import 'catalog/atom_catalog_showcase.dart';
import 'catalog/molecule_catalog_showcase.dart';
import 'catalog/organism_catalog_showcase.dart';

class ComponentCatalogPage extends StatefulWidget {
  const ComponentCatalogPage({super.key});

  @override
  State<ComponentCatalogPage> createState() => _ComponentCatalogPageState();
}

class _ComponentCatalogPageState extends State<ComponentCatalogPage> {
  @override
  Widget build(BuildContext context) => AppPageTemplate(
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppBreadcrumbs(
          items: [
            AppBreadcrumbItem(
              label: AppMessages.administration,
              route: '/administracao',
            ),
            AppBreadcrumbItem(label: AppMessages.componentCatalog),
          ],
        ),
        SizedBox(height: context.tokens.spacing.lg),
        Wrap(
          spacing: context.tokens.spacing.lg,
          runSpacing: context.tokens.spacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              AppMessages.componentCatalog,
              style: context.tokens.typography.headlineMedium,
            ),
            AppBadge(
              label: '${AppComponentRegistry.components.length} componentes',
              variant: AppBadgeVariant.secondary,
            ),
          ],
        ),
        SizedBox(height: context.tokens.spacing.sm),
        Text(
          AppMessages.componentCatalogSubtitle,
          style: context.tokens.typography.bodyLarge.copyWith(
            color: context.tokens.colors.onSurfaceMuted,
          ),
        ),
        SizedBox(height: context.tokens.spacing.xxl),
        AppTabs<String>(
          initialValue: 'tokens',
          items: [
            AppTabItem<String>(
              value: 'tokens',
              label: 'Tokens',
              content: _buildTokens(context),
            ),
            const AppTabItem<String>(
              value: 'atomos',
              label: 'Átomos',
              content: AtomCatalogShowcase(),
            ),
            const AppTabItem<String>(
              value: 'moleculas',
              label: 'Moléculas',
              content: MoleculeCatalogShowcase(),
            ),
            const AppTabItem<String>(
              value: 'organismos',
              label: 'Organismos',
              content: OrganismCatalogShowcase(),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildTokens(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    return _CatalogGroup(
      children: [
        _CatalogSection(
          title: 'Cores semânticas',
          description: 'Todos os papéis de cor resolvidos para o tema atual.',
          child: Wrap(
            spacing: tokens.spacing.md,
            runSpacing: tokens.spacing.md,
            children: [
              _ColorTokenTile(name: 'canvas', color: colors.canvas),
              _ColorTokenTile(name: 'surface', color: colors.surface),
              _ColorTokenTile(name: 'card', color: colors.card),
              _ColorTokenTile(name: 'popover', color: colors.popover),
              _ColorTokenTile(name: 'surfaceSubtle', color: colors.surfaceSubtle),
              _ColorTokenTile(name: 'onSurface', color: colors.onSurface),
              _ColorTokenTile(name: 'onSurfaceMuted', color: colors.onSurfaceMuted),
              _ColorTokenTile(name: 'border', color: colors.border),
              _ColorTokenTile(name: 'controlOutline', color: colors.controlOutline),
              _ColorTokenTile(name: 'focusRing', color: colors.focusRing),
              _ColorTokenTile(name: 'primary', color: colors.primary),
              _ColorTokenTile(name: 'actionForeground', color: colors.actionForeground),
              _ColorTokenTile(name: 'onPrimary', color: colors.onPrimary),
              _ColorTokenTile(name: 'primaryContainer', color: colors.primaryContainer),
              _ColorTokenTile(name: 'onPrimaryContainer', color: colors.onPrimaryContainer),
              _ColorTokenTile(name: 'success', color: colors.success),
              _ColorTokenTile(name: 'onSuccess', color: colors.onSuccess),
              _ColorTokenTile(name: 'successContainer', color: colors.successContainer),
              _ColorTokenTile(name: 'error', color: colors.error),
              _ColorTokenTile(name: 'errorForeground', color: colors.errorForeground),
              _ColorTokenTile(name: 'onError', color: colors.onError),
              _ColorTokenTile(name: 'errorContainer', color: colors.errorContainer),
              _ColorTokenTile(name: 'info', color: colors.info),
              _ColorTokenTile(name: 'onInfo', color: colors.onInfo),
              _ColorTokenTile(name: 'infoContainer', color: colors.infoContainer),
              _ColorTokenTile(name: 'warning', color: colors.warning),
              _ColorTokenTile(name: 'warningContainer', color: colors.warningContainer),
              _ColorTokenTile(name: 'warningBorder', color: colors.warningBorder),
              _ColorTokenTile(name: 'restContainer', color: colors.restContainer),
              _ColorTokenTile(name: 'memorizeContainer', color: colors.memorizeContainer),
              _ColorTokenTile(name: 'attentionContainer', color: colors.attentionContainer),
              _ColorTokenTile(name: 'observationContainer', color: colors.observationContainer),
              _ColorTokenTile(name: 'transparent', color: colors.transparent),
              _ColorTokenTile(name: 'shadow', color: colors.shadow),
              _ColorTokenTile(name: 'scrim', color: colors.scrim),
            ],
          ),
        ),
        _CatalogSection(
          title: 'Tipografia',
          description: 'Escala Geist usada para criar hierarquia sem depender de cor.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypographyTokenSample(name: 'displayLarge', style: tokens.typography.displayLarge),
              _TypographyTokenSample(name: 'displayMedium', style: tokens.typography.displayMedium),
              _TypographyTokenSample(name: 'headlineLarge', style: tokens.typography.headlineLarge),
              _TypographyTokenSample(name: 'headlineMedium', style: tokens.typography.headlineMedium),
              _TypographyTokenSample(name: 'headlineSmall', style: tokens.typography.headlineSmall),
              _TypographyTokenSample(name: 'titleLarge', style: tokens.typography.titleLarge),
              _TypographyTokenSample(name: 'titleMedium', style: tokens.typography.titleMedium),
              _TypographyTokenSample(name: 'titleSmall', style: tokens.typography.titleSmall),
              _TypographyTokenSample(name: 'bodyLarge', style: tokens.typography.bodyLarge),
              _TypographyTokenSample(name: 'bodyMedium', style: tokens.typography.bodyMedium),
              _TypographyTokenSample(name: 'bodySmall', style: tokens.typography.bodySmall),
              _TypographyTokenSample(name: 'labelLarge', style: tokens.typography.labelLarge),
              _TypographyTokenSample(name: 'labelMedium', style: tokens.typography.labelMedium),
              _TypographyTokenSample(name: 'labelSmall', style: tokens.typography.labelSmall),
              _TypographyTokenSample(name: 'button', style: tokens.typography.button),
            ],
          ),
        ),
        _CatalogSection(
          title: 'Espaçamento',
          description: 'Escala completa aplicada a componentes e composições.',
          child: _TokenValueList(
            values: [
              _TokenValue(name: 'none', value: _dimension(tokens.spacing.none)),
              _TokenValue(name: 'hairline', value: _dimension(tokens.spacing.hairline)),
              _TokenValue(name: 'xxxs', value: _dimension(tokens.spacing.xxxs)),
              _TokenValue(name: 'xxs', value: _dimension(tokens.spacing.xxs)),
              _TokenValue(name: 'xs', value: _dimension(tokens.spacing.xs)),
              _TokenValue(name: 'sm', value: _dimension(tokens.spacing.sm)),
              _TokenValue(name: 'md', value: _dimension(tokens.spacing.md)),
              _TokenValue(name: 'lg', value: _dimension(tokens.spacing.lg)),
              _TokenValue(name: 'xl', value: _dimension(tokens.spacing.xl)),
              _TokenValue(name: 'xxl', value: _dimension(tokens.spacing.xxl)),
              _TokenValue(name: 'xxxl', value: _dimension(tokens.spacing.xxxl)),
              _TokenValue(name: 'huge', value: _dimension(tokens.spacing.huge)),
              _TokenValue(name: 'giant', value: _dimension(tokens.spacing.giant)),
              _TokenValue(name: 'jumbo', value: _dimension(tokens.spacing.jumbo)),
              _TokenValue(name: 'page', value: _dimension(tokens.spacing.page)),
            ],
          ),
        ),
        _CatalogSection(
          title: 'Bordas',
          description: 'Larguras e raios usados por controles e superfícies.',
          child: _TokenValueList(
            values: [
              _TokenValue(name: 'widthHairline', value: _dimension(tokens.borders.widthHairline)),
              _TokenValue(name: 'widthEmphasis', value: _dimension(tokens.borders.widthEmphasis)),
              _TokenValue(name: 'widthStrong', value: _dimension(tokens.borders.widthStrong)),
              _TokenValue(name: 'radiusXs', value: _dimension(tokens.borders.radiusXs)),
              _TokenValue(name: 'radiusSm', value: _dimension(tokens.borders.radiusSm)),
              _TokenValue(name: 'radiusMd', value: _dimension(tokens.borders.radiusMd)),
              _TokenValue(name: 'radiusLg', value: _dimension(tokens.borders.radiusLg)),
              _TokenValue(name: 'radiusXl', value: _dimension(tokens.borders.radiusXl)),
              _TokenValue(name: 'radius2xl', value: _dimension(tokens.borders.radius2xl)),
              _TokenValue(name: 'radius3xl', value: _dimension(tokens.borders.radius3xl)),
              _TokenValue(name: 'radiusFull', value: _dimension(tokens.borders.radiusFull)),
            ],
          ),
        ),
        _CatalogSection(
          title: 'Sombra de overlay',
          description: 'Sombra semântica exclusiva de superfícies flutuantes; não representa profundidade.',
          child: _TokenValueList(
            values: [
              _TokenValue(name: 'overlay', value: _shadowDescription(tokens.shadows.overlay)),
            ],
          ),
        ),
        _CatalogSection(
          title: 'Movimento',
          description: 'Durações e curvas usadas nas transições do produto.',
          child: _TokenValueList(
            values: [
              _TokenValue(name: 'fast', value: '${tokens.motion.fast.inMilliseconds} ms'),
              _TokenValue(name: 'medium', value: '${tokens.motion.medium.inMilliseconds} ms'),
              _TokenValue(name: 'slow', value: '${tokens.motion.slow.inMilliseconds} ms'),
              _TokenValue(name: 'drawer', value: '${tokens.motion.drawer.inMilliseconds} ms'),
              _TokenValue(name: 'standard', value: tokens.motion.standard.toString()),
              _TokenValue(name: 'enter', value: tokens.motion.enter.toString()),
              _TokenValue(name: 'exit', value: tokens.motion.exit.toString()),
              _TokenValue(name: 'drawerEnter', value: tokens.motion.drawerEnter.toString()),
            ],
          ),
        ),
        _CatalogSection(
          title: 'Layout',
          description: 'Breakpoints e dimensões estruturais completas.',
          child: _TokenValueList(
            values: [
              _TokenValue(name: 'compact', value: _dimension(tokens.layout.compact)),
              _TokenValue(name: 'medium', value: _dimension(tokens.layout.medium)),
              _TokenValue(name: 'expanded', value: _dimension(tokens.layout.expanded)),
              _TokenValue(name: 'wide', value: _dimension(tokens.layout.wide)),
              _TokenValue(name: 'contentMaxWidth', value: _dimension(tokens.layout.contentMaxWidth)),
              _TokenValue(name: 'dialogMaxWidth', value: _dimension(tokens.layout.dialogMaxWidth)),
              _TokenValue(
                name: 'drawerSideFraction',
                value: _percentage(tokens.layout.drawerSideFraction),
              ),
              _TokenValue(
                name: 'alertDialogSmallMaxWidth',
                value: _dimension(tokens.layout.alertDialogSmallMaxWidth),
              ),
              _TokenValue(name: 'iconRailWidth', value: _dimension(tokens.layout.iconRailWidth)),
              _TokenValue(name: 'commandBarHeight', value: _dimension(tokens.layout.commandBarHeight)),
              _TokenValue(name: 'commandSearchWidth', value: _dimension(tokens.layout.commandSearchWidth)),
              _TokenValue(name: 'catalogMasterWidth', value: _dimension(tokens.layout.catalogMasterWidth)),
              _TokenValue(
                name: 'catalogWorkspaceHeight',
                value: _dimension(tokens.layout.catalogWorkspaceHeight),
              ),
              _TokenValue(name: 'brandWidth', value: _dimension(tokens.layout.brandWidth)),
              _TokenValue(name: 'controlHeight', value: _dimension(tokens.layout.controlHeight)),
              _TokenValue(
                name: 'topicSelectionIndent',
                value: _dimension(tokens.layout.topicSelectionIndent),
              ),
              _TokenValue(
                name: 'tableActionsColumn',
                value: _dimension(tokens.layout.tableActionsColumn),
              ),
              _TokenValue(name: 'narrow', value: _dimension(tokens.layout.narrow)),
              _TokenValue(name: 'toolbar', value: _dimension(tokens.layout.toolbar)),
              _TokenValue(name: 'twoColumn', value: _dimension(tokens.layout.twoColumn)),
              _TokenValue(name: 'header', value: _dimension(tokens.layout.header)),
              _TokenValue(name: 'reading', value: _dimension(tokens.layout.reading)),
              _TokenValue(name: 'detail', value: _dimension(tokens.layout.detail)),
              _TokenValue(name: 'contentSplit', value: _dimension(tokens.layout.contentSplit)),
              _TokenValue(name: 'threeColumn', value: _dimension(tokens.layout.threeColumn)),
              _TokenValue(
                name: 'infiniteScrollExtent',
                value: _dimension(tokens.layout.infiniteScrollExtent),
              ),
              _TokenValue(
                name: 'timelineRailCompact',
                value: _dimension(tokens.layout.timelineRailCompact),
              ),
              _TokenValue(
                name: 'timelineRailExpanded',
                value: _dimension(tokens.layout.timelineRailExpanded),
              ),
              _TokenValue(
                name: 'timelineGapCompact',
                value: _dimension(tokens.layout.timelineGapCompact),
              ),
              _TokenValue(
                name: 'timelineGapExpanded',
                value: _dimension(tokens.layout.timelineGapExpanded),
              ),
              _TokenValue(
                name: 'sundayContentOffset',
                value: _dimension(tokens.layout.sundayContentOffset),
              ),
            ],
          ),
        ),
        _CatalogSection(
          title: 'Ícones',
          description: 'Escala completa da iconografia Lucide.',
          child: _TokenValueList(
            values: [
              _TokenValue(name: 'sm', value: _dimension(tokens.icons.sm)),
              _TokenValue(name: 'md', value: _dimension(tokens.icons.md)),
              _TokenValue(name: 'lg', value: _dimension(tokens.icons.lg)),
              _TokenValue(name: 'xl', value: _dimension(tokens.icons.xl)),
              _TokenValue(name: 'hero', value: _dimension(tokens.icons.hero)),
            ],
          ),
        ),
        _CatalogSection(
          title: 'Opacidade',
          description: 'Valores completos para estados e sobreposições.',
          child: _TokenValueList(
            values: [
              _TokenValue(name: 'disabled', value: _percentage(tokens.opacity.disabled)),
              _TokenValue(name: 'selectionFaint', value: _percentage(tokens.opacity.selectionFaint)),
              _TokenValue(name: 'selection', value: _percentage(tokens.opacity.selection)),
              _TokenValue(name: 'subtle', value: _percentage(tokens.opacity.subtle)),
              _TokenValue(name: 'half', value: _percentage(tokens.opacity.half)),
              _TokenValue(name: 'muted', value: _percentage(tokens.opacity.muted)),
              _TokenValue(name: 'border', value: _percentage(tokens.opacity.border)),
              _TokenValue(name: 'hint', value: _percentage(tokens.opacity.hint)),
              _TokenValue(name: 'tint', value: _percentage(tokens.opacity.tint)),
              _TokenValue(name: 'tintStrong', value: _percentage(tokens.opacity.tintStrong)),
              _TokenValue(name: 'dialogBarrier', value: _percentage(tokens.opacity.dialogBarrier)),
              _TokenValue(name: 'drawerBarrier', value: _percentage(tokens.opacity.drawerBarrier)),
            ],
          ),
        ),
        _CatalogSection(
          title: 'Tamanhos semânticos',
          description: 'Dimensões completas de componentes que não representam espaçamento.',
          child: _TokenValueList(
            values: [
              _TokenValue(name: 'hairline', value: _dimension(tokens.sizes.hairline)),
              _TokenValue(name: 'progressLine', value: _dimension(tokens.sizes.progressLine)),
              _TokenValue(name: 'accentBar', value: _dimension(tokens.sizes.accentBar)),
              _TokenValue(
                name: 'dialogBackdropBlur',
                value: _dimension(tokens.sizes.dialogBackdropBlur),
              ),
              _TokenValue(
                name: 'progressIndicatorThin',
                value: _dimension(tokens.sizes.progressIndicatorThin),
              ),
              _TokenValue(
                name: 'progressIndicatorRegular',
                value: _dimension(tokens.sizes.progressIndicatorRegular),
              ),
              _TokenValue(name: 'dotSm', value: _dimension(tokens.sizes.dotSm)),
              _TokenValue(name: 'dotMd', value: _dimension(tokens.sizes.dotMd)),
              _TokenValue(name: 'dotLg', value: _dimension(tokens.sizes.dotLg)),
              _TokenValue(name: 'stepIndicator', value: _dimension(tokens.sizes.stepIndicator)),
              _TokenValue(name: 'avatarSm', value: _dimension(tokens.sizes.avatarSm)),
              _TokenValue(name: 'avatarMd', value: _dimension(tokens.sizes.avatarMd)),
              _TokenValue(name: 'avatarLg', value: _dimension(tokens.sizes.avatarLg)),
              _TokenValue(name: 'rowIcon', value: _dimension(tokens.sizes.rowIcon)),
              _TokenValue(name: 'iconContainerSm', value: _dimension(tokens.sizes.iconContainerSm)),
              _TokenValue(name: 'iconContainerMd', value: _dimension(tokens.sizes.iconContainerMd)),
              _TokenValue(name: 'identityIcon', value: _dimension(tokens.sizes.identityIcon)),
              _TokenValue(
                name: 'rowDividerHeight',
                value: _dimension(tokens.sizes.rowDividerHeight),
              ),
              _TokenValue(name: 'iconContainerLg', value: _dimension(tokens.sizes.iconContainerLg)),
              _TokenValue(name: 'largeVisual', value: _dimension(tokens.sizes.largeVisual)),
              _TokenValue(
                name: 'drawerHandleLength',
                value: _dimension(tokens.sizes.drawerHandleLength),
              ),
              _TokenValue(name: 'weightColumn', value: _dimension(tokens.sizes.weightColumn)),
              _TokenValue(name: 'progressColumn', value: _dimension(tokens.sizes.progressColumn)),
              _TokenValue(name: 'compactField', value: _dimension(tokens.sizes.compactField)),
              _TokenValue(name: 'navigationBrand', value: _dimension(tokens.sizes.navigationBrand)),
              _TokenValue(name: 'summaryPanel', value: _dimension(tokens.sizes.summaryPanel)),
              _TokenValue(name: 'overviewPanel', value: _dimension(tokens.sizes.overviewPanel)),
              _TokenValue(
                name: 'listItemHeaderHeight',
                value: _dimension(tokens.sizes.listItemHeaderHeight),
              ),
              _TokenValue(name: 'guideMaxWidth', value: _dimension(tokens.sizes.guideMaxWidth)),
              _TokenValue(name: 'noteMaxWidth', value: _dimension(tokens.sizes.noteMaxWidth)),
              _TokenValue(name: 'dialogNarrow', value: _dimension(tokens.sizes.dialogNarrow)),
              _TokenValue(name: 'dialogMedium', value: _dimension(tokens.sizes.dialogMedium)),
              _TokenValue(name: 'dialogWide', value: _dimension(tokens.sizes.dialogWide)),
              _TokenValue(name: 'detailsTable', value: _dimension(tokens.sizes.detailsTable)),
              _TokenValue(name: 'disciplineTable', value: _dimension(tokens.sizes.disciplineTable)),
              _TokenValue(name: 'disciplinePage', value: _dimension(tokens.sizes.disciplinePage)),
              _TokenValue(
                name: 'concursosPage',
                value: _dimension(tokens.sizes.concursosPage),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorTokenTile extends StatelessWidget {
  const _ColorTokenTile({
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: context.tokens.sizes.navigationBrand,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: context.tokens.colors.surface,
      border: Border.all(color: context.tokens.colors.border),
      borderRadius: context.tokens.borders.md,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: context.tokens.sizes.largeVisual,
          color: color,
        ),
        Padding(
          padding: EdgeInsets.all(context.tokens.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.tokens.typography.labelMedium),
              SizedBox(height: context.tokens.spacing.xxs),
              Text(
                _colorHex(color),
                style: context.tokens.typography.bodySmall.copyWith(
                  color: context.tokens.colors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TypographyTokenSample extends StatelessWidget {
  const _TypographyTokenSample({required this.name, required this.style});

  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: context.tokens.spacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: context.tokens.typography.labelSmall.copyWith(
            color: context.tokens.colors.onSurfaceMuted,
          ),
        ),
        SizedBox(height: context.tokens.spacing.xs),
        Text('Estudo no rumo certo.', style: style),
        SizedBox(height: context.tokens.spacing.xxs),
        Text(
          _textStyleDescription(style),
          style: context.tokens.typography.bodySmall.copyWith(
            color: context.tokens.colors.onSurfaceMuted,
          ),
        ),
      ],
    ),
  );
}

@immutable
class _TokenValue {
  const _TokenValue({required this.name, required this.value});

  final String name;
  final String value;
}

class _TokenValueList extends StatelessWidget {
  const _TokenValueList({required this.values});

  final List<_TokenValue> values;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.tokens.colors.surfaceSubtle,
      border: Border.all(color: context.tokens.colors.border),
      borderRadius: context.tokens.borders.md,
    ),
    child: Column(
      children: [
        for (var index = 0; index < values.length; index++) ...[
          Padding(
            padding: EdgeInsets.all(context.tokens.spacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    values[index].name,
                    style: context.tokens.typography.labelMedium,
                  ),
                ),
                SizedBox(width: context.tokens.spacing.lg),
                Flexible(
                  child: Text(
                    values[index].value,
                    textAlign: TextAlign.end,
                    style: context.tokens.typography.bodySmall.copyWith(
                      color: context.tokens.colors.onSurfaceMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (index != values.length - 1) const AppDivider(margin: EdgeInsets.zero),
        ],
      ],
    ),
  );
}

String _colorHex(Color color) => '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

String _dimension(double value) => '${_number(value)} dp';

String _percentage(double value) => '${_number(value * 100)}%';

String _number(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

String _textStyleDescription(TextStyle style) {
  final family = style.fontFamily ?? 'família herdada';
  final size = style.fontSize == null ? 'tamanho herdado' : '${_number(style.fontSize!)} px';
  final weight = style.fontWeight == null ? 'peso herdado' : 'peso ${style.fontWeight!.value}';
  final height = style.height == null ? 'altura herdada' : 'altura ${_number(style.height!)}';
  final tracking = style.letterSpacing == null ? 'tracking herdado' : 'tracking ${_number(style.letterSpacing!)}';
  return '$family · $size · $weight · $height · $tracking';
}

String _shadowDescription(List<BoxShadow> shadows) {
  if (shadows.isEmpty) return 'sem sombra';
  return shadows
      .map(
        (shadow) =>
            'blur ${_number(shadow.blurRadius)} · '
            'offset ${_number(shadow.offset.dx)}/${_number(shadow.offset.dy)} · '
            'cor ${_colorHex(shadow.color)}',
      )
      .join(' + ');
}

class _CatalogGroup extends StatelessWidget {
  const _CatalogGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: context.tokens.spacing.xl),
    child: Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) SizedBox(height: context.tokens.spacing.lg),
        ],
      ],
    ),
  );
}

class _CatalogSection extends StatelessWidget {
  const _CatalogSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.tokens.typography.titleMedium),
        SizedBox(height: context.tokens.spacing.xs),
        Text(
          description,
          style: context.tokens.typography.bodySmall.copyWith(
            color: context.tokens.colors.onSurfaceMuted,
          ),
        ),
        SizedBox(height: context.tokens.spacing.xl),
        child,
      ],
    ),
  );
}
