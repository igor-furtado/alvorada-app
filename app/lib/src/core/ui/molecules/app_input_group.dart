import 'package:flutter/material.dart';

import '../atoms/app_text_input.dart';
import 'app_field.dart';

class AppInputGroup extends StatelessWidget {
  const AppInputGroup({
    this.label,
    this.controller,
    this.placeholder,
    this.leading,
    this.trailing,
    this.helperText,
    this.errorText,
    this.onChanged,
    super.key,
  });

  final String? label;
  final TextEditingController? controller;
  final String? placeholder;
  final Widget? leading;
  final Widget? trailing;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (label == null && helperText == null) {
      return AppTextInput(
        controller: controller,
        placeholder: placeholder,
        errorText: errorText,
        prefixIcon: leading,
        suffixIcon: trailing,
        onChanged: onChanged,
      );
    }
    return AppField(
      label: label ?? '',
      description: helperText,
      errorText: errorText,
      control: AppTextInput(
        controller: controller,
        placeholder: placeholder,
        errorText: errorText,
        prefixIcon: leading,
        suffixIcon: trailing,
        onChanged: onChanged,
        semanticLabel: label,
      ),
    );
  }
}
