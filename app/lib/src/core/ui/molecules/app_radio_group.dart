import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_radio.dart';

@immutable
class AppRadioOption<T> {
  const AppRadioOption({required this.value, required this.label});

  final T value;
  final String label;
}

class AppRadioGroup<T> extends StatefulWidget {
  const AppRadioGroup({
    required this.options,
    required this.value,
    this.onChanged,
    this.direction = Axis.vertical,
    super.key,
  });

  final List<AppRadioOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Axis direction;

  @override
  State<AppRadioGroup<T>> createState() => _AppRadioGroupState<T>();
}

class _AppRadioGroupState<T> extends State<AppRadioGroup<T>> {
  final _focusNodes = <FocusNode>[];

  void _syncFocusNodes() {
    while (_focusNodes.length < widget.options.length) {
      _focusNodes.add(FocusNode());
    }
    while (_focusNodes.length > widget.options.length) {
      _focusNodes.removeLast().dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    _syncFocusNodes();
  }

  @override
  void didUpdateWidget(covariant AppRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFocusNodes();
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.onChanged == null || widget.options.isEmpty) {
      return KeyEventResult.ignored;
    }
    final forwardKey = widget.direction == Axis.vertical ? LogicalKeyboardKey.arrowDown : LogicalKeyboardKey.arrowRight;
    final backwardKey = widget.direction == Axis.vertical ? LogicalKeyboardKey.arrowUp : LogicalKeyboardKey.arrowLeft;
    final offset = event.logicalKey == forwardKey
        ? 1
        : event.logicalKey == backwardKey
        ? -1
        : 0;
    if (offset == 0) return KeyEventResult.ignored;
    final currentIndex = _focusNodes.indexWhere((focusNode) => focusNode.hasFocus);
    if (currentIndex < 0) return KeyEventResult.ignored;
    final nextIndex = (currentIndex + offset) % widget.options.length;
    _focusNodes[nextIndex].requestFocus();
    widget.onChanged!(widget.options[nextIndex].value);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      for (var index = 0; index < widget.options.length; index++)
        AppRadio<T>(
          value: widget.options[index].value,
          semanticLabel: widget.options[index].label,
          selected: widget.options[index].value == widget.value,
          enabled: widget.onChanged != null,
          onChanged: widget.onChanged,
          focusNode: _focusNodes[index],
          label: Text(widget.options[index].label, style: context.tokens.typography.bodyMedium),
        ),
    ];
    return Focus(
      canRequestFocus: false,
      onKeyEvent: _handleKey,
      child: FocusTraversalGroup(
        child: widget.direction == Axis.vertical
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)
            : Wrap(spacing: context.tokens.spacing.md, children: children),
      ),
    );
  }
}
