import 'package:material_ui/material_ui.dart';

import '../app_icons.dart';
import '../design_system_localizations.dart';
import 'app_accessible_icon_button.dart';
import 'app_icon.dart';
import 'app_text_input.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.focusNode,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectivePlaceholder = placeholder ?? context.l10n.search;
    return AppTextInput(
      controller: controller,
      focusNode: focusNode,
      placeholder: effectivePlaceholder,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      semanticLabel: effectivePlaceholder,
      prefixIcon: const AppIcon(AppIcons.search, size: AppIconSize.sm),
      suffixIcon: onClear == null
          ? null
          : AppAccessibleIconButton(
              label: context.l10n.clearSearch,
              onPressed: onClear,
              icon: AppIcons.close,
            ),
    );
  }
}
