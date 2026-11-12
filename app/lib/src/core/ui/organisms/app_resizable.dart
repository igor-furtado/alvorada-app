import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

class AppResizable extends StatefulWidget {
  const AppResizable({
    required this.first,
    required this.second,
    this.direction = Axis.horizontal,
    this.initialRatio = .5,
    this.minRatio = .2,
    this.maxRatio = .8,
    this.withHandle = true,
    super.key,
  }) : assert(
         initialRatio >= minRatio && initialRatio <= maxRatio,
         'Initial ratio must be within the configured bounds.',
       ),
       assert(minRatio > 0 && maxRatio < 1, 'Resize bounds must stay between zero and one.');

  final Widget first;
  final Widget second;
  final Axis direction;
  final double initialRatio;
  final double minRatio;
  final double maxRatio;
  final bool withHandle;

  @override
  State<AppResizable> createState() => _AppResizableState();
}

class _AppResizableState extends State<AppResizable> {
  static const _keyboardStep = .05;
  late double _ratio = widget.initialRatio;

  @override
  void didUpdateWidget(covariant AppResizable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ratio = _ratio.clamp(widget.minRatio, widget.maxRatio);
  }

  void _adjust(double delta) {
    setState(() => _ratio = (_ratio + delta).clamp(widget.minRatio, widget.maxRatio));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final tokens = context.tokens;
      final horizontal = widget.direction == Axis.horizontal;
      final extent = horizontal ? constraints.maxWidth : constraints.maxHeight;
      final dividerExtent = tokens.borders.widthHairline;
      final availableExtent = math.max(0, extent - dividerExtent);
      final firstExtent = availableExtent * _ratio;
      final textDirection = Directionality.of(context);
      final reversed = horizontal && textDirection == TextDirection.rtl;
      final dividerOffset = reversed ? availableExtent - firstExtent : firstExtent;
      final hitExtent = tokens.sizes.avatarSm;
      final handle = _ResizeHandle(
        direction: widget.direction,
        ratio: _ratio,
        reversed: reversed,
        withHandle: widget.withHandle,
        decreasedRatio: (_ratio - _keyboardStep).clamp(widget.minRatio, widget.maxRatio),
        increasedRatio: (_ratio + _keyboardStep).clamp(widget.minRatio, widget.maxRatio),
        onDelta: (delta) {
          if (availableExtent <= 0) return;
          _adjust((reversed ? -delta : delta) / availableExtent);
        },
        onDecrease: () => _adjust(-_keyboardStep),
        onIncrease: () => _adjust(_keyboardStep),
      );

      if (horizontal) {
        return Stack(
          children: [
            Row(
              textDirection: textDirection,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: firstExtent, child: widget.first),
                SizedBox(width: dividerExtent),
                Expanded(child: widget.second),
              ],
            ),
            Positioned(
              left: dividerOffset - (hitExtent - dividerExtent) / 2,
              top: 0,
              bottom: 0,
              width: hitExtent,
              child: handle,
            ),
          ],
        );
      }

      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: firstExtent, child: widget.first),
              SizedBox(height: dividerExtent),
              Expanded(child: widget.second),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: dividerOffset - (hitExtent - dividerExtent) / 2,
            height: hitExtent,
            child: handle,
          ),
        ],
      );
    },
  );
}

class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({
    required this.direction,
    required this.ratio,
    required this.reversed,
    required this.withHandle,
    required this.decreasedRatio,
    required this.increasedRatio,
    required this.onDelta,
    required this.onDecrease,
    required this.onIncrease,
  });

  final Axis direction;
  final double ratio;
  final bool reversed;
  final bool withHandle;
  final double decreasedRatio;
  final double increasedRatio;
  final ValueChanged<double> onDelta;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _focused = false;

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final horizontal = widget.direction == Axis.horizontal;
    final decreaseKey = horizontal ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowUp;
    final increaseKey = horizontal ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowDown;
    final onDecreaseKey = widget.reversed ? widget.onIncrease : widget.onDecrease;
    final onIncreaseKey = widget.reversed ? widget.onDecrease : widget.onIncrease;
    final lineColor = _focused ? tokens.colors.focusRing : tokens.colors.border;

    return Semantics(
      label: 'Redimensionar painéis',
      enabled: true,
      value: '${(widget.ratio * 100).round()}%',
      decreasedValue: '${(widget.decreasedRatio * 100).round()}%',
      increasedValue: '${(widget.increasedRatio * 100).round()}%',
      onDecrease: widget.onDecrease,
      onIncrease: widget.onIncrease,
      child: CallbackShortcuts(
        bindings: {
          SingleActivator(decreaseKey): onDecreaseKey,
          SingleActivator(increaseKey): onIncreaseKey,
        },
        child: Focus(
          onFocusChange: _setFocused,
          child: MouseRegion(
            cursor: horizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: horizontal ? (details) => widget.onDelta(details.delta.dx) : null,
              onVerticalDragUpdate: horizontal ? null : (details) => widget.onDelta(details.delta.dy),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    key: const ValueKey('app-resizable-divider'),
                    width: horizontal ? tokens.borders.widthHairline : double.infinity,
                    height: horizontal ? double.infinity : tokens.borders.widthHairline,
                    child: ColoredBox(color: lineColor),
                  ),
                  if (widget.withHandle)
                    Container(
                      key: const ValueKey('app-resizable-handle-indicator'),
                      width: horizontal ? tokens.spacing.xxs : tokens.spacing.xxl,
                      height: horizontal ? tokens.spacing.xxl : tokens.spacing.xxs,
                      decoration: BoxDecoration(
                        color: lineColor,
                        borderRadius: tokens.borders.full,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
