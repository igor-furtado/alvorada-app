import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';

class AdministrationPage extends StatelessWidget {
  const AdministrationPage({super.key});

  @override
  Widget build(BuildContext context) => AppPageTemplate(
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppMessages.administration,
          style: context.tokens.typography.headlineMedium,
        ),
        SizedBox(height: context.tokens.spacing.sm),
        Text(
          AppMessages.administrationSubtitle,
          style: context.tokens.typography.bodyLarge.copyWith(
            color: context.tokens.colors.onSurfaceMuted,
          ),
        ),
        SizedBox(height: context.tokens.spacing.xxl),
        AppListItem(
          key: const ValueKey('administration-component-catalog'),
          title: AppMessages.componentCatalog,
          subtitle: AppMessages.componentCatalogSubtitle,
          leadingIcon: AppIcons.settings,
          trailing: const AppIcon(
            AppIcons.chevronRight,
            semanticLabel: AppMessages.componentCatalog,
          ),
          onTap: () => context.go('/administracao/componentes'),
        ),
      ],
    ),
  );
}
