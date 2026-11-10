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

  @override
  State<AppResizable> createState() => _AppResizableState();
}

class _AppResizableState extends State<AppResizable> {
  static const _keyboardStep = .05;
  late double _ratio = widget.initialRatio;

  void _adjust(double delta) {
    setState(() => _ratio = (_ratio + delta).clamp(widget.minRatio, widget.maxRatio));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final extent = widget.direction == Axis.horizontal ? constraints.maxWidth : constraints.maxHeight;
      final firstExtent = extent * _ratio;
      final handle = _ResizeHandle(
        direction: widget.direction,
        ratio: _ratio,
        decreasedRatio: (_ratio - _keyboardStep).clamp(widget.minRatio, widget.maxRatio),
        increasedRatio: (_ratio + _keyboardStep).clamp(widget.minRatio, widget.maxRatio),
        onDelta: (delta) => _adjust(delta / extent),
        onDecrease: () => _adjust(-_keyboardStep),
        onIncrease: () => _adjust(_keyboardStep),
      );
      if (widget.direction == Axis.horizontal) {
        return Row(
          children: [
            SizedBox(width: firstExtent, child: widget.first),
            handle,
            Expanded(child: widget.second),
          ],
        );
      }
      return Column(
        children: [
          SizedBox(height: firstExtent, child: widget.first),
          handle,
          Expanded(child: widget.second),
        ],
      );
    },
  );
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    required this.direction,
    required this.ratio,
    required this.decreasedRatio,
    required this.increasedRatio,
    required this.onDelta,
    required this.onDecrease,
    required this.onIncrease,
  });

  final Axis direction;
  final double ratio;
  final double decreasedRatio;
  final double increasedRatio;
  final ValueChanged<double> onDelta;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Redimensionar painéis',
    value: '${(ratio * 100).round()}%',
    decreasedValue: '${(decreasedRatio * 100).round()}%',
    increasedValue: '${(increasedRatio * 100).round()}%',
    onDecrease: onDecrease,
    onIncrease: onIncrease,
    child: CallbackShortcuts(
      bindings: {
        SingleActivator(
          direction == Axis.horizontal ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowUp,
        ): onDecrease,
        SingleActivator(
          direction == Axis.horizontal ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowDown,
        ): onIncrease,
      },
      child: Focus(
        child: MouseRegion(
          cursor: direction == Axis.horizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: direction == Axis.horizontal ? (details) => onDelta(details.delta.dx) : null,
            onVerticalDragUpdate: direction == Axis.vertical ? (details) => onDelta(details.delta.dy) : null,
            child: SizedBox(
              width: direction == Axis.horizontal ? context.tokens.spacing.sm : double.infinity,
              height: direction == Axis.vertical ? context.tokens.spacing.sm : double.infinity,
              child: Center(
                child: Container(
                  width: direction == Axis.horizontal
                      ? context.tokens.borders.widthStrong
                      : context.tokens.spacing.xxxl,
                  height: direction == Axis.vertical ? context.tokens.borders.widthStrong : context.tokens.spacing.xxxl,
                  color: context.tokens.colors.border,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
