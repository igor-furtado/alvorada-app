import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../responsive/app_responsive.dart';

class AppSwitch extends StatefulWidget {
  const AppSwitch({required this.value, required this.semanticLabel, this.onChanged, super.key});

  final bool value;
  final String semanticLabel;
  final ValueChanged<bool>? onChanged;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final enabled = widget.onChanged != null;

    return Semantics(
      label: widget.semanticLabel,
      toggled: widget.value,
      enabled: enabled,
      onTap: enabled ? () => widget.onChanged!(!widget.value) : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : tokens.opacity.half,
        child: Material(
          color: tokens.colors.transparent,
          child: InkWell(
            onTap: enabled ? () => widget.onChanged!(!widget.value) : null,
            onFocusChange: (focused) => setState(() => _focused = focused),
            borderRadius: tokens.borders.full,
            overlayColor: WidgetStatePropertyAll(tokens.colors.transparent),
            splashFactory: NoSplash.splashFactory,
            child: SizedBox(
              width: tokens.layout.controlHeight + tokens.spacing.xs,
              height: tokens.layout.controlHeight,
              child: Center(
                child: AnimatedContainer(
                  duration: context.motionDuration(tokens.motion.fast),
                  width: tokens.spacing.xxxl,
                  height: tokens.spacing.xl - tokens.spacing.xxxs,
                  padding: EdgeInsets.all(tokens.spacing.hairline),
                  decoration: BoxDecoration(
                    color: widget.value ? tokens.colors.primary : tokens.colors.surfaceSubtle,
                    border: Border.all(
                      color: _focused ? tokens.colors.focusRing : tokens.colors.border,
                      width: _focused ? tokens.borders.widthStrong : tokens.borders.widthHairline,
                    ),
                    borderRadius: tokens.borders.full,
                  ),
                  child: AnimatedAlign(
                    duration: context.motionDuration(tokens.motion.fast),
                    alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: tokens.spacing.lg,
                      height: tokens.spacing.lg,
                      decoration: BoxDecoration(
                        color: widget.value ? tokens.colors.onPrimary : tokens.colors.surface,
                        shape: BoxShape.circle,
                      ),
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
