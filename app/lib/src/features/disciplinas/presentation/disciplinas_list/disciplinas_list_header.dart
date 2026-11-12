import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';

class DisciplinasListHeader extends StatelessWidget {
  const DisciplinasListHeader({
    required this.searchController,
    required this.canAdd,
    required this.canRefresh,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onAdd,
    super.key,
  });

  final TextEditingController searchController;
  final bool canAdd;
  final bool canRefresh;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
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
      final actions = Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: context.tokens.spacing.sm,
        runSpacing: context.tokens.spacing.sm,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogNarrow),
            child: AppSearchField(
              controller: searchController,
              placeholder: AppMessages.searchContent,
              onChanged: onSearchChanged,
            ),
          ),
          AppAccessibleIconButton(
            icon: AppIcons.refresh,
            label: AppMessages.update,
            onPressed: canRefresh ? onRefresh : null,
          ),
          AppButton(
            label: AppMessages.newDiscipline,
            icon: AppIcons.add,
            onPressed: canAdd ? onAdd : null,
          ),
        ],
      );
      if (constraints.maxWidth < context.tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            SizedBox(height: context.tokens.spacing.xl),
            actions,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: heading),
          SizedBox(width: context.tokens.spacing.xxl),
          actions,
        ],
      );
    },
  );
}
