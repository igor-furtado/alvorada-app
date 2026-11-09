import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';

class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    required this.value,
    required this.semanticLabel,
    this.enabled = true,
    this.toggleable = false,
    this.label,
    super.key,
  });

  final T value;
  final String semanticLabel;
  final bool enabled;
  final bool toggleable;
  final Widget? label;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      label: semanticLabel,
      inMutuallyExclusiveGroup: true,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          width: context.tokens.layout.controlHeight,
          height: context.tokens.layout.controlHeight,
        ),
        child: Center(
          child: ShadRadio<T>(
            value: value,
            enabled: enabled,
            label: label,
          ),
        ),
      ),
    ),
  );
}
