import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_text_input.dart';

class AppFormField extends StatelessWidget {
  const AppFormField({
    required this.label,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.minLines = 1,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int minLines;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final description = errorText ?? helperText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(required ? '$label *' : label, style: Theme.of(context).textTheme.labelLarge),
        SizedBox(height: context.tokens.spacing.xs),
        AppTextInput(
          controller: controller,
          focusNode: focusNode,
          placeholder: placeholder,
          errorText: errorText,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          minLines: minLines,
          maxLines: maxLines,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          semanticLabel: label,
        ),
        if (description != null && errorText == null) ...[
          SizedBox(height: context.tokens.spacing.xxs),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
