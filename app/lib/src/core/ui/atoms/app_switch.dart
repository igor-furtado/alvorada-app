import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({required this.value, required this.semanticLabel, this.onChanged, super.key});

  final bool value;
  final String semanticLabel;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    toggled: value,
    enabled: onChanged != null,
    child: ExcludeSemantics(
      child: Switch(value: value, onChanged: onChanged),
    ),
  );
}
