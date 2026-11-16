import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../disciplinas_list/disciplinas_list_state.dart';
import '../disciplinas_localizations.dart';

enum _DisciplineAction { edit, delete }

class TopicosListHeader extends StatelessWidget {
  const TopicosListHeader({
    required this.disciplina,
    required this.canAdd,
    required this.canMutateDiscipline,
    required this.onAdd,
    required this.onRenameDiscipline,
    required this.onDeleteDiscipline,
    super.key,
  });

  final DisciplinaListItemData disciplina;
  final bool canAdd;
  final bool canMutateDiscipline;
  final VoidCallback onAdd;
  final VoidCallback? onRenameDiscipline;
  final VoidCallback? onDeleteDiscipline;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final tokens = context.tokens;
      final disciplineColor = _parseHexColor(
        disciplina.color,
        tokens.colors.onSurfaceMuted,
      );
      final heading = Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: disciplineColor.withValues(alpha: .12),
              borderRadius: tokens.borders.lg,
            ),
            child: Icon(AppIcons.bookText, color: disciplineColor, size: 21),
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disciplina.name,
                  style: tokens.typography.headlineSmall,
                ),
                SizedBox(height: tokens.spacing.xxxs),
                Text(
                  context.l10n.catalogDisciplineSummary(
                    disciplina.topicCount,
                    context.l10n.disciplineDifficulty(disciplina.difficulty),
                  ),
                  style: tokens.typography.supportingText,
                ),
              ],
            ),
          ),
        ],
      );
      final editMenu = AppMenuButton<_DisciplineAction>(
        icon: AppIcons.edit,
        label: context.l10n.editDiscipline,
        enabled: canMutateDiscipline,
        onSelected: (action) {
          switch (action) {
            case _DisciplineAction.edit:
              onRenameDiscipline?.call();
            case _DisciplineAction.delete:
              onDeleteDiscipline?.call();
          }
        },
        items: [
          AppMenuItem(
            value: _DisciplineAction.edit,
            label: context.l10n.editDiscipline,
            icon: AppIcons.edit,
          ),
          AppMenuItem(
            value: _DisciplineAction.delete,
            label: context.l10n.deleteDiscipline,
            icon: AppIcons.delete,
            destructive: true,
          ),
        ],
      );
      final addButton = AppButton(
        label: context.l10n.newTopic,
        icon: AppIcons.add,
        onPressed: canAdd ? onAdd : null,
      );
      if (constraints.maxWidth < tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            SizedBox(height: tokens.spacing.md),
            Row(
              children: [
                editMenu,
                SizedBox(width: tokens.spacing.xs),
                Expanded(child: addButton),
              ],
            ),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: heading),
          SizedBox(width: tokens.spacing.lg),
          editMenu,
          SizedBox(width: tokens.spacing.xs),
          addButton,
        ],
      );
    },
  );
}

Color _parseHexColor(String value, Color fallback) {
  final normalized = value.replaceFirst('#', '');
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null || (normalized.length != 6 && normalized.length != 8)) return fallback;
  return Color(normalized.length == 6 ? 0xff000000 | parsed : parsed);
}
