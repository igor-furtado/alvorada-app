import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../responsive/app_responsive.dart';

@immutable
class AppTabItem<T> {
  const AppTabItem({required this.value, required this.label, required this.content});

  final T value;
  final String label;
  final Widget content;
}

class AppTabs<T> extends StatefulWidget {
  const AppTabs({required this.initialValue, required this.items, super.key});

  final T initialValue;
  final List<AppTabItem<T>> items;

  @override
  State<AppTabs<T>> createState() => _AppTabsState<T>();
}

class _AppTabsState<T> extends State<AppTabs<T>> {
  late T _value = widget.initialValue;

  @override
  void didUpdateWidget(covariant AppTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.items.any((item) => item.value == _value)) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.items.firstWhere((item) => item.value == _value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.tokens.colors.surfaceSubtle,
              borderRadius: context.tokens.borders.sm,
            ),
            child: Padding(
              padding: EdgeInsets.all(context.tokens.spacing.xxxs),
              child: Row(
                children: [
                  for (final item in widget.items)
                    Semantics(
                      button: true,
                      selected: item.value == _value,
                      child: InkWell(
                        onTap: () => setState(() => _value = item.value),
                        borderRadius: context.tokens.borders.xs,
                        child: AnimatedContainer(
                          duration: context.motionDuration(context.tokens.motion.fast),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.tokens.spacing.xs,
                            vertical: context.tokens.spacing.xxxs,
                          ),
                          decoration: BoxDecoration(
                            color: item.value == _value
                                ? context.tokens.colors.surface
                                : context.tokens.colors.transparent,
                            border: Border.all(
                              color: item.value == _value
                                  ? context.tokens.colors.border
                                  : context.tokens.colors.transparent,
                            ),
                            borderRadius: context.tokens.borders.xs,
                          ),
                          child: Text(item.label, style: context.tokens.typography.labelMedium),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: context.tokens.spacing.sm),
        selected.content,
      ],
    );
  }
}
