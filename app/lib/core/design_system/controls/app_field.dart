import 'package:material_ui/material_ui.dart';

import '../app_tokens.dart';

enum AppFieldOrientation { vertical, horizontal }

class AppField extends StatelessWidget {
  const AppField({
    required this.label,
    required this.control,
    this.description,
    this.errorText,
    this.required = false,
    this.orientation = AppFieldOrientation.vertical,
    super.key,
  });

  final String label;
  final Widget control;
  final String? description;
  final String? errorText;
  final bool required;
  final AppFieldOrientation orientation;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final effectiveDescription = errorText ?? description;
    final label = Text(
      required ? '${this.label} *' : this.label,
      style: errorText == null ? tokens.typography.controlLabel : tokens.typography.controlLabelError,
    );
    final descriptionText = effectiveDescription == null
        ? null
        : Text(
            effectiveDescription,
            style: errorText == null ? tokens.typography.supportingText : tokens.typography.errorText,
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
        children: [
          content,
          SizedBox(width: tokens.spacing.md),
          control,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        label,
        SizedBox(height: tokens.spacing.xs),
        SizedBox(width: double.infinity, child: control),
        if (descriptionText != null) ...[
          SizedBox(height: tokens.spacing.xs),
          descriptionText,
        ],
      ],
    );
  }
}
