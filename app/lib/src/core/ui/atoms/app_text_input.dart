import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTextInput extends StatelessWidget {
  const AppTextInput({
    this.controller,
    this.focusNode,
    this.placeholder,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUnfocus,
    this.onChanged,
    this.onSubmitted,
    this.minLines = 1,
    this.maxLines = 1,
    this.semanticLabel,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool obscureText;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int minLines;
  final int? maxLines;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    textField: true,
    enabled: enabled,
    child: ShadInputFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      minLines: minLines,
      maxLines: obscureText ? 1 : maxLines,
      placeholder: placeholder == null ? null : Text(placeholder!),
      forceErrorText: errorText,
      leading: prefixIcon,
      trailing: suffixIcon,
    ),
  );
}
