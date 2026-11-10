import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_divider.dart';
import '../atoms/app_icon.dart';
import '../responsive/app_responsive.dart';

@immutable
class AppAccordionItem<T> {
  const AppAccordionItem({
    required this.value,
    required this.title,
    required this.child,
  });

  final T value;
  final Widget title;
  final Widget child;
}

class AppAccordion<T> extends StatefulWidget {
  const AppAccordion({
    required this.items,
    required this.expandedValues,
    required this.onToggle,
    super.key,
  });

  final List<AppAccordionItem<T>> items;
  final Set<T> expandedValues;
  final ValueChanged<T> onToggle;

  @override
  State<AppAccordion<T>> createState() => _AppAccordionState<T>();
}

class _AppAccordionState<T> extends State<AppAccordion<T>> {
  late Set<T> _expandedValues = {...widget.expandedValues};

  @override
  void didUpdateWidget(covariant AppAccordion<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expandedValues != widget.expandedValues) {
      _expandedValues = {...widget.expandedValues};
    }
  }

  void _toggle(T value) {
    setState(() {
      if (!_expandedValues.remove(value)) _expandedValues.add(value);
    });
    widget.onToggle(value);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var index = 0; index < widget.items.length; index++) ...[
        _AppAccordionRow<T>(
          item: widget.items[index],
          expanded: _expandedValues.contains(widget.items[index].value),
          onToggle: _toggle,
        ),
        if (index < widget.items.length - 1) const AppDivider(margin: EdgeInsets.zero),
      ],
    ],
  );
}

class _AppAccordionRow<T> extends StatelessWidget {
  const _AppAccordionRow({required this.item, required this.expanded, required this.onToggle});

  final AppAccordionItem<T> item;
  final bool expanded;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    final triggerStyle = context.tokens.typography.button.copyWith(
      height: context.tokens.typography.bodySmall.height,
      color: context.tokens.colors.onSurface,
    );
    final contentStyle = context.tokens.typography.bodySmall.copyWith(
      color: context.tokens.colors.onSurface,
      letterSpacing: 0,
    );

    return Column(
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: InkWell(
            onTap: () => onToggle(item.value),
            borderRadius: context.tokens.borders.lg,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: (context.tokens.spacing.sm + context.tokens.spacing.md) / 2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: triggerStyle,
                      child: item.title,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: context.motionDuration(context.tokens.motion.medium),
                    child: const _AppAccordionChevron(),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: context.motionDuration(context.tokens.motion.medium),
          curve: context.tokens.motion.standard,
          child: expanded
              ? Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.tokens.spacing.none,
                    context.tokens.spacing.none,
                    context.tokens.spacing.none,
                    (context.tokens.spacing.sm + context.tokens.spacing.md) / 2,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DefaultTextStyle.merge(
                      style: contentStyle,
                      child: item.child,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _AppAccordionChevron extends StatelessWidget {
  const _AppAccordionChevron();

  @override
  Widget build(BuildContext context) => AppIcon(
    AppIcons.expandMore,
    size: AppIconSize.sm,
    color: context.tokens.colors.onSurfaceMuted,
  );
}
