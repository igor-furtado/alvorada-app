import 'package:material_ui/material_ui.dart';

import '../app_tokens.dart';
import '../feedback/app_badge.dart';
import '../layout/app_responsive.dart';
import 'app_icon.dart';

const _trailingReflowWidth = 360.0;

enum AppListItemVariant { plain, primary }

enum AppListItemSize { standard, sm }

enum _AppListItemStyle { plain, muted, primary }

class _AppListItemIcon extends StatelessWidget {
  const _AppListItemIcon(this.icon, {required this.size, required this.color});

  final IconData icon;
  final AppIconSize size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    key: const ValueKey('app-list-item-media'),
    dimension: context.tokens.icons.lg,
    child: ClipRRect(
      borderRadius: context.tokens.borders.sm,
      child: Center(
        child: AppIcon(icon, size: size, color: color),
      ),
    ),
  );
}

/// Mantém uma sequência de itens com o mesmo ritmo vertical.
class AppListItemGroup extends StatelessWidget {
  const AppListItemGroup({required this.children, this.spacing, super.key});

  final List<Widget> children;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? context.tokens.spacing.sm;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index < children.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

/// Conteúdo composto com mídia, título, descrição, cabeçalho e ação.
class AppListItem extends StatefulWidget {
  const AppListItem({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.media,
    this.header,
    this.trailing,
    this.badge,
    this.onTap,
    this.selected = false,
    this.variant = AppListItemVariant.plain,
    this.size = AppListItemSize.standard,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? media;
  final Widget? header;
  final Widget? trailing;
  final String? badge;
  final VoidCallback? onTap;
  final bool selected;
  final AppListItemVariant variant;
  final AppListItemSize size;
  final String? semanticLabel;

  @override
  State<AppListItem> createState() => _AppListItemState();
}

class _AppListItemState extends State<AppListItem> {
  var _hovered = false;
  var _focused = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final interactive = widget.onTap != null;
    final style = switch ((widget.variant, widget.selected)) {
      (AppListItemVariant.primary, _) => _AppListItemStyle.primary,
      (AppListItemVariant.plain, true) => _AppListItemStyle.muted,
      (AppListItemVariant.plain, false) => _AppListItemStyle.plain,
    };
    final background = switch (style) {
      _AppListItemStyle.plain => tokens.colors.transparent,
      _AppListItemStyle.muted => tokens.colors.surfaceSubtle,
      _AppListItemStyle.primary => tokens.colors.primary,
    };
    final foreground = style == _AppListItemStyle.primary ? tokens.colors.onPrimary : tokens.colors.onSurface;
    final hoverBackground = style == _AppListItemStyle.primary ? tokens.colors.primary : tokens.colors.surfaceSubtle;
    final borderColor = _focused
        ? tokens.colors.focusRing
        : widget.selected
        ? tokens.colors.border
        : tokens.colors.transparent;
    final padding = switch (widget.size) {
      AppListItemSize.standard => EdgeInsets.all(tokens.spacing.lg),
      AppListItemSize.sm => EdgeInsets.symmetric(horizontal: tokens.spacing.md, vertical: tokens.spacing.sm),
    };
    final gap = switch (widget.size) {
      AppListItemSize.standard => tokens.spacing.md,
      AppListItemSize.sm => tokens.spacing.sm,
    };
    final titleStyle = style == _AppListItemStyle.primary
        ? tokens.typography.listItemTitleOnPrimary
        : tokens.typography.listItemTitle;
    final subtitleStyle = switch ((widget.size, style)) {
      (AppListItemSize.standard, _AppListItemStyle.primary) => tokens.typography.listItemDescriptionOnPrimary,
      (AppListItemSize.sm, _AppListItemStyle.primary) => tokens.typography.listItemDescriptionCompactOnPrimary,
      (AppListItemSize.standard, _) => tokens.typography.listItemDescription,
      (AppListItemSize.sm, _) => tokens.typography.listItemDescriptionCompact,
    };
    final effectiveMedia =
        widget.media ??
        (widget.leadingIcon == null
            ? null
            : _AppListItemIcon(
                widget.leadingIcon!,
                size: AppIconSize.md,
                color: foreground,
              ));
    final effectiveTrailing = widget.trailing ?? (widget.badge == null ? null : AppBadge(label: widget.badge!));

    final text = ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: titleStyle),
          if (widget.subtitle != null) ...[
            SizedBox(height: tokens.spacing.xxxs),
            Text(widget.subtitle!, style: subtitleStyle),
          ],
        ],
      ),
    );
    final content = Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final reflowTrailing =
              effectiveTrailing != null &&
              (constraints.maxWidth < _trailingReflowWidth || MediaQuery.textScalerOf(context).scale(14) >= 24);
          final main = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (effectiveMedia != null) ...[
                effectiveMedia,
                SizedBox(width: gap),
              ],
              Expanded(child: text),
              if (effectiveTrailing != null && !reflowTrailing) ...[
                SizedBox(width: gap),
                effectiveTrailing,
              ],
            ],
          );
          if (!reflowTrailing) return main;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              main,
              SizedBox(height: gap),
              Align(alignment: Alignment.centerRight, child: effectiveTrailing),
            ],
          );
        },
      ),
    );
    final item = AnimatedContainer(
      key: const ValueKey('app-list-item-surface'),
      duration: context.motionDuration(tokens.motion.fast),
      decoration: BoxDecoration(
        color: _hovered && interactive ? hoverBackground : background,
        border: Border.all(
          color: borderColor,
          width: _focused ? tokens.borders.widthStrong : tokens.borders.widthHairline,
        ),
        borderRadius: tokens.borders.lg,
      ),
      child: widget.header == null
          ? content
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(padding.left, padding.top, padding.right, 0),
                  child: widget.header,
                ),
                content,
              ],
            ),
    );

    return Semantics(
      label: widget.semanticLabel ?? [widget.title, if (widget.subtitle != null) widget.subtitle!].join(', '),
      button: interactive,
      selected: widget.selected,
      enabled: interactive,
      onTap: widget.onTap,
      child: Material(
        color: tokens.colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          excludeFromSemantics: true,
          onHover: interactive ? _setHovered : null,
          onFocusChange: _setFocused,
          canRequestFocus: interactive,
          borderRadius: tokens.borders.lg,
          overlayColor: WidgetStatePropertyAll(tokens.colors.transparent),
          splashFactory: NoSplash.splashFactory,
          child: item,
        ),
      ),
    );
  }
}
