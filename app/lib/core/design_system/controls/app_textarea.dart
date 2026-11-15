import 'package:flutter/material.dart';

import 'app_text_input.dart';

class AppTextarea extends StatelessWidget {
  const AppTextarea({
    this.controller,
    this.focusNode,
    this.placeholder,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.semanticLabel,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUnfocus,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final int minLines;
  final int maxLines;
  final String? semanticLabel;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => AppTextInput(
    controller: controller,
    focusNode: focusNode,
    placeholder: placeholder,
    errorText: errorText,
    enabled: enabled,
    autofocus: autofocus,
    minLines: minLines,
    maxLines: maxLines,
    semanticLabel: semanticLabel,
    validator: validator,
    autovalidateMode: autovalidateMode,
    onChanged: onChanged,
    keyboardType: TextInputType.multiline,
  );
}
