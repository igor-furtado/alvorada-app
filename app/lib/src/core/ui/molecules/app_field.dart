import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

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
