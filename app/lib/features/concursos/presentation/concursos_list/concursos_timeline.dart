import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/concurso.dart';
import 'concurso_timeline_item.dart';

const _compactRailWidth = 64.0;
const _expandedRailWidth = 112.0;
const _compactGap = 12.0;
const _expandedGap = 18.0;
const _timelineDotSize = 14.0;

typedef ConcursoAction = void Function(Concurso concurso);

class ConcursosTimelineActions {
  const ConcursosTimelineActions({
    required this.details,
    required this.openEdital,
    required this.edit,
    required this.prioritize,
    required this.archive,
    required this.delete,
  });

  final ConcursoAction details;
  final ConcursoAction openEdital;
  final ConcursoAction edit;
  final ConcursoAction prioritize;
  final ConcursoAction archive;
  final ConcursoAction delete;
}

class ConcursosTimeline extends StatelessWidget {
  const ConcursosTimeline({
    required this.concursos,
    required this.actions,
    required this.enabled,
    this.now,
    super.key,
  });

  final List<Concurso> concursos;
  final ConcursosTimelineActions actions;
  final bool enabled;
  final DateTime? now;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < context.tokens.layout.compact;
      final railWidth = compact ? _compactRailWidth : _expandedRailWidth;
      final gap = compact ? _compactGap : _expandedGap;
      final reference = now ?? DateTime.now();
      final nearestDays = concursos.map((item) => item.diasAteProva(reference)).whereType<int>().firstOrNull;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: railWidth,
                child: Text(
                  context.l10n.today.toUpperCase(),
                  textAlign: TextAlign.end,
                  style: context.tokens.typography.labelSmall,
                ),
              ),
              SizedBox(
                width: context.tokens.spacing.lg,
                child: const Center(child: _NowDot()),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Text(
                  nearestDays == null ? context.l10n.nextExamDateUndefined : context.l10n.nextExamIn(nearestDays),
                  style: context.tokens.typography.supportingText,
                ),
              ),
            ],
          ),
          for (var index = 0; index < concursos.length; index++)
            ConcursoTimelineItem(
              concurso: concursos[index],
              days: concursos[index].diasAteProva(reference),
              last: index == concursos.length - 1,
              railWidth: railWidth,
              gap: gap,
              compact: compact,
              enabled: enabled,
              onDetails: () => actions.details(concursos[index]),
              onOpenEdital: () => actions.openEdital(concursos[index]),
              onEdit: () => actions.edit(concursos[index]),
              onPrioritize: () => actions.prioritize(concursos[index]),
              onArchive: () => actions.archive(concursos[index]),
              onDelete: () => actions.delete(concursos[index]),
            ),
        ],
      );
    },
  );
}

class _NowDot extends StatelessWidget {
  const _NowDot();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: _timelineDotSize,
      height: _timelineDotSize,
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

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
