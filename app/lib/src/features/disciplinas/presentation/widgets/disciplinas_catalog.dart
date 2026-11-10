import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/models/disciplina.dart';

part 'disciplina_topicos_panel.dart';
part 'disciplinas_master_panel.dart';

enum _DisciplinaAction { rename, delete }

enum _TopicoAction { rename, delete }

enum _SubtopicoAction { rename, delete }

@immutable
class DisciplinasCatalogActions {
  const DisciplinasCatalogActions({
    required this.onAddDiscipline,
    required this.onSelectDisciplina,
    required this.onToggleTopico,
    required this.onAddTopico,
    required this.onRenameDisciplina,
    required this.onDeleteDisciplina,
    required this.onRenameTopico,
    required this.onDeleteTopico,
    required this.onAddSubtopico,
    required this.onRenameSubtopico,
    required this.onDeleteSubtopico,
  });

  final VoidCallback onAddDiscipline;
  final ValueChanged<Disciplina> onSelectDisciplina;
  final ValueChanged<Topico> onToggleTopico;
  final ValueChanged<Disciplina> onAddTopico;
  final ValueChanged<Disciplina> onRenameDisciplina;
  final ValueChanged<Disciplina> onDeleteDisciplina;
  final ValueChanged<Topico> onRenameTopico;
  final ValueChanged<Topico> onDeleteTopico;
  final ValueChanged<Topico> onAddSubtopico;
  final ValueChanged<Subtopico> onRenameSubtopico;
  final ValueChanged<Subtopico> onDeleteSubtopico;
}

class DisciplinasCatalog extends StatelessWidget {
  const DisciplinasCatalog({
    required this.query,
    required this.disciplinas,
    required this.selectedDisciplina,
    required this.expandedTopicIds,
    required this.canMutate,
    required this.actions,
    super.key,
  });

  final String query;
  final List<Disciplina> disciplinas;
  final Disciplina? selectedDisciplina;
  final Set<String> expandedTopicIds;
  final bool canMutate;
  final DisciplinasCatalogActions actions;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final master = _DisciplinasMasterPanel(
          disciplinas: disciplinas,
          selectedDisciplina: selectedDisciplina,
          horizontal: constraints.maxWidth < context.tokens.layout.contentSplit,
          canMutate: canMutate,
          onAdd: actions.onAddDiscipline,
          onSelect: actions.onSelectDisciplina,
          onRename: actions.onRenameDisciplina,
          onDelete: actions.onDeleteDisciplina,
        );
        final detail = selectedDisciplina == null
            ? Padding(
                padding: EdgeInsets.all(context.tokens.spacing.xxl),
                child: AppStateView(
                  variant: AppStateVariant.empty,
                  title: AppMessages.noContentFound,
                  actionLabel: query.trim().isNotEmpty ? null : AppMessages.addDiscipline,
                  onAction: query.trim().isNotEmpty || !canMutate ? null : actions.onAddDiscipline,
                ),
              )
            : _DisciplinaTopicosPanel(
                disciplina: selectedDisciplina!,
                canMutate: canMutate,
                expandedTopicIds: expandedTopicIds,
                onToggle: actions.onToggleTopico,
                onAddTopico: () => actions.onAddTopico(selectedDisciplina!),
                onRenameTopico: actions.onRenameTopico,
                onDeleteTopico: actions.onDeleteTopico,
                onAddSubtopico: actions.onAddSubtopico,
                onRenameSubtopico: actions.onRenameSubtopico,
                onDeleteSubtopico: actions.onDeleteSubtopico,
              );
        if (constraints.maxWidth < context.tokens.layout.contentSplit) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              master,
              const AppDivider(margin: EdgeInsets.zero),
              detail,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: context.tokens.layout.catalogMasterWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: context.tokens.layout.catalogWorkspaceHeight),
                child: master,
              ),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: context.tokens.layout.catalogWorkspaceHeight),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: context.tokens.colors.border),
                    ),
                  ),
                  child: detail,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
