import 'dart:math' as math;

import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/core/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/planejamento_semanal.dart';
import '../../domain/use_cases/semana_use_cases.dart';
import '../modo_foco/modo_foco_page.dart';
import 'semana_bloc.dart';
import 'semana_event.dart';
import 'semana_state.dart';

class SemanaPage extends StatelessWidget {
  const SemanaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<SemanaUseCases>();
    return BlocProvider(
      create: (_) => SemanaBloc(useCases: useCases)..add(const SemanaLoadRequested()),
      child: _SemanaContent(useCases: useCases),
    );
  }
}

class _SemanaContent extends StatelessWidget {
  const _SemanaContent({required this.useCases});

  final SemanaUseCases useCases;

  @override
  Widget build(BuildContext context) => BlocBuilder<SemanaBloc, SemanaState>(
    builder: (context, state) => SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth <= 620;
          final horizontalPadding = compact
              ? 14.0
              : constraints.maxWidth <= 900
              ? 20.0
              : 32.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              compact ? 20 : 32,
              horizontalPadding,
              compact ? 152 : 96,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: _WeekHeader(
                      compact: compact,
                      canAdd: state.status == SemanaStatus.success && state.disponiveis.isNotEmpty && !state.mutating,
                      onAdd: () => _addStudy(context, state),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: SizedBox(
                      width: double.infinity,
                      child: switch (state.status) {
                        SemanaStatus.initial || SemanaStatus.loading => const SizedBox(
                          height: 520,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        SemanaStatus.failure => AppStateView(
                          variant: AppStateVariant.error,
                          icon: AppIcons.error,
                          title: context.l10n.weekLoadFailed,
                          message: context.l10n.tryAgainLater,
                          actionLabel: context.l10n.tryAgain,
                          onAction: () => context.read<SemanaBloc>().add(const SemanaLoadRequested()),
                        ),
                        SemanaStatus.success => _WeekWorkspace(state: state, useCases: useCases),
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );

  Future<void> _addStudy(BuildContext context, SemanaState state) async {
    final selected = await showModalBottomSheet<TopicoDisponivelSemana>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => _AvailableTopicsSheet(items: state.disponiveis),
    );
    if (selected == null || !context.mounted) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = !today.isBefore(state.inicio) && !today.isAfter(state.fim) ? today : state.inicio;
    final result = await useCases.planejar(
      concursoId: selected.concursoId,
      topicoId: selected.topicoId,
      data: target,
    );
    if (!context.mounted) return;

    switch (result) {
      case Sucesso<void>():
        final item = ItemSemana(
          id: 'estudo:${selected.concursoId}:${selected.topicoId}',
          tipo: TipoItemSemana.estudoInicial,
          concursoId: selected.concursoId,
          concursoNome: selected.concursoNome,
          concursoSigla: selected.concursoSigla,
          topicoId: selected.topicoId,
          topicoNome: selected.topicoNome,
          disciplinaNome: selected.disciplinaNome,
          dataPlanejada: target,
          posicaoDia: 0,
          teoriaConcluida: false,
          memoriaConcluida: false,
          conferenciaConcluida: false,
          acertos: 0,
          erros: 0,
          versaoMetodologia: null,
          concluido: false,
          intervaloRevisaoDias: null,
        );
        await Navigator.of(context, rootNavigator: true).push<bool>(
          MaterialPageRoute(
            builder: (_) => ModoFocoPage(item: item, useCases: useCases),
          ),
        );
        if (context.mounted) context.read<SemanaBloc>().add(const SemanaLoadRequested());
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.weekOperationFailed)),
        );
    }
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.compact,
    required this.canAdd,
    required this.onAdd,
  });

  final bool compact;
  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.weekTitle,
          style: compact ? context.tokens.typography.weekPageTitleCompact : context.tokens.typography.weekPageTitle,
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.weekSubtitle,
          style: context.tokens.typography.weekPageDescription,
        ),
      ],
    );
    final action = _AddStudyButton(
      expanded: compact,
      onPressed: canAdd ? onAdd : null,
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [heading, const SizedBox(height: 20), action],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 24),
        action,
      ],
    );
  }
}

class _AddStudyButton extends StatelessWidget {
  const _AddStudyButton({required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: context.l10n.addStudy,
    child: Opacity(
      opacity: onPressed == null ? context.tokens.opacity.disabled : 1,
      child: Material(
        color: context.tokens.colors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: context.tokens.colors.primary),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: expanded ? double.infinity : null,
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.add, size: 16, color: context.tokens.colors.onPrimary),
                const SizedBox(width: 8),
                Text(context.l10n.addStudy, style: context.tokens.typography.weekPrimaryAction),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _WeekWorkspace extends StatelessWidget {
  const _WeekWorkspace({required this.state, required this.useCases});

  final SemanaState state;
  final SemanaUseCases useCases;

  @override
  Widget build(BuildContext context) {
    final concursos = _scheduledConcursos(state);
    final tones = <String, Color>{
      for (var index = 0; index < concursos.length; index++) concursos[index]: _contestTone(context, index),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Filters(state: state, concursos: concursos),
        const SizedBox(height: 12),
        _WeekToolbar(state: state, concursos: concursos),
        const SizedBox(height: 14),
        _WeekBoard(state: state, useCases: useCases, contestTones: tones),
      ],
    );
  }
}

List<String> _scheduledConcursos(SemanaState state) => <String>{
  for (final item in state.itens) item.concursoId,
}.toList(growable: false);

class _Filters extends StatelessWidget {
  const _Filters({required this.state, required this.concursos});

  final SemanaState state;
  final List<String> concursos;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final estimatedWidth = 12 + 148.0 * (concursos.length + 1) + 4.0 * concursos.length + 180;
      return Container(
        height: 62,
        decoration: BoxDecoration(
          color: context.tokens.colors.surface,
          border: Border.all(color: context.tokens.colors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            width: math.max(constraints.maxWidth - 14, estimatedWidth),
            child: Row(
              children: [
                _ContestFilterButton(
                  label: context.l10n.all,
                  detail: context.l10n.topicsCount(_topicCount()),
                  selected: state.concursoFiltro == null,
                  allTones: [
                    for (var index = 0; index < 3; index++) _contestTone(context, index),
                  ],
                  onPressed: () => context.read<SemanaBloc>().add(const SemanaConcursoFilterChanged(null)),
                ),
                for (var index = 0; index < concursos.length; index++) ...[
                  const SizedBox(width: 4),
                  _ContestFilterButton(
                    label: state.rotuloConcurso(concursos[index]),
                    detail: context.l10n.contestStudyDurationProgress(
                      _topicCount(concursos[index]) * 100,
                      _completionPercent(concursos[index]),
                    ),
                    selected: state.concursoFiltro == concursos[index],
                    tone: _contestTone(context, index),
                    onPressed: () => context.read<SemanaBloc>().add(
                      SemanaConcursoFilterChanged(concursos[index]),
                    ),
                  ),
                ],
                const Spacer(),
                _CompletedToggle(
                  selected: state.ocultarConcluidos,
                  onPressed: () => context.read<SemanaBloc>().add(const SemanaHideCompletedChanged()),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  int _topicCount([String? concursoId]) => <String>{
    for (final item in state.itens)
      if (item.tipo == TipoItemSemana.estudoInicial && (concursoId == null || item.concursoId == concursoId))
        '${item.concursoId}:${item.topicoId}',
  }.length;

  int _completionPercent(String concursoId) {
    final total = _topicCount(concursoId);
    if (total == 0) return 0;
    final completed = state.itens
        .where(
          (item) => item.tipo == TipoItemSemana.estudoInicial && item.concursoId == concursoId && item.concluido,
        )
        .length;
    return (completed * 100 / total).round();
  }
}

class _ContestFilterButton extends StatefulWidget {
  const _ContestFilterButton({
    required this.label,
    required this.detail,
    required this.selected,
    required this.onPressed,
    this.tone,
    this.allTones,
  });

  final String label;
  final String detail;
  final bool selected;
  final Color? tone;
  final List<Color>? allTones;
  final VoidCallback onPressed;

  @override
  State<_ContestFilterButton> createState() => _ContestFilterButtonState();
}

class _ContestFilterButtonState extends State<_ContestFilterButton> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final dot = widget.allTones == null
        ? DecoratedBox(
            decoration: BoxDecoration(color: widget.tone, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 8),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: _gradientColors(widget.allTones!)),
            ),
            child: const SizedBox.square(dimension: 8),
          );
    return Semantics(
      selected: selected,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => pressed = true),
          onTapUp: (_) => setState(() => pressed = false),
          onTapCancel: () => setState(() => pressed = false),
          child: AnimatedScale(
            scale: pressed && !context.reduceMotion ? .98 : 1,
            duration: context.motionDuration(context.tokens.motion.fast),
            child: AnimatedContainer(
              duration: context.motionDuration(context.tokens.motion.fast),
              width: 148,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? context.tokens.colors.primary
                    : hovered
                    ? context.tokens.colors.surfaceSubtle
                    : context.tokens.colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  dot,
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: selected
                              ? context.tokens.typography.weekFilterLabelSelected
                              : context.tokens.typography.weekFilterLabel,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: selected
                              ? context.tokens.typography.weekFilterDetailSelected
                              : context.tokens.typography.weekFilterDetail,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Color> _gradientColors(List<Color> tones) {
  if (tones.length == 1) return [tones.first, tones.first];
  final colors = <Color>[];
  for (final color in tones.take(3)) {
    colors
      ..add(color)
      ..add(color);
  }
  return colors;
}

class _CompletedToggle extends StatefulWidget {
  const _CompletedToggle({required this.selected, required this.onPressed});

  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_CompletedToggle> createState() => _CompletedToggleState();
}

class _CompletedToggleState extends State<_CompletedToggle> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: Material(
      color: context.tokens.colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(7),
        child: AnimatedContainer(
          duration: context.motionDuration(context.tokens.motion.fast),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.selected || hovered ? context.tokens.colors.surfaceSubtle : context.tokens.colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Icon(AppIcons.check, size: 15, color: context.tokens.colors.onSurfaceMuted),
              const SizedBox(width: 7),
              Text(
                widget.selected ? context.l10n.showCompleted : context.l10n.hideCompleted,
                style: widget.selected
                    ? context.tokens.typography.weekToggleLabelSelected
                    : context.tokens.typography.weekToggleLabel,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Color _contestTone(BuildContext context, int index) => switch (index % 3) {
  0 => Theme.of(context).brightness == Brightness.dark ? const Color(0xfffafafa) : const Color(0xff18181b),
  1 => const Color(0xff2563eb),
  _ => const Color(0xffd97706),
};

class _WeekToolbar extends StatelessWidget {
  const _WeekToolbar({required this.state, required this.concursos});

  final SemanaState state;
  final List<String> concursos;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final startDay = DateFormat('d', locale).format(state.inicio);
    final endDay = DateFormat('d', locale).format(state.fim);
    final endMonth = DateFormat('MMMM', locale).format(state.fim);
    final navigation = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WeekIconButton(
          tooltip: context.l10n.previousWeek,
          icon: AppIcons.chevronLeft,
          onPressed: state.mutating ? null : () => context.read<SemanaBloc>().add(const SemanaChanged(-1)),
        ),
        SizedBox(
          width: 176,
          child: Text(
            '$startDay a $endDay de $endMonth',
            textAlign: TextAlign.center,
            style: context.tokens.typography.weekToolbarLabel,
          ),
        ),
        _WeekIconButton(
          tooltip: context.l10n.nextWeek,
          icon: AppIcons.chevronRight,
          onPressed: state.mutating ? null : () => context.read<SemanaBloc>().add(const SemanaChanged(1)),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.tokens.colors.surface,
        border: Border.all(color: context.tokens.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) return Center(child: navigation);
          return Row(
            children: [
              navigation,
              const Spacer(),
              _ContestLegend(state: state, concursos: concursos),
            ],
          );
        },
      ),
    );
  }
}

class _WeekIconButton extends StatelessWidget {
  const _WeekIconButton({required this.tooltip, required this.icon, required this.onPressed});

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: context.tokens.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: context.tokens.colors.border),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox.square(
          dimension: 38,
          child: Icon(icon, size: 18, color: context.tokens.colors.onSurface),
        ),
      ),
    ),
  );
}

class _ContestLegend extends StatelessWidget {
  const _ContestLegend({required this.state, required this.concursos});

  final SemanaState state;
  final List<String> concursos;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < concursos.length; index++) ...[
        if (index > 0) const SizedBox(width: 14),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _contestTone(context, index), shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          state.rotuloConcurso(concursos[index]),
          style: context.tokens.typography.weekLegendLabel,
        ),
      ],
    ],
  );
}

class _WeekBoard extends StatelessWidget {
  const _WeekBoard({required this.state, required this.useCases, required this.contestTones});

  final SemanaState state;
  final SemanaUseCases useCases;
  final Map<String, Color> contestTones;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.only(bottom: 12),
    child: SizedBox(
      width: 1120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var day = 0; day < 7; day++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: day == 6 ? 0 : 8),
                child: _DayColumn(
                  date: state.inicio.add(Duration(days: day)),
                  items: _itemsForDay(state, day),
                  useCases: useCases,
                  contestTones: contestTones,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

List<ItemSemana> _itemsForDay(SemanaState state, int day) {
  final target = state.inicio.add(Duration(days: day));
  return state.itensVisiveis.where((item) => _sameDate(item.dataPlanejada, target)).toList(growable: false);
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.date,
    required this.items,
    required this.useCases,
    required this.contestTones,
  });

  final DateTime date;
  final List<ItemSemana> items;
  final SemanaUseCases useCases;
  final Map<String, Color> contestTones;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final initialCount = items.where((item) => item.tipo == TipoItemSemana.estudoInicial).length;
    final isToday = _sameDate(date, DateTime.now());
    return DragTarget<ItemSemana>(
      onAcceptWithDetails: (details) => context.read<SemanaBloc>().add(
        SemanaItemMoved(item: details.data, data: date),
      ),
      builder: (context, candidates, _) => AnimatedContainer(
        duration: context.motionDuration(context.tokens.motion.fast),
        constraints: const BoxConstraints(minHeight: 520),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: candidates.isNotEmpty
              ? context.tokens.colors.surfaceSubtle
              : Color.lerp(context.tokens.colors.surface, context.tokens.colors.canvas, .28),
          border: Border.all(
            color: isToday ? context.tokens.colors.controlOutline : context.tokens.colors.border,
            width: isToday ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _dayLabel(date, locale),
                            style: context.tokens.typography.weekDayLabel,
                          ),
                          TextSpan(
                            text: '  ${date.day}',
                            style: context.tokens.typography.weekDayDate,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${initialCount * 100} min',
                    style: context.tokens.typography.weekDayMeta,
                  ),
                ],
              ),
            ),
            if (items.isEmpty)
              _EmptySlot(label: context.l10n.noTopicsForDay)
            else
              for (var index = 0; index < items.length; index++) ...[
                _DraggableStudyCard(
                  item: items[index],
                  useCases: useCases,
                  tone: contestTones[items[index].concursoId] ?? context.tokens.colors.onSurfaceMuted,
                ),
                if (index < items.length - 1) const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _DraggableStudyCard extends StatelessWidget {
  const _DraggableStudyCard({required this.item, required this.useCases, required this.tone});

  final ItemSemana item;
  final SemanaUseCases useCases;
  final Color tone;

  @override
  Widget build(BuildContext context) => LongPressDraggable<ItemSemana>(
    data: item,
    feedback: Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 144,
        child: _StudyCard(item: item, useCases: useCases, tone: tone, dragging: true),
      ),
    ),
    childWhenDragging: Opacity(
      opacity: .45,
      child: _StudyCard(item: item, useCases: useCases, tone: tone),
    ),
    child: _StudyCard(item: item, useCases: useCases, tone: tone),
  );
}

class _StudyCard extends StatefulWidget {
  const _StudyCard({
    required this.item,
    required this.useCases,
    required this.tone,
    this.dragging = false,
  });

  final ItemSemana item;
  final SemanaUseCases useCases;
  final Color tone;
  final bool dragging;

  @override
  State<_StudyCard> createState() => _StudyCardState();
}

class _StudyCardState extends State<_StudyCard> {
  bool hovered = false;

  ItemSemana get item => widget.item;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: item.concluido ? .62 : 1,
    child: MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedSlide(
        offset: hovered && !context.reduceMotion ? const Offset(0, -.015) : Offset.zero,
        duration: context.motionDuration(context.tokens.motion.fast),
        child: AnimatedContainer(
          duration: context.motionDuration(context.tokens.motion.fast),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: hovered ? context.tokens.overlayShadow : const [],
          ),
          child: Material(
            color: context.tokens.colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: context.tokens.colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: item.tipo == TipoItemSemana.estudoInicial && !widget.dragging ? _openFocus : null,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 3,
                    child: ColoredBox(color: widget.tone),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: _ContestTag(label: item.rotuloConcurso, tone: widget.tone),
                            ),
                            const Spacer(),
                            Icon(AppIcons.reorder, size: 14, color: context.tokens.colors.onSurfaceMuted),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          item.disciplinaNome.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.tokens.typography.weekCardDiscipline,
                        ),
                        const SizedBox(height: 9),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 46),
                          child: Text(
                            item.topicoNome,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: item.concluido
                                ? context.tokens.typography.weekCardTitleCompleted
                                : context.tokens.typography.weekCardTitle,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (item.tipo == TipoItemSemana.revisao) ...[
                                    Flexible(
                                      child: Text(
                                        'D+${item.intervaloRevisaoDias}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.tokens.typography.weekCardMetaStrong,
                                      ),
                                    ),
                                  ] else ...[
                                    Icon(AppIcons.clock, size: 12, color: context.tokens.colors.onSurfaceMuted),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '100 min',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.tokens.typography.weekCardMeta,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            _CardAction(
                              completed: item.concluido,
                              review: item.tipo == TipoItemSemana.revisao,
                              onPressed: item.tipo == TipoItemSemana.revisao && !item.concluido
                                  ? () => context.read<SemanaBloc>().add(SemanaRevisaoConcluida(item.id))
                                  : item.tipo == TipoItemSemana.estudoInicial
                                  ? _openFocus
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _openFocus() async {
    await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => ModoFocoPage(item: item, useCases: widget.useCases),
      ),
    );
    if (mounted) context.read<SemanaBloc>().add(const SemanaLoadRequested());
  }
}

class _ContestTag extends StatelessWidget {
  const _ContestTag({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: context.tokens.colors.surfaceSubtle,
      borderRadius: context.tokens.borders.full,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.tokens.typography.weekTagLabel,
          ),
        ),
      ],
    ),
  );
}

class _CardAction extends StatelessWidget {
  const _CardAction({required this.completed, required this.review, required this.onPressed});

  final bool completed;
  final bool review;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: completed ? context.tokens.colors.primary : context.tokens.colors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: BorderSide(color: completed ? context.tokens.colors.primary : context.tokens.colors.controlOutline),
    ),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox.square(
        dimension: 24,
        child: Icon(
          completed || review ? AppIcons.check : AppIcons.play,
          size: completed ? 14 : 12,
          color: completed ? context.tokens.colors.onPrimary : context.tokens.colors.onSurface,
        ),
      ),
    ),
  );
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedRRectPainter(color: context.tokens.colors.border),
    child: SizedBox(
      height: 48,
      child: Center(
        child: Text(
          label,
          style: context.tokens.typography.weekEmptyLabel,
        ),
      ),
    ),
  );
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(7)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, math.min(distance + 5, metric.length)), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) => oldDelegate.color != color;
}

class _AvailableTopicsSheet extends StatelessWidget {
  const _AvailableTopicsSheet({required this.items});

  final List<TopicoDisponivelSemana> items;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .76),
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.addStudy, style: context.tokens.typography.headlineSmall),
            SizedBox(height: context.tokens.spacing.xs),
            Text(context.l10n.chooseTopicToStudy, style: context.tokens.typography.description),
            SizedBox(height: context.tokens.spacing.xxl),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: context.tokens.spacing.sm),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return AppCard(
                    onTap: () => Navigator.of(context).pop(item),
                    child: Row(
                      children: [
                        AppBadge(label: item.rotuloConcurso, variant: AppBadgeVariant.secondary),
                        SizedBox(width: context.tokens.spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.topicoNome, style: context.tokens.typography.contentTitle),
                              Text(item.disciplinaNome, style: context.tokens.typography.description),
                            ],
                          ),
                        ),
                        const Icon(AppIcons.arrowRight),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

bool _sameDate(DateTime left, DateTime right) =>
    left.year == right.year && left.month == right.month && left.day == right.day;

String _dayLabel(DateTime date, String locale) {
  final raw = DateFormat('EEE', locale).format(date).replaceAll('.', '');
  if (raw.isEmpty) return raw;
  return '${raw[0].toUpperCase()}${raw.substring(1)}';
}
