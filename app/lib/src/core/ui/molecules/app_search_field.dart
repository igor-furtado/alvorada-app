import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_icons.dart';
import '../atoms/app_accessible_icon_button.dart';
import '../atoms/app_icon.dart';
import '../atoms/app_text_input.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.focusNode,
    this.placeholder = AppMessages.search,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) => AppTextInput(
    controller: controller,
    focusNode: focusNode,
    placeholder: placeholder,
    enabled: enabled,
    textInputAction: TextInputAction.search,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    semanticLabel: placeholder,
    prefixIcon: const AppIcon(AppIcons.search, size: AppIconSize.sm),
    suffixIcon: onClear == null
        ? null
        : AppAccessibleIconButton(
            label: AppMessages.clearSearch,
            onPressed: onClear,
            icon: AppIcons.close,
          ),
  );
}
