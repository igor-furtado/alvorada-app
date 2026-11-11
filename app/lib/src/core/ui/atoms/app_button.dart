import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../responsive/app_responsive.dart';

enum AppButtonVariant { primary, secondary, outline, text, destructive }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.loading = false,
    this.semanticLabel,
    this.autofocus = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;
  final String? semanticLabel;
  final bool autofocus;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = _AppButtonPalette.resolve(context, widget.variant);
    final background = _pressed || _hovered ? palette.interactiveBackground : palette.background;
    final height = switch (widget.size) {
      AppButtonSize.sm => tokens.layout.buttonHeightSm,
      AppButtonSize.md => tokens.layout.buttonHeightMd,
      AppButtonSize.lg => tokens.layout.buttonHeightLg,
    };
    final horizontalPadding = (tokens.spacing.sm + tokens.spacing.md) / 2;
    final leading = widget.loading
        ? SizedBox.square(
            dimension: tokens.icons.sm,
            child: CircularProgressIndicator(
              color: palette.foreground,
              strokeWidth: tokens.borders.widthStrong,
            ),
          )
        : widget.icon == null
        ? null
        : Icon(
            widget.icon,
            size: tokens.icons.sm,
            color: palette.foreground,
          );
    final content = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - horizontalPadding - horizontalPadding,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: tokens.spacing.xs),
          ],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: tokens.typography.button.copyWith(
                color: palette.foreground,
              ),
            ),
          ),
        ],
      ),
    );
    final effectiveLabel = widget.loading
        ? '${widget.semanticLabel ?? widget.label}, ${AppMessages.loading}'
        : widget.semanticLabel ?? widget.label;

    return Semantics(
      label: effectiveLabel,
      button: true,
      enabled: _enabled,
      liveRegion: widget.loading,
      onTap: _enabled ? widget.onPressed : null,
      excludeSemantics: true,
      child: Material(
        color: tokens.colors.transparent,
        child: InkWell(
          onTap: _enabled ? widget.onPressed : null,
          onHover: _enabled ? _setHovered : null,
          onFocusChange: _setFocused,
          onHighlightChanged: _enabled ? _setPressed : null,
          autofocus: widget.autofocus,
          canRequestFocus: _enabled,
          excludeFromSemantics: true,
          borderRadius: tokens.borders.lg,
          mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          overlayColor: WidgetStatePropertyAll(tokens.colors.transparent),
          splashFactory: NoSplash.splashFactory,
          child: Opacity(
            opacity: _enabled ? 1 : tokens.opacity.half,
            child: AnimatedContainer(
              duration: context.motionDuration(tokens.motion.fast),
              curve: tokens.motion.standard,
              constraints: BoxConstraints(minHeight: height),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: tokens.spacing.xxs,
              ),
              decoration: BoxDecoration(
                color: background,
                border: Border.all(
                  color: _focused ? tokens.colors.focusRing : palette.border,
                  width: _focused ? tokens.borders.widthStrong : tokens.borders.widthHairline,
                ),
                borderRadius: tokens.borders.lg,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppButtonPalette {
  const _AppButtonPalette({
    required this.background,
    required this.interactiveBackground,
    required this.foreground,
    required this.border,
  });

  factory _AppButtonPalette.resolve(
    BuildContext context,
    AppButtonVariant variant,
  ) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final transparent = colors.transparent;
    return switch (variant) {
      AppButtonVariant.primary => _AppButtonPalette(
        background: colors.primary,
        interactiveBackground: Color.lerp(
          colors.primary,
          colors.onPrimary,
          tokens.opacity.tint,
        )!,
        foreground: colors.onPrimary,
        border: transparent,
      ),
      AppButtonVariant.secondary => _AppButtonPalette(
        background: colors.surfaceSubtle,
        interactiveBackground: Color.lerp(
          colors.surfaceSubtle,
          colors.onSurface,
          tokens.opacity.tint,
        )!,
        foreground: colors.onSurface,
        border: transparent,
      ),
      AppButtonVariant.outline => _AppButtonPalette(
        background: colors.surface,
        interactiveBackground: colors.primaryContainer,
        foreground: colors.onSurface,
        border: colors.border,
      ),
      AppButtonVariant.text => _AppButtonPalette(
        background: transparent,
        interactiveBackground: colors.primaryContainer,
        foreground: colors.actionForeground,
        border: transparent,
      ),
      AppButtonVariant.destructive => _AppButtonPalette(
        background: colors.errorContainer,
        interactiveBackground: Color.lerp(colors.errorContainer, colors.error, tokens.opacity.tint)!,
        foreground: colors.error,
        border: transparent,
      ),
    };
  }

  final Color background;
  final Color interactiveBackground;
  final Color foreground;
  final Color border;
}
