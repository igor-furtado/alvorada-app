import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => RadioGroup<T>(
    groupValue: value,
    onChanged: onChanged ?? (_) {},
    child: Flex(
      direction: direction,
      children: [
        for (final option in options)
          InkWell(
            borderRadius: context.tokens.borders.md,
            onTap: onChanged == null ? null : () => onChanged!(option.value),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: context.tokens.layout.controlHeight),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppRadio<T>(value: option.value, semanticLabel: option.label, enabled: onChanged != null),
                  Flexible(child: Text(option.label)),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
