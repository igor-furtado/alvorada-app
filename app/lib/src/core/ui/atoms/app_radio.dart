import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../responsive/app_responsive.dart';

class AppRadio<T> extends StatefulWidget {
  const AppRadio({
    required this.value,
    required this.semanticLabel,
    required this.selected,
    this.onChanged,
    this.enabled = true,
    this.toggleable = false,
    this.label,
    this.focusNode,
    super.key,
  });

  final T value;
  final String semanticLabel;
  final bool selected;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final bool toggleable;
  final Widget? label;
  final FocusNode? focusNode;

  @override
  State<AppRadio<T>> createState() => _AppRadioState<T>();
}

class _AppRadioState<T> extends State<AppRadio<T>> {
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.enabled && widget.onChanged != null;
    return MergeSemantics(
      child: Semantics(
        label: widget.semanticLabel,
        checked: widget.selected,
        enabled: interactive,
        inMutuallyExclusiveGroup: true,
        child: InkWell(
          focusNode: widget.focusNode,
          onFocusChange: (focused) => setState(() => _focused = focused),
          onTap: interactive
              ? () => widget.onChanged!(widget.selected && widget.toggleable ? null : widget.value)
              : null,
          borderRadius: context.tokens.borders.sm,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: context.tokens.layout.controlHeight),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: context.tokens.layout.controlHeight,
                  child: Center(
                    child: AnimatedContainer(
                      duration: context.motionDuration(context.tokens.motion.fast),
                      width: context.tokens.icons.sm,
                      height: context.tokens.icons.sm,
                      padding: EdgeInsets.all(context.tokens.spacing.xxs),
                      decoration: BoxDecoration(
                        color: widget.selected ? context.tokens.colors.primary : context.tokens.colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _focused
                              ? context.tokens.colors.focusRing
                              : widget.selected
                              ? context.tokens.colors.primary
                              : context.tokens.colors.controlOutline,
                          width: _focused || widget.selected
                              ? context.tokens.borders.widthStrong
                              : context.tokens.borders.widthHairline,
                        ),
                      ),
                      child: widget.selected
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                color: context.tokens.colors.onPrimary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                ?widget.label,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
