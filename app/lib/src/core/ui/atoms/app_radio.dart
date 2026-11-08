import 'package:flutter/material.dart';

class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    required this.value,
    required this.semanticLabel,
    this.enabled = true,
    this.toggleable = false,
    super.key,
  });

  final T value;
  final String semanticLabel;
  final bool enabled;
  final bool toggleable;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      label: semanticLabel,
      inMutuallyExclusiveGroup: true,
      child: Radio<T>(value: value, enabled: enabled, toggleable: toggleable),
    ),
  );
}
