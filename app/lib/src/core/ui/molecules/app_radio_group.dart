import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_radio.dart';

@immutable
class AppRadioOption<T> {
  const AppRadioOption({required this.value, required this.label});

  final T value;
  final String label;
}

class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    required this.options,
    required this.value,
    this.onChanged,
    this.direction = Axis.vertical,
    super.key,
  });

  final List<AppRadioOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Axis direction;

  @override
  Widget build(BuildContext context) => ShadRadioGroup<T>(
    initialValue: value,
    onChanged: onChanged,
    enabled: onChanged != null,
    axis: direction,
    spacing: context.tokens.spacing.xs,
    items: [
      for (final option in options)
        AppRadio<T>(
          value: option.value,
          semanticLabel: option.label,
          enabled: onChanged != null,
          label: Text(option.label),
        ),
    ],
  );
}
