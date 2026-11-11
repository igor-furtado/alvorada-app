import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';

class DisciplinasListHeader extends StatelessWidget {
  const DisciplinasListHeader({
    required this.canAdd,
    required this.onAdd,
    super.key,
  });

  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppMessages.contentCatalog, style: context.tokens.typography.headlineLarge),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            AppMessages.contentCatalogSubtitle,
            style: context.tokens.typography.bodyLarge.copyWith(
              color: context.tokens.colors.onSurfaceMuted,
            ),
          ),
        ],
      );
      final action = AppButton(
        label: AppMessages.newDiscipline,
        icon: AppIcons.add,
        onPressed: canAdd ? onAdd : null,
      );
      if (constraints.maxWidth < context.tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            SizedBox(height: context.tokens.spacing.xl),
            action,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: heading),
          SizedBox(width: context.tokens.spacing.xxl),
          action,
        ],
      );
    },
  );
}
