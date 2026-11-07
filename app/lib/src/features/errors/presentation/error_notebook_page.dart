import 'package:flutter/material.dart';

import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';

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
      correctRule:
          'A responsabilidade do agente é apurada em ação própria, quando houver dolo ou culpa.',
      whyIFell:
          'Eu ignorei a palavra “agente” e respondi como se a pergunta tratasse diretamente do Estado.',
      nextReview: 'Revisar hoje',
      reviewStage: '7 dias',
    ),
    _ErrorEntry(
      discipline: 'Língua Portuguesa',
      topic: 'Concordância verbal',
      question: 'Questão 27 · Bloco de questões',
      kind: _ErrorKind.rush,
      correctRule:
          'Com sujeito composto posposto, a concordância pode ocorrer no plural ou com o núcleo mais próximo.',
      whyIFell:
          'Marquei a primeira alternativa em poucos segundos e não conferi a posição do sujeito.',
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
      whyIFell:
          'Eu lembrava a regra geral, mas não sabia a exceção aplicável à autoridade descrita.',
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
      whyIFell:
          'A assertiva trocou uma hipótese de suspensão por perda, e eu aceitei a redação por parecer familiar.',
      nextReview: '12 nov.',
      reviewStage: '30 dias',
    ),
  ];

  List<_ErrorEntry> get _visibleEntries => _entries
      .where((entry) => _kind == null || entry.kind == _kind)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) => AppShell(
    section: AppSection.errors,
    builder: (context, desktop) => SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              desktop ? 40 : 20,
              20,
              desktop ? 40 : 20,
              48,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!desktop) ...[
                        const AppBrandLogo(width: 178),
                        const SizedBox(height: 28),
                      ],
                      _Header(
                        onAdd: () => _showRegisterDialog(context),
                        onLearn: () => _showMethodDialog(context),
                      ),
                      const SizedBox(height: 28),
                      const _Overview(),
                      const SizedBox(height: 24),
                      _Filters(
                        view: _view,
                        kind: _kind,
                        onViewChanged: (value) => setState(() => _view = value),
                        onKindChanged: (value) => setState(() => _kind = value),
                      ),
                      const SizedBox(height: 24),
                      if (_view == _NotebookView.active)
                        _ActiveNotebook(entries: _visibleEntries)
                      else
                        const _ArchivePreview(),
                      const SizedBox(height: 28),
                      const _MonthlyReading(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      final compact = constraints.maxWidth < 700;
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caderno de Erros',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Entenda por que errou. Volte apenas ao que precisa.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final actions = Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: onLearn,
            icon: const Icon(AppIcons.observation, size: 18),
            label: const Text('Como funciona'),
          ),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(AppIcons.add, size: 18),
            label: const Text('Registrar erro'),
          ),
        ],
      );
      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [heading, const SizedBox(height: 18), actions],
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

class _Overview extends StatelessWidget {
  const _Overview();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Wrap(
      spacing: 32,
      runSpacing: 16,
      children: [
        _OverviewItem(
          icon: AppIcons.errorNotebook,
          value: '24',
          label: 'Registros ativos',
        ),
        _OverviewItem(
          icon: AppIcons.reviews,
          value: '3',
          label: 'Para revisar hoje',
        ),
        _OverviewItem(
          icon: AppIcons.statistics,
          value: 'Leitura',
          label: 'Causa mais frequente',
        ),
      ],
    ),
  );
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
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
        segments: const [
          ButtonSegment(
            value: _NotebookView.active,
            label: Text('Caderno ativo'),
            icon: Icon(AppIcons.bookText, size: 18),
          ),
          ButtonSegment(
            value: _NotebookView.archived,
            label: Text('Arquivo'),
            icon: Icon(AppIcons.check, size: 18),
          ),
        ],
        selected: {view},
        onSelectionChanged: (values) => onViewChanged(values.first),
      ),
      const SizedBox(height: 14),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              selected: kind == null,
              onSelected: (_) => onKindChanged(null),
              label: const Text('Todos os tipos'),
            ),
            for (final value in _ErrorKind.values) ...[
              const SizedBox(width: 8),
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
          Text('Em revisão', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text(
            'O caderno ativo guarda somente o que ainda precisa voltar.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            const _EmptyFilter()
          else
            for (var index = 0; index < entries.length; index++) ...[
              _ErrorCard(entry: entries[index]),
              if (index < entries.length - 1) const SizedBox(height: 14),
            ],
        ],
      );
      if (constraints.maxWidth < 860) {
        return Column(
          children: [
            notebook,
            const SizedBox(height: 24),
            const _DiagnosisGuide(),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: notebook),
          const SizedBox(width: 20),
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
    final accent = entry.priority
        ? scheme.error
        : _kindColor(entry.kind, context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: ColoredBox(color: accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Tag(label: entry.kind.label, color: accent),
                    _Tag(label: entry.reviewStage, color: scheme.primary),
                    if (entry.priority)
                      _Tag(label: 'Errou novamente', color: scheme.error),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  entry.topic,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 3),
                Text(
                  '${entry.discipline} · ${entry.question}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                _LinedField(
                  label: 'A regra certa, com minhas palavras',
                  value: entry.correctRule,
                  icon: AppIcons.fromMemory,
                ),
                const SizedBox(height: 12),
                _LinedField(
                  label: 'Por que eu caí',
                  value: entry.whyIFell,
                  icon: AppIcons.errorNotebook,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(AppIcons.calendar, size: 18, color: accent),
                    const SizedBox(width: 8),
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
                      child: const Text('Abrir registro'),
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
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(6),
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
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: .48),
      borderRadius: BorderRadius.circular(8),
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
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
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          AppIcons.observation,
          size: AppIcons.prominent,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 14),
        Text(
          'Diagnóstico antes do remédio',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Classifique pela primeira resposta que fizer sentido. Cada causa pede um treino diferente.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        for (final kind in _ErrorKind.values) ...[
          _DiagnosisRow(kind: kind),
          if (kind != _ErrorKind.values.last) const Divider(height: 20),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
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
        width: 9,
        height: 9,
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: _kindColor(kind, context),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kind.label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 2),
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
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          AppIcons.check,
          color: Theme.of(context).colorScheme.secondary,
          size: 28,
        ),
        const SizedBox(height: 12),
        Text('Arquivo', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '18 registros já saíram do caderno ativo. Eles voltam apenas na semana da prova, com uma leitura de “Por que eu caí”.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => _showDataMessage(context),
          child: const Text('Ver registros arquivados'),
        ),
      ],
    ),
  );
}

class _MonthlyReading extends StatelessWidget {
  const _MonthlyReading();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 5),
            Text(
              'Direito Administrativo concentra mais erros. Leitura é a causa predominante; o ajuste é no processo, não em reler toda a matéria.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
        final button = OutlinedButton.icon(
          onPressed: () => _showDataMessage(context),
          icon: const Icon(AppIcons.statistics, size: 18),
          label: const Text('Ver relatório mensal'),
        );
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [text, const SizedBox(height: 16), button],
          );
        }
        return Row(
          children: [
            Expanded(child: text),
            const SizedBox(width: 24),
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
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text('Nenhum registro com esse diagnóstico.'),
  );
}

class _RegisterErrorDialog extends StatefulWidget {
  const _RegisterErrorDialog();

  @override
  State<_RegisterErrorDialog> createState() => _RegisterErrorDialogState();
}

class _RegisterErrorDialogState extends State<_RegisterErrorDialog> {
  final _formKey = GlobalKey<FormState>();
  _ErrorKind _kind = _ErrorKind.content;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Registrar erro'),
    content: SizedBox(
      width: 560,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sete campos, cerca de noventa segundos. Escreva antes de voltar ao gabarito.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Data'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Disciplina e Tópico',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(labelText: 'Banca e ano'),
              ),
              const SizedBox(height: 16),
              Text(
                'Tipo do erro',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kind in _ErrorKind.values)
                    ChoiceChip(
                      label: Text(kind.label),
                      selected: _kind == kind,
                      onSelected: (_) => setState(() => _kind = kind),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'A regra certa, com minhas palavras',
                  helperText: 'Feche o gabarito antes de escrever.',
                  alignLabelWithHint: true,
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Por que eu caí',
                  helperText: 'Nomeie o mecanismo do erro, não o sentimento.',
                  alignLabelWithHint: true,
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 14),
              Text(
                'As Revisões de 1, 7 e 30 dias serão programadas ao salvar.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (!(_formKey.currentState?.validate() ?? false)) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro demonstrativo concluído.')),
          );
        },
        child: const Text('Salvar e programar Revisões'),
      ),
    ],
  );
}

Future<void> _showRegisterDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => const _RegisterErrorDialog(),
);

Future<void> _showMethodDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Como funciona o Caderno de Erros'),
    content: const SizedBox(
      width: 500,
      child: Text(
        'Classifique a causa, escreva a regra correta com suas palavras e explique por que caiu. No dia seguinte, leia a regra; em 7 dias, recupere de memória; em 30 dias, refaça a questão. Só então um registro pode sair do caderno ativo.',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Entendi'),
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
      width: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.reviewStage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(_reviewInstruction(entry.reviewStage)),
          if (entry.priority) ...[
            const SizedBox(height: 14),
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
        child: const Text('Fechar'),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Começar Revisão'),
      ),
    ],
  ),
);

void _showDataMessage(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('Esta área será conectada aos dados depois.'),
      ),
    );
}

String? _requiredText(String? value) => value == null || value.trim().isEmpty
    ? 'Escreva com suas palavras para concluir o registro.'
    : null;

String _reviewInstruction(String stage) => switch (stage) {
  '1 dia' => 'Leia somente “A regra certa”. Se não fizer sentido, reescreva.',
  '7 dias' => 'Cubra a regra e tente dizê-la de memória antes de conferir.',
  '30 dias' =>
    'Refaça a questão original. Arquive apenas se acertar com segurança.',
  _ =>
    'Volte ao Tópico inteiro e repare a compreensão antes de tentar novamente.',
};

Color _kindColor(_ErrorKind kind, BuildContext context) => switch (kind) {
  _ErrorKind.content => Theme.of(context).colorScheme.error,
  _ErrorKind.reading => Theme.of(context).colorScheme.primary,
  _ErrorKind.rush => Theme.of(context).colorScheme.tertiary,
  _ErrorKind.trap => AppColors.jurisprudenciaTinta,
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
