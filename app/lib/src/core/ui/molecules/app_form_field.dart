import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_divider.dart';
import '../atoms/app_text_input.dart';

enum AppFieldOrientation { vertical, horizontal }

enum AppFieldControlPlacement { leading, trailing }

enum AppFieldDescriptionPlacement { beforeControl, afterControl }

class AppField extends StatelessWidget {
  const AppField({
    required this.label,
    required this.control,
    this.description,
    this.errorText,
    this.required = false,
    this.orientation = AppFieldOrientation.vertical,
    this.controlPlacement = AppFieldControlPlacement.trailing,
    this.descriptionPlacement = AppFieldDescriptionPlacement.afterControl,
    super.key,
  });

  final String label;
  final Widget control;
  final String? description;
  final String? errorText;
  final bool required;
  final AppFieldOrientation orientation;
  final AppFieldControlPlacement controlPlacement;
  final AppFieldDescriptionPlacement descriptionPlacement;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final effectiveDescription = errorText ?? description;
    final label = Text(
      required ? '${this.label} *' : this.label,
      style: tokens.typography.labelLarge.copyWith(
        color: errorText == null ? tokens.colors.onSurface : tokens.colors.error,
      ),
    );
    final descriptionText = effectiveDescription == null
        ? null
        : Text(
            effectiveDescription,
            style: tokens.typography.bodySmall.copyWith(
              color: errorText == null ? tokens.colors.onSurfaceMuted : tokens.colors.error,
            ),
          );

    if (orientation == AppFieldOrientation.horizontal) {
      final content = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            label,
            if (descriptionText != null) ...[
              SizedBox(height: tokens.spacing.xxs),
              descriptionText,
            ],
          ],
        ),
      );
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controlPlacement == AppFieldControlPlacement.leading
            ? [control, SizedBox(width: tokens.spacing.sm), content]
            : [content, SizedBox(width: tokens.spacing.md), control],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        label,
        if (descriptionText != null && descriptionPlacement == AppFieldDescriptionPlacement.beforeControl) ...[
          SizedBox(height: tokens.spacing.xxs),
          descriptionText,
        ],
        SizedBox(height: tokens.spacing.xs),
        SizedBox(width: double.infinity, child: control),
        if (descriptionText != null && descriptionPlacement == AppFieldDescriptionPlacement.afterControl) ...[
          SizedBox(height: tokens.spacing.xs),
          descriptionText,
        ],
      ],
    );
  }
}

class AppFieldGroup extends StatelessWidget {
  const AppFieldGroup({required this.children, this.spacing, super.key});

  final List<Widget> children;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? context.tokens.spacing.lg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class AppFieldset extends StatelessWidget {
  const AppFieldset({required this.legend, required this.child, this.description, super.key});

  final String legend;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: legend,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(legend, style: context.tokens.typography.titleSmall),
        if (description != null) ...[
          SizedBox(height: context.tokens.spacing.xxs),
          Text(
            description!,
            style: context.tokens.typography.bodySmall.copyWith(
              color: context.tokens.colors.onSurfaceMuted,
            ),
          ),
        ],
        SizedBox(height: context.tokens.spacing.lg),
        child,
      ],
    ),
  );
}

class AppFieldSeparator extends StatelessWidget {
  const AppFieldSeparator({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.xs),
    child: const AppDivider(),
  );
}

class AppFormField extends StatelessWidget {
  const AppFormField({
    required this.label,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUnfocus,
    this.onChanged,
    this.onSubmitted,
    this.minLines = 1,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.descriptionPlacement = AppFieldDescriptionPlacement.afterControl,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int minLines;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final AppFieldDescriptionPlacement descriptionPlacement;

  @override
  Widget build(BuildContext context) => AppField(
    label: label,
    description: helperText,
    errorText: errorText,
    required: required,
    descriptionPlacement: descriptionPlacement,
    control: AppTextInput(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      errorText: errorText,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      minLines: minLines,
      maxLines: maxLines,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      semanticLabel: required ? '$label, ${AppMessages.requiredSuffix}' : label,
    ),
  );
}
