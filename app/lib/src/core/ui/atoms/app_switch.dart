import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({required this.value, required this.semanticLabel, this.onChanged, super.key});

  final bool value;
  final String semanticLabel;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      label: semanticLabel,
      child: Switch(value: value, onChanged: onChanged),
    ),
  );
}
