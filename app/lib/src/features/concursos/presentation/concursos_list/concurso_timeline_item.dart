import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/concurso.dart';
import 'concurso_list_item.dart';

class ConcursoTimelineItem extends StatelessWidget {
  const ConcursoTimelineItem({
    required this.concurso,
    required this.days,
    required this.last,
    required this.railWidth,
    required this.gap,
    required this.compact,
    required this.enabled,
    required this.onDetails,
    required this.onOpenEdital,
    required this.onPrioritize,
    required this.onArchive,
    required this.onDelete,
    super.key,
  });

  final Concurso concurso;
  final int? days;
  final bool last;
  final double railWidth;
  final double gap;
  final bool compact;
  final bool enabled;
  final VoidCallback onDetails;
  final VoidCallback onOpenEdital;
  final VoidCallback onPrioritize;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: railWidth,
          child: Padding(
            padding: EdgeInsets.only(
              top: context.tokens.spacing.page,
              right: compact ? context.tokens.spacing.sm : context.tokens.spacing.xl,
            ),
            child: _Deadline(days: days, compact: compact),
          ),
        ),
        SizedBox(
          width: context.tokens.spacing.lg,
          child: Column(
            children: [
              const Expanded(child: _TimelineLine()),
              const _TimelineDot(),
              Expanded(child: last ? const SizedBox() : const _TimelineLine()),
            ],
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.xl),
            child: ConcursoListItem(
              concurso: concurso,
              enabled: enabled,
              compact: compact,
              onDetails: onDetails,
              onOpenEdital: onOpenEdital,
              onPrioritize: onPrioritize,
              onArchive: onArchive,
              onDelete: onDelete,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Deadline extends StatelessWidget {
  const _Deadline({required this.days, required this.compact});

  final int? days;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final value = days;
    if (value == null) {
      return Text(
        AppMessages.toBeDefined,
        textAlign: TextAlign.end,
        style: context.tokens.typography.bodySmall.copyWith(color: context.tokens.colors.onSurfaceMuted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$value',
          style: compact ? context.tokens.typography.titleLarge : context.tokens.typography.headlineMedium,
        ),
        Text(AppMessages.days, style: context.tokens.typography.bodySmall),
      ],
    );
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: context.tokens.sizes.progressLine,
      color: context.tokens.colors.border,
    ),
  );
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: context.tokens.sizes.dotLg,
      height: context.tokens.sizes.dotLg,
      decoration: BoxDecoration(
        color: context.tokens.colors.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.tokens.colors.surface,
          width: context.tokens.borders.widthStrong,
        ),
      ),
    ),
  );
}
