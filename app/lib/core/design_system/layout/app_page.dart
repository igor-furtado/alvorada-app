import 'package:flutter/material.dart';

import '../app_tokens.dart';
import 'app_responsive.dart';

/// Estrutura de página que mantém cabeçalho, margens e reflow consistentes.
class AppPage extends StatelessWidget {
  const AppPage.scroll({
    required this.title,
    required this.description,
    required this.child,
    this.headerLeading,
    this.headerAction,
    this.maxWidth,
    super.key,
  }) : _fillsViewport = false;

  const AppPage.workspace({
    required this.title,
    required this.description,
    required this.child,
    this.headerLeading,
    this.headerAction,
    this.maxWidth,
    super.key,
  }) : _fillsViewport = true;

  final String title;
  final String description;
  final Widget? headerLeading;
  final Widget? headerAction;
  final Widget child;
  final double? maxWidth;
  final bool _fillsViewport;

  @override
  Widget build(BuildContext context) {
    final content = _PageContent(
      title: title,
      description: description,
      headerLeading: headerLeading,
      headerAction: headerAction,
      fillsViewport: _fillsViewport,
      child: child,
    );
    return SafeArea(
      top: false,
      child: ResponsiveBuilder(
        builder: (context, windowClass) {
          final spacing = context.tokens.spacing;
          final padding = windowClass.isExpanded ? spacing.page : spacing.xl;
          final constrained = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth ?? context.tokens.layout.contentMaxWidth),
              child: content,
            ),
          );
          if (_fillsViewport) {
            return Padding(
              padding: EdgeInsets.fromLTRB(padding, padding, padding, spacing.huge),
              child: constrained,
            );
          }
          return SingleChildScrollView(
            key: PageStorageKey<String>(ModalRoute.of(context)?.settings.name ?? title),
            padding: EdgeInsets.fromLTRB(padding, padding, padding, spacing.huge),
            child: constrained,
          );
        },
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.title,
    required this.description,
    required this.headerLeading,
    required this.headerAction,
    required this.child,
    required this.fillsViewport,
  });

  final String title;
  final String description;
  final Widget? headerLeading;
  final Widget? headerAction;
  final Widget child;
  final bool fillsViewport;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerLeading != null) ...[
          headerLeading!,
          SizedBox(height: context.tokens.spacing.lg),
        ],
        Text(title, style: context.tokens.typography.headlineLarge),
        SizedBox(height: context.tokens.spacing.xs),
        Text(
          description,
          style: context.tokens.typography.bodyLarge.copyWith(color: context.tokens.colors.onSurfaceMuted),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = headerAction != null && constraints.maxWidth < context.tokens.layout.toolbar;
        final header = stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  heading,
                  SizedBox(height: context.tokens.spacing.xl),
                  headerAction!,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: heading),
                  if (headerAction != null) ...[
                    SizedBox(width: context.tokens.spacing.xxl),
                    Flexible(child: headerAction!),
                  ],
                ],
              );
        final headerChildren = <Widget>[
          RepaintBoundary(child: header),
          SizedBox(height: context.tokens.spacing.xxxl),
        ];
        if (fillsViewport) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...headerChildren,
              Expanded(child: child),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [...headerChildren, child],
        );
      },
    );
  }
}
