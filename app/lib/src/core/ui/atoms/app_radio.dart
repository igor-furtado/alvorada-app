import 'package:flutter/material.dart';

class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    required this.value,
    required this.groupValue,
    required this.semanticLabel,
    this.onChanged,
    this.toggleable = false,
    super.key,
  });

  final T value;
  final T? groupValue;
  final String semanticLabel;
  final ValueChanged<T?>? onChanged;
  final bool toggleable;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    checked: value == groupValue,
    enabled: onChanged != null,
    inMutuallyExclusiveGroup: true,
    child: ExcludeSemantics(
      child: RadioGroup<T>(
        groupValue: groupValue,
        onChanged: onChanged ?? (_) {},
        child: Radio<T>(
          value: value,
          enabled: onChanged != null,
          toggleable: toggleable,
        ),
      ),
    ),
  );
}
