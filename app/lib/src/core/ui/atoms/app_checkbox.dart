import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';

class AppCheckbox extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final checkbox = tristate
        ? Checkbox(value: value, onChanged: onChanged, tristate: true)
        : ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: context.tokens.layout.controlHeight,
              height: context.tokens.layout.controlHeight,
            ),
            child: Center(
              child: ShadCheckbox(
                value: value ?? false,
                enabled: onChanged != null,
                onChanged: onChanged == null ? null : (next) => onChanged!(next),
              ),
            ),
          );
    return MergeSemantics(
      child: Semantics(label: semanticLabel, child: checkbox),
    );
  }
}
