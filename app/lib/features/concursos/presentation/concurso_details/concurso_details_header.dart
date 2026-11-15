import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../concurso_view_data.dart';

class ConcursoDetailsHeader extends StatelessWidget {
  const ConcursoDetailsHeader({required this.concurso, super.key});

  final ConcursoViewData concurso;

  @override
  Widget build(BuildContext context) => AppBreadcrumbs(
    items: [
      AppBreadcrumbItem(label: context.l10n.navigationConcursos, route: '/concursos'),
      AppBreadcrumbItem(label: concurso.shortName),
    ],
  );
}

class ConcursoDetailsFacts extends StatelessWidget {
  const ConcursoDetailsFacts({required this.concurso, super.key});

  final ConcursoViewData concurso;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (concurso.isPrimary) ...[
        AppBadge(label: context.l10n.priority, variant: AppBadgeVariant.secondary),
        SizedBox(width: context.tokens.spacing.xl),
      ],
      _InlineFact(label: context.l10n.board, value: concurso.board),
      const _FactDot(),
      _InlineFact(label: context.l10n.exam, value: concurso.examDate),
      const _FactDot(),
      _InlineFact(label: context.l10n.location, value: concurso.examLocation),
    ],
  );
}

class _InlineFact extends StatelessWidget {
  const _InlineFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: '$label  ',
      children: [
        TextSpan(
          text: value,
          style: context.tokens.typography.labelLarge.copyWith(color: context.tokens.colors.onSurface),
        ),
      ],
    ),
    maxLines: 1,
    style: context.tokens.typography.bodySmall.copyWith(color: context.tokens.colors.onSurfaceMuted),
  );
}

class _FactDot extends StatelessWidget {
  const _FactDot();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.lg),
    child: Container(
      width: context.tokens.spacing.xxxs,
      height: context.tokens.spacing.xxxs,
      decoration: BoxDecoration(
        color: context.tokens.colors.onSurfaceMuted,
        borderRadius: context.tokens.borders.full,
      ),
    ),
  );
}
