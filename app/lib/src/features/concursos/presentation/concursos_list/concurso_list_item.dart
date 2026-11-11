import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/models/concurso.dart';
import '../concurso_formatters.dart';

enum ConcursoListItemMenuAction { details, prioritize, archive, delete }

class ConcursoListItem extends StatelessWidget {
  const ConcursoListItem({
    required this.concurso,
    required this.enabled,
    required this.onDetails,
    required this.onOpenEdital,
    required this.onPrioritize,
    required this.onArchive,
    required this.onDelete,
    required this.compact,
    super.key,
  });

  final Concurso concurso;
  final bool enabled;
  final VoidCallback onDetails;
  final VoidCallback onOpenEdital;
  final VoidCallback onPrioritize;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: enabled ? onDetails : null,
    padding: EdgeInsets.all(compact ? context.tokens.spacing.lg : context.tokens.spacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (concurso.prioritario) ...[
                    Text(
                      AppMessages.concursoPrioritario,
                      style: context.tokens.typography.labelSmall.copyWith(
                        color: context.tokens.colors.onSurfaceMuted,
                      ),
                    ),
                    SizedBox(height: context.tokens.spacing.xs),
                  ],
                  Text(concurso.instituicao, style: context.tokens.typography.headlineSmall),
                  SizedBox(height: context.tokens.spacing.xxs),
                  Text(concurso.cargo, style: context.tokens.typography.bodyMedium),
                ],
              ),
            ),
            SizedBox(width: context.tokens.spacing.sm),
            AppMenuButton<ConcursoListItemMenuAction>(
              icon: AppIcons.more,
              label: AppMessages.moreActions,
              enabled: enabled,
              onSelected: (action) => switch (action) {
                ConcursoListItemMenuAction.details => onDetails(),
                ConcursoListItemMenuAction.prioritize => onPrioritize(),
                ConcursoListItemMenuAction.archive => onArchive(),
                ConcursoListItemMenuAction.delete => onDelete(),
              },
              items: [
                const AppMenuItem(
                  value: ConcursoListItemMenuAction.details,
                  label: AppMessages.seeDetails,
                  icon: AppIcons.arrowRight,
                ),
                if (!concurso.prioritario)
                  const AppMenuItem(
                    value: ConcursoListItemMenuAction.prioritize,
                    label: AppMessages.definirConcursoPrioritario,
                    icon: AppIcons.concursos,
                  ),
                const AppMenuItem(value: ConcursoListItemMenuAction.archive, label: AppMessages.archive),
                const AppMenuItem(
                  value: ConcursoListItemMenuAction.delete,
                  label: AppMessages.delete,
                  icon: AppIcons.delete,
                  destructive: true,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: context.tokens.spacing.xl),
        Wrap(
          spacing: context.tokens.spacing.xxxl,
          runSpacing: context.tokens.spacing.md,
          children: [
            _LabelValue(AppMessages.exam, formatExamDate(concurso.dataProva)),
            _LabelValue(AppMessages.board, formatBoard(concurso.banca)),
          ],
        ),
        SizedBox(height: context.tokens.spacing.xl),
        const AppDivider(margin: EdgeInsets.zero),
        SizedBox(height: context.tokens.spacing.lg),
        _ConcursoProgress(value: concurso.progressoEdital),
        SizedBox(height: context.tokens.spacing.md),
        AppButton(
          label: AppMessages.openNotice,
          icon: AppIcons.arrowRight,
          variant: AppButtonVariant.outline,
          onPressed: enabled ? onOpenEdital : null,
        ),
      ],
    ),
  );
}

class _ConcursoProgress extends StatelessWidget {
  const _ConcursoProgress({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: Text(AppMessages.noticeProgress, style: context.tokens.typography.labelMedium)),
          SizedBox(width: context.tokens.spacing.md),
          Text('$value%', style: context.tokens.typography.labelMedium),
        ],
      ),
      SizedBox(height: context.tokens.spacing.sm),
      AppProgress(value: value / 100, semanticLabel: AppMessages.noticeProgress),
    ],
  );
}

class _LabelValue extends StatelessWidget {
  const _LabelValue(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.tokens.typography.labelSmall),
      SizedBox(height: context.tokens.spacing.xxs),
      Text(value, style: context.tokens.typography.bodyMedium),
    ],
  );
}
