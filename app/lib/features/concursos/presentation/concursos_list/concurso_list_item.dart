import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/concurso.dart';
import '../concurso_formatters.dart';

enum ConcursoListItemMenuAction { details, edit, prioritize, archive, delete }

class ConcursoListItem extends StatelessWidget {
  const ConcursoListItem({
    required this.concurso,
    required this.enabled,
    required this.onDetails,
    required this.onOpenEdital,
    required this.onEdit,
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
  final VoidCallback onEdit;
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
                      context.l10n.concursoPrioritario,
                      style: context.tokens.typography.overline,
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
              label: context.l10n.moreActions,
              enabled: enabled,
              onSelected: (action) => switch (action) {
                ConcursoListItemMenuAction.details => onDetails(),
                ConcursoListItemMenuAction.edit => onEdit(),
                ConcursoListItemMenuAction.prioritize => onPrioritize(),
                ConcursoListItemMenuAction.archive => onArchive(),
                ConcursoListItemMenuAction.delete => onDelete(),
              },
              items: [
                AppMenuItem(
                  value: ConcursoListItemMenuAction.details,
                  label: context.l10n.seeDetails,
                  icon: AppIcons.arrowRight,
                ),
                AppMenuItem(
                  value: ConcursoListItemMenuAction.edit,
                  label: context.l10n.editarConcurso,
                  icon: AppIcons.edit,
                ),
                if (!concurso.prioritario)
                  AppMenuItem(
                    value: ConcursoListItemMenuAction.prioritize,
                    label: context.l10n.definirConcursoPrioritario,
                    icon: AppIcons.concursos,
                  ),
                AppMenuItem(value: ConcursoListItemMenuAction.archive, label: context.l10n.archive),
                AppMenuItem(
                  value: ConcursoListItemMenuAction.delete,
                  label: context.l10n.delete,
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
            _LabelValue(context.l10n.exam, formatExamDate(concurso.dataProva, context.l10n)),
            _LabelValue(context.l10n.board, formatBoard(concurso.banca, context.l10n)),
          ],
        ),
        SizedBox(height: context.tokens.spacing.xl),
        const AppDivider(margin: EdgeInsets.zero),
        SizedBox(height: context.tokens.spacing.lg),
        _ConcursoProgress(value: concurso.progressoEdital),
        SizedBox(height: context.tokens.spacing.md),
        AppButton(
          label: context.l10n.openNotice,
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
          Expanded(child: Text(context.l10n.noticeProgress, style: context.tokens.typography.labelMedium)),
          SizedBox(width: context.tokens.spacing.md),
          Text('$value%', style: context.tokens.typography.labelMedium),
        ],
      ),
      SizedBox(height: context.tokens.spacing.sm),
      AppProgress(value: value / 100, semanticLabel: context.l10n.noticeProgress),
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
