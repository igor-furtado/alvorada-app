import 'package:flutter/material.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';

class ErrorNotebookPage extends StatefulWidget {
  const ErrorNotebookPage({super.key});

  @override
  State<ErrorNotebookPage> createState() => _ErrorNotebookPageState();
}

class _ErrorNotebookPageState extends State<ErrorNotebookPage> {
  _NotebookView _view = _NotebookView.active;
  _ErrorKind? _kind;

  static const _entries = [
    _ErrorEntry(
      discipline: 'Direito Administrativo',
      topic: 'Responsabilidade civil do Estado',
      question: 'Questão 18 · Simulado 04',
      kind: _ErrorKind.reading,
      correctRule: 'A responsabilidade do agente é apurada em ação própria, quando houver dolo ou culpa.',
      whyIFell: 'Eu ignorei a palavra “agente” e respondi como se a pergunta tratasse diretamente do Estado.',
      nextReview: 'Revisar hoje',
      reviewStage: '7 dias',
    ),
    _ErrorEntry(
      discipline: 'Língua Portuguesa',
      topic: 'Concordância verbal',
      question: 'Questão 27 · Bloco de questões',
      kind: _ErrorKind.rush,
      correctRule: 'Com sujeito composto posposto, a concordância pode ocorrer no plural ou com o núcleo mais próximo.',
      whyIFell: 'Marquei a primeira alternativa em poucos segundos e não conferi a posição do sujeito.',
      nextReview: 'Amanhã',
      reviewStage: '1 dia',
    ),
    _ErrorEntry(
      discipline: 'Controle Externo',
      topic: 'Competências constitucionais',
      question: 'Questão 11 · Simulado 03',
      kind: _ErrorKind.content,
      correctRule:
          'A competência muda conforme o ato analisado; é preciso identificar quem praticou o ato antes de concluir.',
      whyIFell: 'Eu lembrava a regra geral, mas não sabia a exceção aplicável à autoridade descrita.',
      nextReview: 'Prioridade máxima',
      reviewStage: 'Reincidente',
      priority: true,
    ),
    _ErrorEntry(
      discipline: 'Direito Constitucional',
      topic: 'Direitos políticos',
      question: 'Questão 09 · Bloco de questões',
      kind: _ErrorKind.trap,
      correctRule:
          'As hipóteses de perda e suspensão têm efeitos distintos e não podem ser tratadas como equivalentes.',
      whyIFell: 'A assertiva trocou uma hipótese de suspensão por perda, e eu aceitei a redação por parecer familiar.',
      nextReview: '12 nov.',
      reviewStage: '30 dias',
    ),
  ];

  List<_ErrorEntry> get _visibleEntries =>
      _entries.where((entry) => _kind == null || entry.kind == _kind).toList(growable: false);

  @override
  Widget build(BuildContext context) => AppPageTemplate(
    builder: (context, desktop) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!desktop) ...[
          AppBrandLogo(width: context.tokens.layout.brandWidth),
          SizedBox(height: context.tokens.spacing.xxxl),
        ],
        _Header(
          onAdd: () => _showRegisterDialog(context),
          onLearn: () => _showMethodDialog(context),
        ),
        SizedBox(height: context.tokens.spacing.xxxl),
        const AppMetricOverview(
          tone: AppMetricTone.error,
          items: [
            AppMetricData(icon: AppIcons.errorNotebook, value: '24', label: 'Registros ativos'),
            AppMetricData(icon: AppIcons.reviews, value: '3', label: 'Para revisar hoje'),
            AppMetricData(icon: AppIcons.statistics, value: 'Leitura', label: 'Causa mais frequente'),
          ],
        ),
        SizedBox(height: context.tokens.spacing.xxl),
        _Filters(
          view: _view,
          kind: _kind,
          onViewChanged: (value) => setState(() => _view = value),
          onKindChanged: (value) => setState(() => _kind = value),
        ),
        SizedBox(height: context.tokens.spacing.xxl),
        if (_view == _NotebookView.active) _ActiveNotebook(entries: _visibleEntries) else const _ArchivePreview(),
        SizedBox(height: context.tokens.spacing.xxxl),
        const _MonthlyReading(),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd, required this.onLearn});

  final VoidCallback onAdd;
  final VoidCallback onLearn;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < context.tokens.layout.header;
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caderno de Erros',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            'Entenda por que errou. Volte apenas ao que precisa.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final actions = Wrap(
        spacing: context.tokens.spacing.md,
        runSpacing: context.tokens.spacing.md,
        children: [
          AppButton(
            onPressed: onLearn,
            variant: AppButtonVariant.outline,
            icon: AppIcons.observation,
            label: AppMessages.howItWorks,
          ),
          AppButton(
            onPressed: onAdd,
            icon: AppIcons.add,
            label: AppMessages.registerError,
          ),
        ],
      );
      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            SizedBox(height: context.tokens.spacing.xl),
            actions,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: heading),
          actions,
        ],
      );
    },
  );
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.view,
    required this.kind,
    required this.onViewChanged,
    required this.onKindChanged,
  });

  final _NotebookView view;
  final _ErrorKind? kind;
  final ValueChanged<_NotebookView> onViewChanged;
  final ValueChanged<_ErrorKind?> onKindChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SegmentedButton<_NotebookView>(
        segments: [
          ButtonSegment(
            value: _NotebookView.active,
            label: const Text(AppMessages.activeNotebook),
            icon: Icon(AppIcons.bookText, size: context.tokens.icons.md),
          ),
          ButtonSegment(
            value: _NotebookView.archived,
            label: const Text(AppMessages.notebookArchive),
            icon: Icon(AppIcons.check, size: context.tokens.icons.md),
          ),
        ],
        selected: {view},
        onSelectionChanged: (values) => onViewChanged(values.first),
      ),
      SizedBox(height: context.tokens.spacing.lg),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              selected: kind == null,
              onSelected: (_) => onKindChanged(null),
              label: const Text(AppMessages.allErrorTypes),
            ),
            for (final value in _ErrorKind.values) ...[
              SizedBox(width: context.tokens.spacing.sm),
              FilterChip(
                selected: kind == value,
                onSelected: (_) => onKindChanged(value),
                label: Text(value.label),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

class _ActiveNotebook extends StatelessWidget {
  const _ActiveNotebook({required this.entries});

  final List<_ErrorEntry> entries;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final notebook = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppMessages.underReview, style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            'O caderno ativo guarda somente o que ainda precisa voltar.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.tokens.spacing.lg),
          if (entries.isEmpty)
            const _EmptyFilter()
          else
            for (var index = 0; index < entries.length; index++) ...[
              _ErrorCard(entry: entries[index]),
              if (index < entries.length - 1) SizedBox(height: context.tokens.spacing.lg),
            ],
        ],
      );
      if (constraints.maxWidth < context.tokens.layout.contentSplit) {
        return Column(
          children: [
            notebook,
            SizedBox(height: context.tokens.spacing.xxl),
            const _DiagnosisGuide(),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: notebook),
          SizedBox(width: context.tokens.spacing.xl),
          const Expanded(flex: 4, child: _DiagnosisGuide()),
        ],
      );
    },
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.entry});

  final _ErrorEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = entry.priority ? scheme.error : _kindColor(entry.kind, context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: context.tokens.borders.lg,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Stack(
        children: [
          Positioned(
            left: context.tokens.spacing.none,
            top: context.tokens.spacing.none,
            bottom: context.tokens.spacing.none,
            width: context.tokens.sizes.accentBar,
            child: ColoredBox(color: accent),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.tokens.spacing.xxl,
              context.tokens.spacing.lg,
              context.tokens.spacing.xl,
              context.tokens.spacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: context.tokens.spacing.sm,
                  runSpacing: context.tokens.spacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Tag(label: entry.kind.label, color: _kindColor(entry.kind, context)),
                    _Tag(label: entry.reviewStage, color: context.tokens.colors.actionForeground),
                    if (entry.priority) _Tag(label: 'Errou novamente', color: context.tokens.colors.errorForeground),
                  ],
                ),
                SizedBox(height: context.tokens.spacing.lg),
                Text(
                  entry.topic,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: context.tokens.spacing.xxs),
                Text(
                  '${entry.discipline} · ${entry.question}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: context.tokens.spacing.lg),
                _LinedField(
                  label: AppMessages.correctRule,
                  value: entry.correctRule,
                  icon: AppIcons.fromMemory,
                ),
                SizedBox(height: context.tokens.spacing.md),
                _LinedField(
                  label: AppMessages.whyIFell,
                  value: entry.whyIFell,
                  icon: AppIcons.errorNotebook,
                ),
                SizedBox(height: context.tokens.spacing.lg),
                Row(
                  children: [
                    Icon(AppIcons.calendar, size: context.tokens.icons.md, color: accent),
                    SizedBox(width: context.tokens.spacing.sm),
                    Expanded(
                      child: Text(
                        entry.nextReview,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: accent),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showReviewPreview(context, entry),
                      child: const Text(AppMessages.openEntry),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.md, vertical: context.tokens.spacing.xs),
    decoration: BoxDecoration(
      color: color.withValues(alpha: context.tokens.opacity.tint),
      borderRadius: context.tokens.borders.sm,
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
    ),
  );
}

class _LinedField extends StatelessWidget {
  const _LinedField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(context.tokens.spacing.md),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
        alpha: context.tokens.opacity.subtle,
      ),
      borderRadius: context.tokens.borders.md,
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: context.tokens.icons.md,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              SizedBox(height: context.tokens.spacing.xxs),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DiagnosisGuide extends StatelessWidget {
  const _DiagnosisGuide();

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.xl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: context.tokens.borders.lg,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          AppIcons.observation,
          size: context.tokens.icons.xl,
          color: context.tokens.colors.actionForeground,
        ),
        SizedBox(height: context.tokens.spacing.lg),
        Text(
          'Diagnóstico antes do remédio',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: context.tokens.spacing.sm),
        Text(
          'Classifique pela primeira resposta que fizer sentido. Cada causa pede um treino diferente.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: context.tokens.spacing.xl),
        for (final kind in _ErrorKind.values) ...[
          _DiagnosisRow(kind: kind),
          if (kind != _ErrorKind.values.last) Divider(height: context.tokens.spacing.xl),
        ],
        SizedBox(height: context.tokens.spacing.lg),
        Container(
          padding: EdgeInsets.all(context.tokens.spacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: context.tokens.borders.md,
          ),
          child: Text(
            'Evite “falta de atenção”. Nomeie a palavra, condição ou decisão que levou ao erro.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

class _DiagnosisRow extends StatelessWidget {
  const _DiagnosisRow({required this.kind});

  final _ErrorKind kind;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: context.tokens.sizes.dotMd,
        height: context.tokens.sizes.dotMd,
        margin: EdgeInsets.only(top: context.tokens.spacing.xs),
        decoration: BoxDecoration(
          color: _kindColor(kind, context),
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: context.tokens.spacing.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kind.label, style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: context.tokens.spacing.xxxs),
            Text(kind.remedy, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}

class _ArchivePreview extends StatelessWidget {
  const _ArchivePreview();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(context.tokens.spacing.xxl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: context.tokens.borders.lg,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          AppIcons.check,
          color: Theme.of(context).colorScheme.secondary,
          size: context.tokens.icons.xl,
        ),
        SizedBox(height: context.tokens.spacing.md),
        Text(AppMessages.notebookArchive, style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: context.tokens.spacing.xs),
        Text(
          '18 registros já saíram do caderno ativo. Eles voltam apenas na semana da prova, com uma leitura de “Por que eu caí”.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: context.tokens.spacing.lg),
        OutlinedButton(
          onPressed: () => _showDataMessage(context),
          child: const Text(AppMessages.seeArchivedEntries),
        ),
      ],
    ),
  );
}

class _MonthlyReading extends StatelessWidget {
  const _MonthlyReading();

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.xl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: context.tokens.borders.lg,
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leitura mensal do seu padrão',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: context.tokens.spacing.xs),
            Text(
              'Direito Administrativo concentra mais erros. Leitura é a causa predominante; o ajuste é no processo, não em reler toda a matéria.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
        final button = OutlinedButton.icon(
          onPressed: () => _showDataMessage(context),
          icon: Icon(AppIcons.statistics, size: context.tokens.icons.md),
          label: const Text(AppMessages.seeMonthlyReport),
        );
        if (constraints.maxWidth < context.tokens.layout.reading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              text,
              SizedBox(height: context.tokens.spacing.lg),
              button,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: text),
            SizedBox(width: context.tokens.spacing.xxl),
            button,
          ],
        );
      },
    ),
  );
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(context.tokens.spacing.xxl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: context.tokens.borders.lg,
    ),
    child: const Text(AppMessages.noEntryForDiagnosis),
  );
}

class _RegisterErrorDialog extends StatefulWidget {
  const _RegisterErrorDialog();

  @override
  State<_RegisterErrorDialog> createState() => _RegisterErrorDialogState();
}

class _RegisterErrorDialogState extends State<_RegisterErrorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ruleController = TextEditingController();
  final _reasonController = TextEditingController();
  final _ruleFocus = FocusNode();
  final _reasonFocus = FocusNode();
  _ErrorKind _kind = _ErrorKind.content;

  @override
  void dispose() {
    _ruleController.dispose();
    _reasonController.dispose();
    _ruleFocus.dispose();
    _reasonFocus.dispose();
    super.dispose();
  }

  FocusNode? _firstInvalidFocus() {
    if (_ruleController.text.trim().isEmpty) return _ruleFocus;
    if (_reasonController.text.trim().isEmpty) return _reasonFocus;
    return null;
  }

  @override
  Widget build(BuildContext context) => AppDialog(
    title: AppMessages.registerError,
    maxWidth: context.tokens.sizes.dialogWide,
    content: AppValidatedForm(
      formKey: _formKey,
      firstInvalidFocusNode: _firstInvalidFocus,
      onSubmit: () async => Navigator.of(context).pop(true),
      builder: (context, submitting, submit) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppMessages.registerErrorIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: context.tokens.spacing.xl),
          const AppFormField(label: AppMessages.date),
          SizedBox(height: context.tokens.spacing.md),
          const AppFormField(label: AppMessages.disciplineAndTopic),
          SizedBox(height: context.tokens.spacing.md),
          const AppFormField(label: AppMessages.boardAndYear),
          SizedBox(height: context.tokens.spacing.lg),
          Text(
            AppMessages.errorType,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          Wrap(
            spacing: context.tokens.spacing.sm,
            runSpacing: context.tokens.spacing.sm,
            children: [
              for (final kind in _ErrorKind.values)
                ChoiceChip(
                  label: Text(kind.label),
                  selected: _kind == kind,
                  onSelected: (_) => setState(() => _kind = kind),
                ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.lg),
          AppFormField(
            label: AppMessages.correctRule,
            helperText: AppMessages.correctRuleHint,
            controller: _ruleController,
            focusNode: _ruleFocus,
            required: true,
            minLines: 2,
            maxLines: 4,
            validator: _requiredText,
          ),
          SizedBox(height: context.tokens.spacing.md),
          AppFormField(
            label: AppMessages.whyIFell,
            helperText: AppMessages.whyIFellHint,
            controller: _reasonController,
            focusNode: _reasonFocus,
            required: true,
            minLines: 2,
            maxLines: 4,
            validator: _requiredText,
          ),
          SizedBox(height: context.tokens.spacing.lg),
          Text(
            AppMessages.revisionsWillBeScheduled,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: context.tokens.spacing.xl),
          Wrap(
            spacing: context.tokens.spacing.sm,
            runSpacing: context.tokens.spacing.sm,
            alignment: WrapAlignment.end,
            children: [
              AppButton(
                label: AppMessages.cancel,
                variant: AppButtonVariant.text,
                onPressed: submitting ? null : () => Navigator.of(context).pop(false),
              ),
              AppButton(
                label: AppMessages.saveAndScheduleReviews,
                loading: submitting,
                onPressed: submit,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<void> _showRegisterDialog(BuildContext context) async {
  final saved = await showDialog<bool>(context: context, builder: (context) => const _RegisterErrorDialog());
  if (saved == true && context.mounted) {
    AppSnackbar.show(context, message: AppMessages.errorRegistered, variant: AppSnackbarVariant.success);
  }
}

Future<void> _showMethodDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text(AppMessages.howErrorNotebookWorks),
    content: SizedBox(
      width: context.tokens.sizes.dialogMedium,
      child: const Text(
        'Classifique a causa, escreva a regra correta com suas palavras e explique por que caiu. No dia seguinte, leia a regra; em 7 dias, recupere de memória; em 30 dias, refaça a questão. Só então um registro pode sair do caderno ativo.',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(AppMessages.understand),
      ),
    ],
  ),
);

Future<void> _showReviewPreview(
  BuildContext context,
  _ErrorEntry entry,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(entry.topic),
    content: SizedBox(
      width: context.tokens.sizes.dialogNarrow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.reviewStage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          Text(_reviewInstruction(entry.reviewStage)),
          if (entry.priority) ...[
            SizedBox(height: context.tokens.spacing.lg),
            Text(
              'Como este erro se repetiu, o Tópico inteiro volta para consulta.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(AppMessages.close),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(AppMessages.startNotebookReview),
      ),
    ],
  ),
);

void _showDataMessage(BuildContext context) {
  AppSnackbar.show(context, message: AppMessages.areaNotConnected);
}

String? _requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'Escreva com suas palavras para concluir o registro.' : null;

String _reviewInstruction(String stage) => switch (stage) {
  '1 dia' => 'Leia somente “A regra certa”. Se não fizer sentido, reescreva.',
  '7 dias' => 'Cubra a regra e tente dizê-la de memória antes de conferir.',
  '30 dias' => 'Refaça a questão original. Arquive apenas se acertar com segurança.',
  _ => 'Volte ao Tópico inteiro e repare a compreensão antes de tentar novamente.',
};

Color _kindColor(_ErrorKind kind, BuildContext context) => switch (kind) {
  _ErrorKind.content => context.tokens.colors.errorForeground,
  _ErrorKind.reading => context.tokens.colors.actionForeground,
  _ErrorKind.rush => Theme.of(context).colorScheme.tertiary,
  _ErrorKind.trap => context.tokens.colors.info,
};

enum _NotebookView { active, archived }

enum _ErrorKind {
  content('Conteúdo', 'Volte ao material e refaça questões do mesmo assunto.'),
  reading('Leitura', 'Treine o comando e as palavras que mudam a assertiva.'),
  rush('Pressa', 'Ajuste o ritmo e confira antes de marcar.'),
  trap(
    'Armadilha',
    'Registre a exceção ou a troca específica; ela pode voltar.',
  );

  const _ErrorKind(this.label, this.remedy);

  final String label;
  final String remedy;
}

class _ErrorEntry {
  const _ErrorEntry({
    required this.discipline,
    required this.topic,
    required this.question,
    required this.kind,
    required this.correctRule,
    required this.whyIFell,
    required this.nextReview,
    required this.reviewStage,
    this.priority = false,
  });

  final String discipline;
  final String topic;
  final String question;
  final _ErrorKind kind;
  final String correctRule;
  final String whyIFell;
  final String nextReview;
  final String reviewStage;
  final bool priority;
}
