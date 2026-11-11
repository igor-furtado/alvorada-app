import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';

class TopicosListHeader extends StatelessWidget {
  const TopicosListHeader({
    required this.canAdd,
    required this.onAdd,
    super.key,
  });

  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final title = Text(
        AppMessages.topics,
        style: context.tokens.typography.titleLarge,
      );
      final action = AppButton(
        label: AppMessages.addTopic,
        icon: AppIcons.add,
        variant: AppButtonVariant.outline,
        onPressed: canAdd ? onAdd : null,
      );
      if (constraints.maxWidth < context.tokens.layout.narrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            title,
            SizedBox(height: context.tokens.spacing.sm),
            Align(alignment: Alignment.centerRight, child: action),
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: title),
          SizedBox(width: context.tokens.spacing.lg),
          action,
        ],
      );
    },
  );
}
