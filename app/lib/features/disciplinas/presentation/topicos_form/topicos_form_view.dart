import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/disciplina_input.dart';
import '../../domain/use_cases/disciplinas_use_cases.dart';
import '../disciplinas_localizations.dart';
import '../topicos_list/topicos_list_state.dart';
import 'topicos_form_bloc.dart';
import 'topicos_form_event.dart';
import 'topicos_form_state.dart';

class TopicosFormView extends StatelessWidget {
  const TopicosFormView({
    required this.disciplineId,
    required this.disciplineName,
    required this.topics,
    super.key,
  });

  final String disciplineId;
  final String disciplineName;
  final List<TopicoListItemData> topics;

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<DisciplinasUseCases>();
    return BlocProvider(
      create: (_) => TopicosFormBloc(
        replaceTopicos: useCases.replaceTopicos,
        disciplineId: disciplineId,
      ),
      child: _TopicosFormContent(
        disciplineName: disciplineName,
        topics: topics,
      ),
    );
  }
}

class _TopicosFormContent extends StatefulWidget {
  const _TopicosFormContent({required this.disciplineName, required this.topics});

  final String disciplineName;
  final List<TopicoListItemData> topics;

  @override
  State<_TopicosFormContent> createState() => _TopicosFormContentState();
}

class _TopicosFormContentState extends State<_TopicosFormContent> {
  final _newTopicsController = TextEditingController();
  final _newTopicsFocus = FocusNode();
  late final List<_TopicDraft> _drafts = widget.topics
      .where((topic) => !topic.mandatory)
      .map(_TopicDraft.fromTopic)
      .toList();

  List<TopicoListItemData> get _mandatoryTopics =>
      widget.topics.where((topic) => topic.mandatory).toList(growable: false);

  List<String> get _newTopicNames => _parseTopicNames(_newTopicsController.text);

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    _newTopicsController.dispose();
    _newTopicsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<TopicosFormBloc, TopicosFormState>(
    listenWhen: (previous, current) => previous.status != current.status && current.status == TopicosFormStatus.success,
    listener: (context, state) => Navigator.pop(context, true),
    builder: (context, state) => AppForm(
      firstInvalidFocusNode: () => _drafts.isEmpty ? _newTopicsFocus : _drafts.first.focus,
      onSubmit: _submit,
      contentBuilder: (context, submitting, submit) => [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.existingTopics, style: context.tokens.typography.controlLabel),
            SizedBox(height: context.tokens.spacing.sm),
            if (_drafts.isEmpty)
              _EmptyTopicsMessage(message: context.l10n.noEditableTopics)
            else
              for (var index = 0; index < _drafts.length; index++)
                _EditableTopicRow(
                  key: ValueKey(_drafts[index].id),
                  index: index,
                  draft: _drafts[index],
                  enabled: !submitting,
                  onRemove: () => _removeDraft(index),
                ),
            for (final topic in _mandatoryTopics) _MandatoryTopicRow(topic: topic),
            SizedBox(height: context.tokens.spacing.xxl),
            AppField(
              label: context.l10n.newTopics,
              description: context.l10n.newTopicsDescription,
              control: AppTextarea(
                controller: _newTopicsController,
                focusNode: _newTopicsFocus,
                placeholder: context.l10n.topicsPerLineExample,
                minLines: 4,
                maxLines: 8,
                enabled: !submitting,
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(height: context.tokens.spacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.preview,
                    style: context.tokens.typography.catalogOverline,
                  ),
                ),
                Text(
                  context.l10n.itemsCount(_newTopicNames.length),
                  style: context.tokens.typography.supportingText,
                ),
              ],
            ),
            SizedBox(height: context.tokens.spacing.sm),
            if (_newTopicNames.isEmpty)
              _EmptyTopicsMessage(message: context.l10n.topicsPreviewEmpty)
            else
              for (var index = 0; index < _newTopicNames.length; index++)
                _TopicPreviewRow(
                  index: _drafts.length + index,
                  name: _newTopicNames[index],
                ),
            if (state.errorCode != null) ...[
              SizedBox(height: context.tokens.spacing.sm),
              Text(
                context.l10n.topicFormError(state.errorCode),
                style: context.tokens.typography.errorText,
              ),
            ],
          ],
        ),
      ],
      builder: (context, submitting, submit, content) => AppDrawer(
        eyebrow: widget.disciplineName.toUpperCase(),
        title: context.l10n.editTopics,
        description: context.l10n.editTopicsDescription,
        dismissible: !submitting,
        scrollable: true,
        footer: Container(
          padding: EdgeInsets.all(context.tokens.spacing.xxl),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.tokens.colors.border)),
          ),
          child: AppButton(
            label: context.l10n.saveChanges,
            onPressed: submitting ? null : submit,
            loading: submitting,
          ),
        ),
        child: content,
      ),
    ),
  );

  void _removeDraft(int index) {
    _drafts.removeAt(index).dispose();
    setState(() {});
  }

  Future<void> _submit() async {
    final topics = [
      for (final draft in _drafts) ReplaceTopicoInput(id: draft.id, name: draft.controller.text),
      for (final name in _newTopicNames) ReplaceTopicoInput(name: name),
    ];
    final bloc = context.read<TopicosFormBloc>()..add(TopicosFormSubmitted(topics));
    await bloc.stream.firstWhere(
      (state) => state.status == TopicosFormStatus.success || state.status == TopicosFormStatus.failure,
    );
  }
}

class _TopicPreviewRow extends StatelessWidget {
  const _TopicPreviewRow({required this.index, required this.name});

  final int index;
  final String name;

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: context.tokens.spacing.sm),
    padding: EdgeInsets.symmetric(
      horizontal: context.tokens.spacing.md,
      vertical: context.tokens.spacing.sm,
    ),
    decoration: BoxDecoration(
      color: context.tokens.colors.surfaceSubtle,
      borderRadius: context.tokens.borders.lg,
    ),
    child: Row(
      children: [
        SizedBox(
          width: context.tokens.spacing.xxl,
          child: Text(
            '${index + 1}'.padLeft(2, '0'),
            style: context.tokens.typography.labelMedium,
          ),
        ),
        SizedBox(width: context.tokens.spacing.sm),
        Expanded(
          child: Text(name, style: context.tokens.typography.contentTitle),
        ),
      ],
    ),
  );
}

class _EditableTopicRow extends StatelessWidget {
  const _EditableTopicRow({
    required this.index,
    required this.draft,
    required this.enabled,
    required this.onRemove,
    super.key,
  });

  final int index;
  final _TopicDraft draft;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: context.tokens.spacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.tokens.spacing.xxl,
          height: context.tokens.layout.inputHeight,
          child: Center(
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: context.tokens.typography.labelMedium,
            ),
          ),
        ),
        SizedBox(width: context.tokens.spacing.sm),
        Expanded(
          child: AppTextInput(
            controller: draft.controller,
            focusNode: draft.focus,
            enabled: enabled,
            validator: (value) => value == null || value.trim().isEmpty ? context.l10n.requiredField : null,
            semanticLabel: context.l10n.topicNumber(index + 1),
          ),
        ),
        SizedBox(width: context.tokens.spacing.xs),
        AppAccessibleIconButton(
          icon: AppIcons.delete,
          label: context.l10n.removeItem(draft.controller.text),
          onPressed: enabled ? onRemove : null,
        ),
      ],
    ),
  );
}

class _MandatoryTopicRow extends StatelessWidget {
  const _MandatoryTopicRow({required this.topic});

  final TopicoListItemData topic;

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: context.tokens.spacing.sm),
    padding: EdgeInsets.symmetric(
      horizontal: context.tokens.spacing.md,
      vertical: context.tokens.spacing.sm,
    ),
    decoration: BoxDecoration(
      color: context.tokens.colors.surfaceSubtle,
      borderRadius: context.tokens.borders.lg,
    ),
    child: Row(
      children: [
        const Icon(AppIcons.lockedTopic, size: 17),
        SizedBox(width: context.tokens.spacing.sm),
        Expanded(child: Text(topic.name, style: context.tokens.typography.contentTitle)),
        Text(context.l10n.protected, style: context.tokens.typography.supportingText),
      ],
    ),
  );
}

class _EmptyTopicsMessage extends StatelessWidget {
  const _EmptyTopicsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.lg),
    decoration: BoxDecoration(
      color: context.tokens.colors.surfaceSubtle,
      borderRadius: context.tokens.borders.lg,
    ),
    child: Text(message, style: context.tokens.typography.supportingText),
  );
}

class _TopicDraft {
  _TopicDraft({required this.id, required String name})
    : controller = TextEditingController(text: name),
      focus = FocusNode();

  factory _TopicDraft.fromTopic(TopicoListItemData topic) => _TopicDraft(id: topic.id, name: topic.name);

  final String id;
  final TextEditingController controller;
  final FocusNode focus;

  void dispose() {
    controller.dispose();
    focus.dispose();
  }
}

List<String> _parseTopicNames(String value) {
  final seen = <String>{};
  return value
      .split(RegExp(r'[\r\n]+'))
      .map((name) => name.trim().replaceFirst(RegExp(r'^[\d\-\u2022.)\s]+'), ''))
      .where((name) => name.isNotEmpty && seen.add(name.toLowerCase()))
      .toList(growable: false);
}
