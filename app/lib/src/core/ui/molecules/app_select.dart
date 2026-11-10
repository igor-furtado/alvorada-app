import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

@immutable
class AppSelectOption<T> {
  const AppSelectOption({required this.value, required this.label, this.enabled = true});

  final T value;
  final String label;
  final bool enabled;
}

class AppSelect<T> extends StatefulWidget {
  const AppSelect({
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder,
    this.semanticLabel,
    super.key,
  });

  final List<AppSelectOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? placeholder;
  final String? semanticLabel;

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  final _controller = OverlayPortalController();
  final _link = LayerLink();
  final _triggerKey = GlobalKey();
  final _menuController = ScrollController(keepScrollOffset: false);
  var _open = false;
  var _focused = false;
  var _openUpwards = false;
  double? _triggerWidth;

  bool get _enabled => widget.onChanged != null;

  void _setOpen(bool value) {
    if (_open == value || (value && !_enabled)) return;
    if (value) {
      final renderObject = _triggerKey.currentContext?.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize) {
        _triggerWidth = renderObject.size.width;
        final tokens = context.tokens;
        final itemCount = widget.options.length + (widget.placeholder == null ? 0 : 1);
        final desiredHeight = (itemCount * tokens.layout.controlHeight) + (tokens.spacing.xs * 2);
        final menuHeight = desiredHeight > tokens.sizes.dialogNarrow ? tokens.sizes.dialogNarrow : desiredHeight;
        final bottom = renderObject.localToGlobal(Offset.zero).dy + renderObject.size.height;
        _openUpwards = MediaQuery.sizeOf(context).height - bottom < menuHeight + tokens.spacing.xs;
      }
    }
    setState(() => _open = value);
    if (value) {
      _controller.show();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_menuController.hasClients) _menuController.jumpTo(0);
      });
    } else {
      _controller.hide();
    }
  }

  @override
  void didUpdateWidget(covariant AppSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_open && !_enabled) {
      _open = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.hide();
      });
    }
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _select(T? value) {
    widget.onChanged?.call(value);
    _setOpen(false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final selected = widget.options.where((option) => option.value == widget.value).firstOrNull;
    final label = selected?.label ?? widget.placeholder ?? '';
    final muted = selected == null;

    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (overlayContext) {
        final triggerWidth = _triggerWidth ?? tokens.sizes.dialogNarrow;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _setOpen(false),
                child: ColoredBox(color: tokens.colors.transparent),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: _openUpwards ? Alignment.topLeft : Alignment.bottomLeft,
              followerAnchor: _openUpwards ? Alignment.bottomLeft : Alignment.topLeft,
              offset: Offset(0, _openUpwards ? -tokens.spacing.xs : tokens.spacing.xs),
              child: Material(
                color: tokens.colors.transparent,
                child: Container(
                  width: triggerWidth,
                  constraints: BoxConstraints(maxHeight: tokens.sizes.dialogNarrow),
                  padding: EdgeInsets.all(tokens.spacing.xs),
                  decoration: BoxDecoration(
                    color: tokens.colors.popover,
                    border: Border.all(color: tokens.colors.border),
                    borderRadius: tokens.borders.lg,
                    boxShadow: tokens.shadows.overlay,
                  ),
                  child: SingleChildScrollView(
                    controller: _menuController,
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.placeholder != null)
                          _AppSelectMenuItem(
                            label: widget.placeholder!,
                            selected: widget.value == null,
                            onPressed: () => _select(null),
                          ),
                        for (final option in widget.options)
                          _AppSelectMenuItem(
                            label: option.label,
                            selected: option.value == widget.value,
                            enabled: option.enabled,
                            onPressed: () => _select(option.value),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: Semantics(
          label: widget.semanticLabel,
          button: true,
          enabled: _enabled,
          expanded: _open,
          onTap: _enabled ? () => _setOpen(!_open) : null,
          excludeSemantics: true,
          child: Opacity(
            opacity: _enabled ? 1 : tokens.opacity.half,
            child: Material(
              key: _triggerKey,
              color: tokens.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: tokens.borders.sm,
                side: BorderSide(
                  color: _focused || _open ? tokens.colors.focusRing : tokens.colors.controlOutline,
                  width: _focused || _open ? tokens.borders.widthStrong : tokens.borders.widthHairline,
                ),
              ),
              child: InkWell(
                onTap: _enabled ? () => _setOpen(!_open) : null,
                onFocusChange: (focused) => setState(() => _focused = focused),
                borderRadius: tokens.borders.sm,
                overlayColor: WidgetStatePropertyAll(tokens.colors.surfaceSubtle),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: tokens.layout.controlHeight),
                  child: Padding(
                    padding: EdgeInsets.only(left: tokens.spacing.md, right: tokens.spacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tokens.typography.bodySmall.copyWith(
                              color: muted ? tokens.colors.onSurfaceMuted : tokens.colors.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(width: tokens.spacing.sm),
                        Icon(
                          AppIcons.expandMore,
                          size: tokens.icons.sm,
                          color: tokens.colors.onSurfaceMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppSelectMenuItem extends StatelessWidget {
  const _AppSelectMenuItem({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : tokens.opacity.half,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: tokens.borders.sm,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.layout.controlHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: tokens.typography.bodySmall)),
                  if (selected) Icon(AppIcons.check, size: tokens.icons.sm, color: tokens.colors.onSurface),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
