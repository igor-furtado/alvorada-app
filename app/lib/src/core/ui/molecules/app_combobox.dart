import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_text_input.dart';

class AppCombobox<T extends Object> extends StatelessWidget {
  const AppCombobox({
    required this.options,
    required this.displayStringForOption,
    this.initialValue,
    this.onSelected,
    this.placeholder,
    this.emptyMessage = 'Nenhum resultado encontrado.',
    super.key,
  });

  final List<T> options;
  final String Function(T option) displayStringForOption;
  final T? initialValue;
  final ValueChanged<T>? onSelected;
  final String? placeholder;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => RawAutocomplete<T>(
    initialValue: initialValue == null ? null : TextEditingValue(text: displayStringForOption(initialValue!)),
    displayStringForOption: displayStringForOption,
    optionsBuilder: (value) {
      final query = value.text.trim().toLowerCase();
      if (query.isEmpty) return options;
      return options.where((option) => displayStringForOption(option).toLowerCase().contains(query));
    },
    onSelected: onSelected,
    fieldViewBuilder: (context, controller, focusNode, onSubmitted) => AppTextInput(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: (_) => onSubmitted(),
      placeholder: placeholder,
      semanticLabel: placeholder,
      suffixIcon: Icon(AppIcons.expandMore, size: context.tokens.icons.md),
    ),
    optionsViewBuilder: (context, select, options) => Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: context.tokens.colors.popover,
        shape: RoundedRectangleBorder(
          borderRadius: context.tokens.borders.lg,
          side: BorderSide(color: context.tokens.colors.border),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: context.tokens.sizes.overviewPanel,
            maxWidth: context.tokens.layout.commandSearchWidth,
          ),
          child: options.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(context.tokens.spacing.lg),
                  child: Text(emptyMessage, style: context.tokens.typography.bodySmall),
                )
              : ListView(
                  padding: EdgeInsets.all(context.tokens.spacing.xxs),
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      ListTile(
                        dense: true,
                        title: Text(displayStringForOption(option)),
                        onTap: () => select(option),
                      ),
                  ],
                ),
        ),
      ),
    ),
  );
}
