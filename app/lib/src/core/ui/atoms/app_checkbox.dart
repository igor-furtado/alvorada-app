import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../responsive/app_responsive.dart';

class AppCheckbox extends StatefulWidget {
  const AppCheckbox({
    required this.value,
    required this.semanticLabel,
    this.onChanged,
    this.tristate = false,
    super.key,
  });

  final bool? value;
  final String semanticLabel;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final enabled = widget.onChanged != null;
    final selected = widget.value != false;
    final checkbox = Semantics(
      checked: widget.value,
      enabled: enabled,
      onTap: enabled ? _toggle : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : tokens.opacity.half,
        child: Material(
          color: tokens.colors.transparent,
          child: InkWell(
            onTap: enabled ? _toggle : null,
            onFocusChange: (focused) => setState(() => _focused = focused),
            borderRadius: tokens.borders.sm,
            overlayColor: WidgetStatePropertyAll(tokens.colors.transparent),
            splashFactory: NoSplash.splashFactory,
            child: SizedBox.square(
              dimension: tokens.layout.controlHeight,
              child: Center(
                child: AnimatedContainer(
                  duration: context.motionDuration(tokens.motion.fast),
                  width: tokens.icons.sm,
                  height: tokens.icons.sm,
                  decoration: BoxDecoration(
                    color: selected ? tokens.colors.primary : tokens.colors.surface,
                    border: Border.all(
                      color: _focused
                          ? tokens.colors.focusRing
                          : selected
                          ? tokens.colors.primary
                          : tokens.colors.controlOutline,
                      width: _focused ? tokens.borders.widthStrong : tokens.borders.widthHairline,
                    ),
                    borderRadius: tokens.borders.xs,
                  ),
                  child: selected
                      ? Icon(
                          widget.value == null ? Icons.remove : Icons.check,
                          size: tokens.spacing.md,
                          color: tokens.colors.onPrimary,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return MergeSemantics(
      child: Semantics(label: widget.semanticLabel, child: checkbox),
    );
  }

  void _toggle() {
    if (widget.tristate) {
      widget.onChanged!(switch (widget.value) {
        false => true,
        true => null,
        null => false,
      });
      return;
    }
    widget.onChanged!(!(widget.value ?? false));
  }
}
