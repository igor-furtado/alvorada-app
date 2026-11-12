import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/concurso.dart';
import 'concurso_timeline_item.dart';

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
      final railWidth = compact
          ? context.tokens.layout.timelineRailCompact
          : context.tokens.layout.timelineRailExpanded;
      final gap = compact ? context.tokens.layout.timelineGapCompact : context.tokens.layout.timelineGapExpanded;
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
                  AppMessages.today.toUpperCase(),
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
                  nearestDays == null
                      ? 'A próxima prova ainda não tem data definida'
                      : AppMessages.nextExamIn(nearestDays),
                  style: context.tokens.typography.bodySmall.copyWith(
                    color: context.tokens.colors.onSurfaceMuted,
                  ),
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

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
