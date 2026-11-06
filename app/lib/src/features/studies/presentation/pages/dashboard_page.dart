import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/study_catalog.dart';
import '../providers/study_providers.dart';
import '../widgets/study_dialogs.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(studyCatalogProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1000;
        return Scaffold(
          drawer: desktop ? null : const Drawer(child: _Sidebar()),
          body: Row(
            children: [
              if (desktop) const SizedBox(width: 248, child: _Sidebar()),
              Expanded(
                child: catalog.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _ErrorState(
                    message: _friendlyError(error),
                    onRetry: () =>
                        ref.read(studyCatalogProvider.notifier).refresh(),
                  ),
                  data: (subjects) =>
                      _DashboardContent(subjects: subjects, showMenu: !desktop),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.subjects, required this.showMenu});
  final List<StudySubject> subjects;
  final bool showMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicCount = subjects.fold(
      0,
      (total, subject) => total + subject.topics.length,
    );
    final subtopicCount = subjects.fold(
      0,
      (total, subject) => total + subject.subtopicCount,
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              showMenu ? 20 : 40,
              24,
              showMenu ? 20 : 40,
              8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showMenu)
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: const Icon(Icons.menu_rounded),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Atualizar',
                      onPressed: () =>
                          ref.read(studyCatalogProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        'EU',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Meus estudos',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Organize seu conteúdo e enxergue com clareza o que precisa estudar.',
                ),
                const SizedBox(height: 26),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      label: 'Disciplinas',
                      value: subjects.length,
                      icon: Icons.menu_book_rounded,
                      color: AppColors.primary,
                    ),
                    _MetricCard(
                      label: 'Tópicos',
                      value: topicCount,
                      icon: Icons.account_tree_rounded,
                      color: AppColors.success,
                    ),
                    _MetricCard(
                      label: 'Subtópicos',
                      value: subtopicCount,
                      icon: Icons.checklist_rounded,
                      color: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Row(
                  children: [
                    Text(
                      'Disciplinas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _createSubject(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Nova disciplina'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        if (subjects.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(onCreate: () => _createSubject(context, ref)),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              showMenu ? 20 : 40,
              0,
              showMenu ? 20 : 40,
              40,
            ),
            sliver: SliverList.separated(
              itemCount: subjects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _SubjectCard(subject: subjects[index]),
            ),
          ),
      ],
    );
  }

  Future<void> _createSubject(BuildContext context, WidgetRef ref) async {
    final draft = await showSubjectDialog(context);
    if (draft == null || !context.mounted) return;
    await _run(
      context,
      () => ref
          .read(studyCatalogProvider.notifier)
          .createSubject(draft.name, draft.difficulty, draft.color),
    );
  }
}

class _SubjectCard extends ConsumerWidget {
  const _SubjectCard({required this.subject});
  final StudySubject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: subject.color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.menu_book_rounded, color: subject.color),
      ),
      title: Text(subject.name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Wrap(
          spacing: 10,
          runSpacing: 4,
          children: [
            Text(
              '${subject.topics.length} ${subject.topics.length == 1 ? 'tópico' : 'tópicos'}',
            ),
            Text('•  ${subject.subtopicCount} subtópicos'),
            _DifficultyBadge(difficulty: subject.difficulty),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<String>(
            tooltip: 'Ações da disciplina',
            onSelected: (value) => _subjectAction(context, ref, value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: AppColors.danger),
                  title: Text('Excluir'),
                ),
              ),
            ],
          ),
          const Icon(Icons.expand_more_rounded),
        ],
      ),
      children: [
        const Divider(color: AppColors.border),
        ...subject.topics.map(
          (topic) => _TopicRow(subject: subject, topic: topic),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _addTopic(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Adicionar tópico'),
          ),
        ),
      ],
    ),
  );

  Future<void> _addTopic(BuildContext context, WidgetRef ref) async {
    final name = await showNameDialog(
      context,
      title: 'Novo tópico',
      label: 'Nome do tópico',
    );
    if (name != null && context.mounted) {
      await _run(
        context,
        () => ref
            .read(studyCatalogProvider.notifier)
            .createTopic(subject.id, name),
      );
    }
  }

  Future<void> _subjectAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (action == 'edit') {
      final draft = await showSubjectDialog(context, subject: subject);
      if (draft != null && context.mounted) {
        await _run(
          context,
          () => ref
              .read(studyCatalogProvider.notifier)
              .updateSubject(
                subject.id,
                name: draft.name,
                difficulty: draft.difficulty,
                color: draft.color,
              ),
        );
      }
    } else if (await confirmDelete(context, subject.name) && context.mounted) {
      await _run(
        context,
        () => ref.read(studyCatalogProvider.notifier).deleteSubject(subject.id),
      );
    }
  }
}

class _TopicRow extends ConsumerWidget {
  const _TopicRow({required this.subject, required this.topic});
  final StudySubject subject;
  final StudyTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    margin: const EdgeInsets.only(top: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: ExpansionTile(
      dense: true,
      shape: const Border(),
      leading: Icon(Icons.folder_outlined, color: subject.color),
      title: Text(
        topic.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      subtitle: Text(
        '${topic.subtopics.length} ${topic.subtopics.length == 1 ? 'subtópico' : 'subtópicos'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Adicionar subtópico',
            onPressed: () => _addSubtopic(context, ref),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _topicAction(context, ref, value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Renomear')),
              PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ],
      ),
      childrenPadding: const EdgeInsets.fromLTRB(18, 0, 12, 12),
      children: [
        if (topic.subtopics.isEmpty)
          const Padding(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Nenhum subtópico ainda.'),
            ),
          ),
        ...topic.subtopics.map((item) => _SubtopicRow(subtopic: item)),
      ],
    ),
  );

  Future<void> _addSubtopic(BuildContext context, WidgetRef ref) async {
    final name = await showNameDialog(
      context,
      title: 'Novo subtópico',
      label: 'Nome do subtópico',
    );
    if (name != null && context.mounted) {
      await _run(
        context,
        () => ref
            .read(studyCatalogProvider.notifier)
            .createSubtopic(topic.id, name),
      );
    }
  }

  Future<void> _topicAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (action == 'edit') {
      final name = await showNameDialog(
        context,
        title: 'Renomear tópico',
        label: 'Nome do tópico',
        initialValue: topic.name,
      );
      if (name != null && context.mounted) {
        await _run(
          context,
          () => ref
              .read(studyCatalogProvider.notifier)
              .updateTopic(topic.id, name),
        );
      }
    } else if (await confirmDelete(context, topic.name) && context.mounted) {
      await _run(
        context,
        () => ref.read(studyCatalogProvider.notifier).deleteTopic(topic.id),
      );
    }
  }
}

class _SubtopicRow extends ConsumerWidget {
  const _SubtopicRow({required this.subtopic});
  final StudySubtopic subtopic;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    dense: true,
    leading: const Icon(
      Icons.circle_outlined,
      size: 16,
      color: AppColors.muted,
    ),
    title: Text(subtopic.name),
    trailing: PopupMenuButton<String>(
      onSelected: (value) => _action(context, ref, value),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Renomear')),
        PopupMenuItem(value: 'delete', child: Text('Excluir')),
      ],
    ),
  );

  Future<void> _action(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (action == 'edit') {
      final name = await showNameDialog(
        context,
        title: 'Renomear subtópico',
        label: 'Nome do subtópico',
        initialValue: subtopic.name,
      );
      if (name != null && context.mounted) {
        await _run(
          context,
          () => ref
              .read(studyCatalogProvider.notifier)
              .updateSubtopic(subtopic.id, name),
        );
      }
    } else if (await confirmDelete(context, subtopic.name) && context.mounted) {
      await _run(
        context,
        () =>
            ref.read(studyCatalogProvider.notifier).deleteSubtopic(subtopic.id),
      );
    }
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.white,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 11),
                  Text(
                    'Foco',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'Visão geral',
              selected: true,
            ),
            const _NavItem(
              icon: Icons.menu_book_outlined,
              label: 'Disciplinas',
            ),
            const _NavItem(
              icon: Icons.calendar_month_outlined,
              label: 'Planejamento',
              soon: true,
            ),
            const _NavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Progresso',
              soon: true,
            ),
            const Spacer(),
            const Divider(color: AppColors.border),
            const _NavItem(
              icon: Icons.settings_outlined,
              label: 'Configurações',
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.soon = false,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final bool soon;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 5),
    decoration: BoxDecoration(
      color: selected ? AppColors.primarySoft : null,
      borderRadius: BorderRadius.circular(11),
    ),
    child: ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: selected ? AppColors.primary : AppColors.muted,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.muted,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: soon
          ? const Text(
              'em breve',
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            )
          : null,
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 180,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Text(label),
          ],
        ),
      ],
    ),
  );
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: difficulty.color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      difficulty.label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: difficulty.color,
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              size: 42,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Comece pela primeira disciplina',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Depois, adicione tópicos e subtópicos no mesmo lugar.'),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Criar disciplina'),
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.muted),
          const SizedBox(height: 16),
          Text(
            'Não foi possível conectar',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _run(
  BuildContext context,
  Future<void> Function() operation,
) async {
  try {
    await operation();
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(error)),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

String _friendlyError(Object error) {
  if (error is DioException && error.type == DioExceptionType.connectionError) {
    return 'A API não está disponível. Inicie os serviços com Docker e tente novamente.';
  }
  if (error is DioException && error.response?.data is Map) {
    return (error.response!.data as Map)['error']?.toString() ??
        'Não foi possível concluir a operação.';
  }
  return 'Não foi possível concluir a operação. Tente novamente.';
}
