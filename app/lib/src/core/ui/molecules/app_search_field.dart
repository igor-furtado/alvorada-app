import 'package:flutter/material.dart';

import '../../theme/app_icons.dart';
import '../atoms/app_icon.dart';
import '../atoms/app_text_input.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.focusNode,
    this.placeholder = 'Buscar',
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
        : IconButton(
            tooltip: 'Limpar busca',
            onPressed: onClear,
            icon: const AppIcon(AppIcons.close, size: AppIconSize.sm),
          ),
  );
}
