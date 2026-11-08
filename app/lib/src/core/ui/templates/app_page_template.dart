import 'package:flutter/material.dart';

import '../../presentation/app_shell.dart';
import '../../theme/app_theme.dart';

typedef AppPageContentBuilder = Widget Function(BuildContext context, bool desktop);

class AppPageTemplate extends StatelessWidget {
  const AppPageTemplate({required this.section, required this.builder, this.maxWidth, super.key});

  final AppSection section;
  final AppPageContentBuilder builder;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) => AppShell(
    section: section,
    builder: (context, desktop) => SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              desktop ? context.tokens.spacing.page : context.tokens.spacing.xl,
              context.tokens.spacing.xl,
              desktop ? context.tokens.spacing.page : context.tokens.spacing.xl,
              context.tokens.spacing.huge,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth ?? context.tokens.layout.contentMaxWidth),
                  child: builder(context, desktop),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
