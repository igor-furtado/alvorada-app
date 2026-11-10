import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../responsive/app_responsive.dart';

typedef AppPageContentBuilder = Widget Function(BuildContext context, bool desktop);

class AppPageTemplate extends StatelessWidget {
  const AppPageTemplate({required this.builder, this.maxWidth, super.key});

  final AppPageContentBuilder builder;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final desktop = context.windowClass.isExpanded;
    return SafeArea(
      top: false,
      child: CustomScrollView(
        key: PageStorageKey<String>(ModalRoute.of(context)?.settings.name ?? 'app-page'),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              desktop ? context.tokens.spacing.page : context.tokens.spacing.xl,
              desktop ? context.tokens.spacing.page : context.tokens.spacing.xl,
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
    );
  }
}
