import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_badge.dart';
import '../atoms/app_icon.dart';
import '../responsive/app_responsive.dart';

enum AppListItemVariant { plain, outline, muted }

enum AppListItemSize { standard, sm, xs }

enum AppListItemRole { button, link }

enum AppListItemMediaVariant { icon, avatar, image }

/// Mídia com dimensões e recortes consistentes para [AppListItem].
class AppListItemMedia extends StatelessWidget {
  const AppListItemMedia({
    required this.child,
    this.variant = AppListItemMediaVariant.icon,
    this.semanticLabel,
    super.key,
  }) : icon = null,
       size = AppIconSize.md,
       color = null;

  const AppListItemMedia.icon(
    this.icon, {
    this.size = AppIconSize.md,
    this.color,
    this.semanticLabel,
    super.key,
  }) : child = null,
       variant = AppListItemMediaVariant.icon;

  const AppListItemMedia.avatar(
    Widget avatar, {
    String? semanticLabel,
    Key? key,
  }) : this(
         key: key,
         variant: AppListItemMediaVariant.avatar,
         semanticLabel: semanticLabel,
         child: avatar,
       );

  const AppListItemMedia.image(
    Widget image, {
    String? semanticLabel,
    Key? key,
  }) : this(
         key: key,
         variant: AppListItemMediaVariant.image,
         semanticLabel: semanticLabel,
         child: image,
       );

  final Widget? child;
  final IconData? icon;
  final AppIconSize size;
  final Color? color;
  final AppListItemMediaVariant variant;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dimension = switch (variant) {
      AppListItemMediaVariant.icon => context.tokens.icons.lg,
      AppListItemMediaVariant.avatar => context.tokens.sizes.avatarLg,
      AppListItemMediaVariant.image => context.tokens.sizes.identityIcon,
    };
    final radius = switch (variant) {
      AppListItemMediaVariant.icon => context.tokens.borders.sm,
      AppListItemMediaVariant.avatar => BorderRadius.circular(dimension),
      AppListItemMediaVariant.image => context.tokens.borders.md,
    };

    return Semantics(
      label: semanticLabel,
      image: variant != AppListItemMediaVariant.icon,
      excludeSemantics: semanticLabel != null,
      child: SizedBox.square(
        key: const ValueKey('app-list-item-media'),
        dimension: dimension,
        child: ClipRRect(
          borderRadius: radius,
          child: Center(
            child: icon == null ? child : AppIcon(icon!, size: size, color: color),
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho visual que ocupa a largura do item antes de seu conteúdo.
class AppListItemHeader extends StatelessWidget {
  const AppListItemHeader({required this.child, this.height, super.key});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: height ?? context.tokens.sizes.reviewAccentHeight,
    child: ClipRRect(
      borderRadius: context.tokens.borders.md,
      child: child,
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
    this.role = AppListItemRole.button,
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
  final AppListItemRole role;
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
    final effectiveVariant = widget.selected ? AppListItemVariant.muted : widget.variant;
    final background = switch (effectiveVariant) {
      AppListItemVariant.plain => tokens.colors.transparent,
      AppListItemVariant.outline => tokens.colors.surface,
      AppListItemVariant.muted => tokens.colors.surfaceSubtle,
    };
    final borderColor = _focused
        ? tokens.colors.focusRing
        : effectiveVariant == AppListItemVariant.outline || widget.selected
        ? tokens.colors.border
        : tokens.colors.transparent;
    final padding = switch (widget.size) {
      AppListItemSize.standard => EdgeInsets.all(tokens.spacing.lg),
      AppListItemSize.sm => EdgeInsets.symmetric(horizontal: tokens.spacing.md, vertical: tokens.spacing.sm),
      AppListItemSize.xs => EdgeInsets.symmetric(horizontal: tokens.spacing.sm, vertical: tokens.spacing.xs),
    };
    final gap = switch (widget.size) {
      AppListItemSize.standard => tokens.spacing.md,
      AppListItemSize.sm => tokens.spacing.sm,
      AppListItemSize.xs => tokens.spacing.xs,
    };
    final titleStyle = switch (widget.size) {
      AppListItemSize.standard => tokens.typography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      AppListItemSize.sm => tokens.typography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      AppListItemSize.xs => tokens.typography.labelLarge,
    };
    final subtitleStyle = switch (widget.size) {
      AppListItemSize.standard => tokens.typography.bodyMedium,
      AppListItemSize.sm => tokens.typography.bodySmall,
      AppListItemSize.xs => tokens.typography.labelMedium,
    }.copyWith(color: tokens.colors.onSurfaceMuted);
    final effectiveMedia =
        widget.media ??
        (widget.leadingIcon == null
            ? null
            : AppListItemMedia.icon(
                widget.leadingIcon,
                size: widget.size == AppListItemSize.xs ? AppIconSize.sm : AppIconSize.md,
              ));
    final effectiveTrailing = widget.trailing ?? (widget.badge == null ? null : AppBadge(label: widget.badge!));

    final content = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (effectiveMedia != null) ...[
            effectiveMedia,
            SizedBox(width: gap),
          ],
          Expanded(
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
          ),
          if (effectiveTrailing != null) ...[
            SizedBox(width: gap),
            effectiveTrailing,
          ],
        ],
      ),
    );
    final item = AnimatedContainer(
      key: const ValueKey('app-list-item-surface'),
      duration: context.motionDuration(tokens.motion.fast),
      decoration: BoxDecoration(
        color: _hovered && interactive ? tokens.colors.surfaceSubtle : background,
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
      button: interactive && widget.role == AppListItemRole.button,
      link: interactive && widget.role == AppListItemRole.link,
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
