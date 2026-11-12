import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../responsive/app_responsive.dart';

enum AppTabsVariant { segmented, filled, line }

@immutable
class AppTabItem<T> {
  const AppTabItem({required this.value, required this.label, required this.content});

  final T value;
  final String label;
  final Widget content;
}

class AppTabs<T> extends StatefulWidget {
  const AppTabs({
    required this.initialValue,
    required this.items,
    this.value,
    this.onChanged,
    this.variant = AppTabsVariant.segmented,
    this.trailing,
    this.expanded = false,
    this.headerMaxWidth,
    this.headerPadding = EdgeInsets.zero,
    super.key,
  });

  final T initialValue;
  final T? value;
  final List<AppTabItem<T>> items;
  final ValueChanged<T>? onChanged;
  final AppTabsVariant variant;
  final Widget? trailing;
  final bool expanded;
  final double? headerMaxWidth;
  final EdgeInsetsGeometry headerPadding;

  @override
  State<AppTabs<T>> createState() => _AppTabsState<T>();
}

class _AppTabsState<T> extends State<AppTabs<T>> {
  late T _value = widget.value ?? widget.initialValue;
  late List<FocusNode> _focusNodes = _createFocusNodes();

  T get _selectedValue => widget.value ?? _value;

  List<FocusNode> _createFocusNodes() => List.generate(
    widget.items.length,
    (index) => FocusNode(debugLabel: 'AppTabs ${widget.items[index].label}'),
  );

  @override
  void didUpdateWidget(covariant AppTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value case final controlled?) {
      _value = controlled;
    } else if (!widget.items.any((item) => item.value == _value)) {
      _value = widget.initialValue;
    }
    if (oldWidget.items.length != widget.items.length) {
      for (final node in _focusNodes) {
        node.dispose();
      }
      _focusNodes = _createFocusNodes();
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _select(T value) {
    if (widget.value == null) setState(() => _value = value);
    widget.onChanged?.call(value);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        (event.logicalKey != LogicalKeyboardKey.arrowLeft && event.logicalKey != LogicalKeyboardKey.arrowRight)) {
      return KeyEventResult.ignored;
    }
    final current = widget.items.indexWhere((item) => item.value == _selectedValue);
    final direction = event.logicalKey == LogicalKeyboardKey.arrowRight ? 1 : -1;
    final next = (current + direction) % widget.items.length;
    _select(widget.items[next].value);
    _focusNodes[next].requestFocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.items.firstWhere((item) => item.value == _selectedValue);
    final spacing = widget.variant == AppTabsVariant.line ? 0.0 : context.tokens.spacing.sm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Focus(
          canRequestFocus: false,
          onKeyEvent: _handleKeyEvent,
          child: switch (widget.variant) {
            AppTabsVariant.segmented => _segmentedHeader(context),
            AppTabsVariant.filled => _segmentedHeader(context, filled: true),
            AppTabsVariant.line => _lineHeader(context),
          },
        ),
        if (spacing > 0) SizedBox(height: spacing),
        selected.content,
      ],
    );
  }

  Widget _segmentedHeader(BuildContext context, {bool filled = false}) {
    final tabs = [
      for (final (index, item) in widget.items.indexed)
        _SegmentedTab(
          label: item.label,
          selected: item.value == _selectedValue,
          filled: filled,
          focusNode: _focusNodes[index],
          onTap: () => _select(item.value),
        ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? context.tokens.colors.surface : context.tokens.colors.surfaceSubtle,
        borderRadius: context.tokens.borders.xl,
        border: filled ? Border.all(color: context.tokens.colors.border) : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spacing.xxs),
        child: widget.expanded
            ? Row(children: [for (final tab in tabs) Expanded(child: tab)])
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: tabs),
              ),
      ),
    );
  }

  Widget _lineHeader(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.tokens.colors.surface,
      border: Border(bottom: BorderSide(color: context.tokens.colors.border)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.headerMaxWidth ?? double.infinity),
        child: Padding(
          padding: widget.headerPadding,
          child: Row(
            children: [
              for (final (index, item) in widget.items.indexed)
                _LineTab(
                  label: item.label,
                  selected: item.value == _selectedValue,
                  focusNode: _focusNodes[index],
                  onTap: () => _select(item.value),
                ),
              if (widget.trailing != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: widget.trailing,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SegmentedTab extends StatelessWidget {
  const _SegmentedTab({
    required this.label,
    required this.selected,
    required this.filled,
    required this.focusNode,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool filled;
  final FocusNode focusNode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      focusNode: focusNode,
      onTap: onTap,
      borderRadius: context.tokens.borders.lg,
      child: AnimatedContainer(
        duration: context.motionDuration(context.tokens.motion.fast),
        alignment: Alignment.center,
        constraints: BoxConstraints(minHeight: context.tokens.layout.controlHeight),
        padding: EdgeInsets.symmetric(
          horizontal: filled ? context.tokens.spacing.sm : context.tokens.spacing.lg,
        ),
        decoration: BoxDecoration(
          color: selected
              ? filled
                    ? context.tokens.colors.primary
                    : context.tokens.colors.surface
              : context.tokens.colors.transparent,
          borderRadius: context.tokens.borders.lg,
          boxShadow: selected && !filled ? context.tokens.shadows.overlay : const [],
        ),
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: context.tokens.typography.labelLarge.copyWith(
            color: selected
                ? filled
                      ? context.tokens.colors.onPrimary
                      : context.tokens.colors.onSurface
                : context.tokens.colors.onSurfaceMuted,
          ),
        ),
      ),
    ),
  );
}

class _LineTab extends StatelessWidget {
  const _LineTab({
    required this.label,
    required this.selected,
    required this.focusNode,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final FocusNode focusNode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      focusNode: focusNode,
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: context.tokens.layout.controlHeight + context.tokens.spacing.sm),
        padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.xxxs),
        margin: EdgeInsets.only(right: context.tokens.spacing.xxl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? context.tokens.colors.onSurface : context.tokens.colors.transparent,
              width: context.tokens.borders.widthStrong,
            ),
          ),
        ),
        child: Text(
          label,
          style: context.tokens.typography.labelLarge.copyWith(
            color: selected ? context.tokens.colors.onSurface : context.tokens.colors.onSurfaceMuted,
          ),
        ),
      ),
    ),
  );
}
