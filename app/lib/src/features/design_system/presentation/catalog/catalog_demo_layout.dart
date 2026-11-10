import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CatalogDemoGroup extends StatelessWidget {
  const CatalogDemoGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: context.tokens.spacing.xl),
    child: Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) SizedBox(height: context.tokens.spacing.xxxl),
        ],
      ],
    ),
  );
}

class CatalogDemoSection extends StatelessWidget {
  const CatalogDemoSection({
    required this.title,
    required this.description,
    required this.child,
    super.key,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: context.tokens.typography.titleMedium),
      SizedBox(height: context.tokens.spacing.xs),
      Text(
        description,
        style: context.tokens.typography.bodySmall.copyWith(
          color: context.tokens.colors.onSurfaceMuted,
        ),
      ),
      SizedBox(height: context.tokens.spacing.md),
      LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < context.tokens.layout.compact
              ? context.tokens.spacing.xxl
              : context.tokens.spacing.huge;
          return Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: context.tokens.sizes.overviewPanel),
            alignment: Alignment.center,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: context.tokens.colors.surface,
              border: Border.all(color: context.tokens.colors.border),
              borderRadius: context.tokens.borders.xl,
            ),
            child: child,
          );
        },
      ),
    ],
  );
}
