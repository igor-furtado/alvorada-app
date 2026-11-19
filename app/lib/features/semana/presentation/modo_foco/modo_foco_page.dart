import 'dart:async';

import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/core/result.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/planejamento_semanal.dart';
import '../../domain/use_cases/semana_use_cases.dart';

class ModoFocoPage extends StatefulWidget {
  const ModoFocoPage({required this.item, required this.useCases, super.key});

  final ItemSemana item;
  final SemanaUseCases useCases;

  @override
  State<ModoFocoPage> createState() => _ModoFocoPageState();
}

class _ModoFocoPageState extends State<ModoFocoPage> {
  late ItemSemana _item;
  final _remaining = <int, int>{0: 40 * 60, 1: 5 * 60, 2: 15 * 60, 3: 40 * 60};
  final _selectedReviews = <int>{};
  Timer? _timer;
  int _step = 0;
  int? _runningStep;
  bool _busy = false;
  bool _reviewsSaved = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _step = _firstPendingStep();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _firstPendingStep() {
    if (!_item.teoriaConcluida) return 0;
    if (!_item.memoriaConcluida) return 1;
    if (!_item.conferenciaConcluida) return 2;
    return 3;
  }

  void _selectStep(int step) {
    if (_runningStep != null && _runningStep != step) {
      _timer?.cancel();
      _timer = null;
      _runningStep = null;
    }
    setState(() => _step = step);
  }

  void _toggleTimer() {
    if (_runningStep == _step) {
      _stopTimer();
      return;
    }
    _timer?.cancel();
    setState(() => _runningStep = _step);
    final activeStep = _step;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final value = _remaining[activeStep] ?? 0;
      if (value <= 1) {
        _stopTimer();
        setState(() => _remaining[activeStep] = 0);
        return;
      }
      setState(() => _remaining[activeStep] = value - 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _runningStep = null);
  }

  Future<void> _completeCurrentStage() async {
    if (_step > 2 || _busy) return;
    final input = switch (_step) {
      0 => const ProgressoTopicoInput(teoriaConcluida: true),
      1 => const ProgressoTopicoInput(memoriaConcluida: true),
      _ => const ProgressoTopicoInput(conferenciaConcluida: true),
    };
    setState(() => _busy = true);
    final result = await widget.useCases.atualizarProgresso(
      concursoId: _item.concursoId,
      topicoId: _item.topicoId,
      input: input,
    );
    if (!mounted) return;
    switch (result) {
      case Sucesso<void>():
        final teoria = _item.teoriaConcluida || _step == 0;
        final memoria = _item.memoriaConcluida || _step == 1;
        final conferencia = _item.conferenciaConcluida || _step == 2;
        setState(() {
          _item = _item.copyWith(
            teoriaConcluida: teoria,
            memoriaConcluida: memoria,
            conferenciaConcluida: conferencia,
            concluido: teoria && memoria && conferencia,
          );
          _busy = false;
          if (_step < 3) _step++;
        });
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        setState(() => _busy = false);
        _showFailure();
    }
  }

  Future<void> _registerAnswer(ResultadoQuestao result) async {
    if (_busy || _runningStep != 3) return;
    setState(() => _busy = true);
    final response = await widget.useCases.registrarQuestao(
      concursoId: _item.concursoId,
      topicoId: _item.topicoId,
      resultado: result,
    );
    if (!mounted) return;
    switch (response) {
      case Sucesso<void>():
        setState(() {
          _item = result == ResultadoQuestao.certa
              ? _item.copyWith(acertos: _item.acertos + 1)
              : _item.copyWith(erros: _item.erros + 1);
          _busy = false;
        });
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        setState(() => _busy = false);
        _showFailure();
    }
  }

  Future<void> _saveReviews() async {
    if (!_item.concluido || _busy) return;
    setState(() => _busy = true);
    final result = await widget.useCases.substituirRevisoes(
      concursoId: _item.concursoId,
      topicoId: _item.topicoId,
      intervalosDias: _selectedReviews,
    );
    if (!mounted) return;
    switch (result) {
      case Sucesso<void>():
        setState(() {
          _busy = false;
          _reviewsSaved = true;
        });
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        setState(() => _busy = false);
        _showFailure();
    }
  }

  void _showFailure() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.weekOperationFailed)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.tokens.colors.canvas,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          return Padding(
            padding: EdgeInsets.all(compact ? context.tokens.spacing.md : context.tokens.spacing.xxl),
            child: Column(
              children: [
                _FocusHeader(item: _item, onExit: () => Navigator.of(context).pop(true)),
                SizedBox(height: compact ? context.tokens.spacing.lg : context.tokens.spacing.xxl),
                Align(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: _StageNavigation(
                      current: _step,
                      item: _item,
                      completedCycle: _reviewsSaved,
                      onSelected: _selectStep,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, viewport) => SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.lg),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: viewport.maxHeight - context.tokens.spacing.xxl),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: AnimatedSwitcher(
                              duration: context.motionDuration(context.tokens.motion.fast),
                              child: _buildStage(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  context.l10n.studyMethodFooter,
                  style: context.tokens.typography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    ),
  );

  Widget _buildStage(BuildContext context) {
    if (_reviewsSaved) {
      return _CompletionStage(
        key: const ValueKey('completed'),
        selected: _selectedReviews,
        onExit: () => Navigator.of(context).pop(true),
      );
    }
    if (_step == 4) return _reviewsStage(context);
    if (_step == 3) return _questionsStage(context);
    final completed = switch (_step) {
      0 => _item.teoriaConcluida,
      1 => _item.memoriaConcluida,
      _ => _item.conferenciaConcluida,
    };
    return _ActivityStage(
      key: ValueKey(_step),
      eyebrow: context.l10n.studyStep(_step + 1, 5),
      title: _stageTitle(context, _step),
      instruction: _stageInstruction(context, _step),
      time: _formattedRemaining(_step),
      running: _runningStep == _step,
      completed: completed,
      busy: _busy,
      onTimer: _toggleTimer,
      onComplete: completed ? null : _completeCurrentStage,
    );
  }

  Widget _questionsStage(BuildContext context) => _QuestionsStage(
    key: const ValueKey(3),
    time: _formattedRemaining(3),
    running: _runningStep == 3,
    busy: _busy,
    acertos: _item.acertos,
    erros: _item.erros,
    onTimer: _toggleTimer,
    onCorrect: () => _registerAnswer(ResultadoQuestao.certa),
    onWrong: () => _registerAnswer(ResultadoQuestao.errada),
  );

  Widget _reviewsStage(BuildContext context) => _ReviewsStage(
    key: const ValueKey(4),
    enabled: _item.concluido,
    selected: _selectedReviews,
    busy: _busy,
    onToggle: (days) => setState(() {
      if (!_selectedReviews.add(days)) _selectedReviews.remove(days);
    }),
    onSave: _saveReviews,
  );

  String _formattedRemaining(int step) {
    final seconds = _remaining[step] ?? 0;
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${rest.toString().padLeft(2, '0')}';
  }
}

class _FocusHeader extends StatelessWidget {
  const _FocusHeader({required this.item, required this.onExit});

  final ItemSemana item;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final exitButton = AppButton(
        label: context.l10n.saveAndExit,
        variant: AppButtonVariant.outline,
        onPressed: onExit,
      );
      if (constraints.maxWidth < 720) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppBadge(label: item.rotuloConcurso),
                const Spacer(),
                exitButton,
              ],
            ),
            SizedBox(height: context.tokens.spacing.sm),
            Text(item.disciplinaNome, style: context.tokens.typography.bodySmall),
            SizedBox(height: context.tokens.spacing.xs),
            Text(item.topicoNome, style: context.tokens.typography.titleSmall),
          ],
        );
      }
      return Row(
        children: [
          AppBadge(label: item.rotuloConcurso),
          SizedBox(width: context.tokens.spacing.md),
          Flexible(child: Text(item.disciplinaNome, style: context.tokens.typography.bodySmall)),
          SizedBox(width: context.tokens.spacing.md),
          Expanded(child: Text(item.topicoNome, style: context.tokens.typography.titleSmall)),
          exitButton,
        ],
      );
    },
  );
}

class _StageNavigation extends StatelessWidget {
  const _StageNavigation({
    required this.current,
    required this.item,
    required this.completedCycle,
    required this.onSelected,
  });

  final int current;
  final ItemSemana item;
  final bool completedCycle;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth < 620 ? 5 * 116.0 : constraints.maxWidth;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < 5; index++)
                Expanded(
                  child: _StageButton(
                    number: index + 1,
                    label: _stageShortTitle(context, index),
                    detail: index == 4 ? context.l10n.optional : '${[40, 5, 15, 40][index]} min',
                    selected: current == index,
                    completed: completedCycle || _isStageCompleted(item, index),
                    onPressed: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _StageButton extends StatelessWidget {
  const _StageButton({
    required this.number,
    required this.label,
    required this.detail,
    required this.selected,
    required this.completed,
    required this.onPressed,
  });

  final int number;
  final String label;
  final String detail;
  final bool selected;
  final bool completed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: context.motionDuration(context.tokens.motion.fast),
        padding: EdgeInsets.fromLTRB(
          context.tokens.spacing.sm,
          context.tokens.spacing.sm,
          context.tokens.spacing.sm,
          context.tokens.spacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: selected || completed ? context.tokens.colors.onSurface : context.tokens.colors.border,
              width: context.tokens.borders.widthStrong,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected || completed ? context.tokens.colors.onSurface : context.tokens.colors.onSurfaceMuted,
                ),
              ),
              child: completed
                  ? const Icon(AppIcons.check, size: 13)
                  : Text('$number', style: context.tokens.typography.bodySmall),
            ),
            SizedBox(width: context.tokens.spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.tokens.typography.controlLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    detail,
                    style: context.tokens.typography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActivityStage extends StatelessWidget {
  const _ActivityStage({
    required this.eyebrow,
    required this.title,
    required this.instruction,
    required this.time,
    required this.running,
    required this.completed,
    required this.busy,
    required this.onTimer,
    required this.onComplete,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String instruction;
  final String time;
  final bool running;
  final bool completed;
  final bool busy;
  final VoidCallback onTimer;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(eyebrow, style: context.tokens.typography.overlineStrong),
      SizedBox(height: context.tokens.spacing.md),
      Text(title, style: context.tokens.typography.displayMedium, textAlign: TextAlign.center),
      SizedBox(height: context.tokens.spacing.md),
      Text(instruction, style: context.tokens.typography.leadDescription, textAlign: TextAlign.center),
      SizedBox(height: context.tokens.spacing.xxxl),
      Text(time, style: context.tokens.typography.displayMedium),
      SizedBox(height: context.tokens.spacing.xs),
      Text(running ? context.l10n.timerRunning : context.l10n.timerReady),
      SizedBox(height: context.tokens.spacing.xxl),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: context.tokens.spacing.md,
        runSpacing: context.tokens.spacing.md,
        children: [
          AppButton(
            label: running ? context.l10n.pause : context.l10n.start,
            variant: AppButtonVariant.outline,
            icon: running ? AppIcons.minus : AppIcons.play,
            onPressed: onTimer,
          ),
          AppButton(
            label: completed ? context.l10n.completed : context.l10n.completeStage,
            icon: completed ? AppIcons.check : AppIcons.arrowRight,
            loading: busy,
            onPressed: onComplete,
          ),
        ],
      ),
    ],
  );
}

class _QuestionsStage extends StatelessWidget {
  const _QuestionsStage({
    required this.time,
    required this.running,
    required this.busy,
    required this.acertos,
    required this.erros,
    required this.onTimer,
    required this.onCorrect,
    required this.onWrong,
    super.key,
  });

  final String time;
  final bool running;
  final bool busy;
  final int acertos;
  final int erros;
  final VoidCallback onTimer;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(context.l10n.studyStep(4, 5), style: context.tokens.typography.overlineStrong),
      SizedBox(height: context.tokens.spacing.md),
      Text(
        context.l10n.questionsAndErrors,
        style: context.tokens.typography.displayMedium,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: context.tokens.spacing.md),
      Text(
        context.l10n.questionsInstruction,
        style: context.tokens.typography.leadDescription,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: context.tokens.spacing.xxl),
      LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final total = acertos + erros;
          final cards = [
            _QuestionTotalCard(total: total, running: running),
            _AnswerCounter(
              key: const ValueKey('answer-correct'),
              label: context.l10n.correctAnswers.toUpperCase(),
              value: acertos,
              icon: AppIcons.check,
              iconColor: context.tokens.colors.success,
              enabled: running && !busy,
              onPressed: onCorrect,
            ),
            _AnswerCounter(
              key: const ValueKey('answer-wrong'),
              label: context.l10n.wrongAnswers.toUpperCase(),
              value: erros,
              icon: AppIcons.close,
              iconColor: context.tokens.colors.error,
              enabled: running && !busy,
              onPressed: onWrong,
            ),
          ];
          if (compact) {
            return Column(
              children: [
                SizedBox(width: double.infinity, child: cards[0]),
                SizedBox(height: context.tokens.spacing.sm),
                Row(
                  children: [
                    Expanded(child: cards[1]),
                    SizedBox(width: context.tokens.spacing.sm),
                    Expanded(child: cards[2]),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 5, child: cards[0]),
              SizedBox(width: context.tokens.spacing.sm),
              Expanded(flex: 4, child: cards[1]),
              SizedBox(width: context.tokens.spacing.sm),
              Expanded(flex: 4, child: cards[2]),
            ],
          );
        },
      ),
      SizedBox(height: context.tokens.spacing.xxl),
      Text(time, style: context.tokens.typography.displayMedium),
      SizedBox(height: context.tokens.spacing.xs),
      Text(running ? context.l10n.timerRunning : context.l10n.timerReady),
      SizedBox(height: context.tokens.spacing.xxl),
      AppButton(
        label: running ? context.l10n.pause : context.l10n.start,
        variant: AppButtonVariant.outline,
        icon: running ? AppIcons.minus : AppIcons.play,
        onPressed: onTimer,
      ),
    ],
  );
}

class _QuestionTotalCard extends StatelessWidget {
  const _QuestionTotalCard({required this.total, required this.running});

  final int total;
  final bool running;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 92),
    padding: EdgeInsets.all(context.tokens.spacing.lg),
    decoration: BoxDecoration(
      color: context.tokens.colors.card,
      border: Border.all(color: context.tokens.colors.border),
      borderRadius: context.tokens.borders.xl,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.answeredQuestions, style: context.tokens.typography.overline),
        SizedBox(height: context.tokens.spacing.xs),
        Text('$total', style: context.tokens.typography.headlineMedium),
        Text(
          running ? context.l10n.timerRunning : context.l10n.startTimerToAnswer,
          style: context.tokens.typography.bodySmall,
        ),
      ],
    ),
  );
}

class _AnswerCounter extends StatelessWidget {
  const _AnswerCounter({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    label: '$label: $value',
    child: Opacity(
      opacity: enabled ? 1 : .45,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: context.tokens.borders.xl,
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: EdgeInsets.all(context.tokens.spacing.lg),
          decoration: BoxDecoration(
            color: context.tokens.colors.card,
            border: Border.all(color: context.tokens.colors.border),
            borderRadius: context.tokens.borders.xl,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(label, style: context.tokens.typography.overline),
                  Text('$value', style: context.tokens.typography.headlineMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ReviewsStage extends StatelessWidget {
  const _ReviewsStage({
    required this.enabled,
    required this.selected,
    required this.busy,
    required this.onToggle,
    required this.onSave,
    super.key,
  });

  final bool enabled;
  final Set<int> selected;
  final bool busy;
  final ValueChanged<int> onToggle;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(context.l10n.studyStep(5, 5), style: context.tokens.typography.overlineStrong),
      SizedBox(height: context.tokens.spacing.md),
      Text(context.l10n.chooseReviews, style: context.tokens.typography.displayMedium, textAlign: TextAlign.center),
      SizedBox(height: context.tokens.spacing.md),
      Text(
        enabled ? context.l10n.chooseReviewsDescription : context.l10n.completeCoreStagesFirst,
        style: context.tokens.typography.leadDescription,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: context.tokens.spacing.xxl),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: context.tokens.spacing.md,
        runSpacing: context.tokens.spacing.md,
        children: [
          for (final days in const [1, 7, 30])
            _ReviewChoice(
              days: days,
              selected: selected.contains(days),
              enabled: enabled && !busy,
              onPressed: () => onToggle(days),
            ),
        ],
      ),
      SizedBox(height: context.tokens.spacing.xxl),
      AppButton(
        label: context.l10n.finishStudyCycle,
        icon: AppIcons.arrowRight,
        loading: busy,
        onPressed: enabled ? onSave : null,
      ),
    ],
  );
}

class _CompletionStage extends StatelessWidget {
  const _CompletionStage({required this.selected, required this.onExit, super.key});

  final Set<int> selected;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final ordered = selected.toList()..sort();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(AppIcons.check, size: 36, color: context.tokens.colors.success),
        SizedBox(height: context.tokens.spacing.md),
        Text(context.l10n.cycleCompleted, style: context.tokens.typography.overlineStrong),
        SizedBox(height: context.tokens.spacing.md),
        Text(
          ordered.isEmpty ? context.l10n.noReviewsScheduled : context.l10n.scheduledReviewsCount(ordered.length),
          style: context.tokens.typography.displayMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.tokens.spacing.md),
        Text(
          ordered.isEmpty ? context.l10n.noReviewsScheduledDescription : context.l10n.scheduledReviewsDescription,
          style: context.tokens.typography.leadDescription,
          textAlign: TextAlign.center,
        ),
        if (ordered.isNotEmpty) ...[
          SizedBox(height: context.tokens.spacing.xxl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: context.tokens.spacing.sm,
            runSpacing: context.tokens.spacing.sm,
            children: [
              for (final days in ordered)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.tokens.spacing.md,
                    vertical: context.tokens.spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: context.tokens.colors.card,
                    border: Border.all(color: context.tokens.colors.border),
                    borderRadius: context.tokens.borders.lg,
                  ),
                  child: Text('D+$days', style: context.tokens.typography.controlLabel),
                ),
            ],
          ),
        ],
        SizedBox(height: context.tokens.spacing.xxl),
        AppButton(label: context.l10n.backToWeek, onPressed: onExit),
      ],
    );
  }
}

class _ReviewChoice extends StatelessWidget {
  const _ReviewChoice({
    required this.days,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final int days;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    enabled: enabled,
    child: InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: context.tokens.borders.xl,
      child: AnimatedContainer(
        duration: context.motionDuration(context.tokens.motion.fast),
        width: 160,
        height: 112,
        padding: EdgeInsets.all(context.tokens.spacing.md),
        decoration: BoxDecoration(
          color: selected ? context.tokens.colors.surfaceSubtle : context.tokens.colors.card,
          border: Border.all(
            color: selected ? context.tokens.colors.onSurface : context.tokens.colors.border,
            width: selected ? context.tokens.borders.widthStrong : context.tokens.borders.widthHairline,
          ),
          borderRadius: context.tokens.borders.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('D+$days', style: context.tokens.typography.titleSmall),
            SizedBox(height: context.tokens.spacing.xs),
            Text(
              context.l10n.reviewAfterDays(days),
              style: context.tokens.typography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

bool _isStageCompleted(ItemSemana item, int step) => switch (step) {
  0 => item.teoriaConcluida,
  1 => item.memoriaConcluida,
  2 => item.conferenciaConcluida,
  _ => false,
};

String _stageShortTitle(BuildContext context, int step) => switch (step) {
  0 => context.l10n.theory,
  1 => context.l10n.memory,
  2 => context.l10n.conference,
  3 => context.l10n.questions,
  _ => context.l10n.reviews,
};

String _stageTitle(BuildContext context, int step) => switch (step) {
  0 => context.l10n.theoryStudy,
  1 => context.l10n.memoryWriting,
  _ => context.l10n.conferenceAndConsolidation,
};

String _stageInstruction(BuildContext context, int step) => switch (step) {
  0 => context.l10n.theoryInstruction,
  1 => context.l10n.memoryInstruction,
  _ => context.l10n.conferenceInstruction,
};
