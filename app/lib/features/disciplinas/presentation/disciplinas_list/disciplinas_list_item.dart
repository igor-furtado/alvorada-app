import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'disciplinas_list_state.dart';

class DisciplinaListItem extends StatelessWidget {
  const DisciplinaListItem({
    required this.disciplina,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final DisciplinaListItemData disciplina;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = _parseHexColor(disciplina.color, tokens.colors.onSurfaceMuted);
    return Semantics(
      button: true,
      selected: selected,
      label: '${disciplina.name}, ${context.l10n.topicCountShort(disciplina.topicCount)}',
      onTap: onSelect,
      excludeSemantics: true,
      child: Material(
        color: selected ? tokens.colors.surfaceSubtle : tokens.colors.transparent,
        borderRadius: tokens.borders.lg,
        child: InkWell(
          onTap: onSelect,
          borderRadius: tokens.borders.lg,
          hoverColor: tokens.colors.surfaceSubtle,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disciplina.name,
                        style: selected ? tokens.typography.disciplineSelected : tokens.typography.disciplineUnselected,
                      ),
                      SizedBox(height: tokens.spacing.xxxs),
                      Text(
                        context.l10n.topicCountShort(disciplina.topicCount),
                        style: tokens.typography.supportingText,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.spacing.sm),
                const Icon(AppIcons.chevronRight, size: 17),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _parseHexColor(String value, Color fallback) {
  final normalized = value.replaceFirst('#', '');
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null || (normalized.length != 6 && normalized.length != 8)) return fallback;
  return Color(normalized.length == 6 ? 0xff000000 | parsed : parsed);
}
