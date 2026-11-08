import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    checked: value,
    enabled: onChanged != null,
    child: ExcludeSemantics(
      child: Checkbox(value: value, onChanged: onChanged, tristate: tristate),
    ),
  );
}
