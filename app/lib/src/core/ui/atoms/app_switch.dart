import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({required this.value, required this.semanticLabel, this.onChanged, super.key});

  final bool value;
  final String semanticLabel;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          width: context.tokens.layout.controlHeight,
          height: context.tokens.layout.controlHeight,
        ),
        child: Center(
          child: ShadSwitch(
            value: value,
            enabled: onChanged != null,
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  );
}
