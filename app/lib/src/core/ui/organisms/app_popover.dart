import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../responsive/app_responsive.dart';

class AppPopover extends StatefulWidget {
  const AppPopover({
    required this.trigger,
    required this.content,
    this.width,
    this.hover = false,
    this.onOpenChanged,
    super.key,
  });

  final Widget trigger;
  final Widget content;
  final double? width;
  final bool hover;
  final ValueChanged<bool>? onOpenChanged;

  @override
  State<AppPopover> createState() => _AppPopoverState();
}

class _AppPopoverState extends State<AppPopover> {
  final _controller = OverlayPortalController();
  final _link = LayerLink();
  final _triggerFocusNode = FocusNode();
  Timer? _closeTimer;
  var _open = false;
  var _focused = false;

  void _setOpen(bool value) {
    if (_open == value) return;
    _closeTimer?.cancel();
    _open = value;
    if (value) {
      _controller.show();
    } else {
      _controller.hide();
    }
    widget.onOpenChanged?.call(value);
    if (mounted) setState(() {});
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(context.motionDuration(context.tokens.motion.fast), () => _setOpen(false));
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _triggerFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleTriggerKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape && _open) {
      _setOpen(false);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space) {
      if (widget.hover) {
        _setOpen(true);
      } else {
        _setOpen(!_open);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleTriggerFocus(bool focused) {
    if (_focused != focused) setState(() => _focused = focused);
    if (!widget.hover) return;
    if (focused) {
      _setOpen(true);
    } else {
      _scheduleClose();
    }
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _controller,
    overlayChildBuilder: (overlayContext) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _setOpen(false),
            child: ColoredBox(color: context.tokens.colors.transparent),
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, context.tokens.spacing.xs),
          child: MouseRegion(
            onEnter: widget.hover ? (_) => _setOpen(true) : null,
            onExit: widget.hover ? (_) => _scheduleClose() : null,
            child: Material(
              color: context.tokens.colors.transparent,
              child: Container(
                width: widget.width,
                constraints: BoxConstraints(maxWidth: context.tokens.layout.dialogMaxWidth),
                padding: EdgeInsets.all((context.tokens.spacing.sm + context.tokens.spacing.md) / 2),
                decoration: BoxDecoration(
                  color: context.tokens.colors.popover,
                  border: Border.all(color: context.tokens.colors.border),
                  borderRadius: context.tokens.borders.lg,
                  boxShadow: context.tokens.shadows.overlay,
                ),
                child: widget.content,
              ),
            ),
          ),
        ),
      ],
    ),
    child: CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: widget.hover ? (_) => _setOpen(true) : null,
        onExit: widget.hover ? (_) => _scheduleClose() : null,
        child: Focus(
          focusNode: _triggerFocusNode,
          onFocusChange: _handleTriggerFocus,
          onKeyEvent: _handleTriggerKey,
          child: Semantics(
            button: !widget.hover,
            expanded: _open,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.hover
                  ? null
                  : () {
                      _triggerFocusNode.requestFocus();
                      _setOpen(!_open);
                    },
              child: AnimatedContainer(
                duration: context.motionDuration(context.tokens.motion.fast),
                foregroundDecoration: BoxDecoration(
                  border: Border.all(
                    color: _focused ? context.tokens.colors.focusRing : context.tokens.colors.transparent,
                    width: context.tokens.borders.widthStrong,
                  ),
                  borderRadius: context.tokens.borders.sm,
                ),
                child: widget.trigger,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AppHoverCard extends StatelessWidget {
  const AppHoverCard({required this.trigger, required this.content, this.width, super.key});

  final Widget trigger;
  final Widget content;
  final double? width;

  @override
  Widget build(BuildContext context) => AppPopover(
    trigger: trigger,
    content: content,
    width: width,
    hover: true,
  );
}
