import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

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
    this.topico,
    super.key,
  });

  final String disciplineId;
  final String disciplineName;
  final TopicoListItemData? topico;

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<DisciplinasUseCases>();
    return BlocProvider(
      create: (context) => TopicosFormBloc(
        createTopicos: useCases.createTopicos,
        updateTopico: useCases.updateTopico,
        disciplineId: disciplineId,
        topicId: topico?.id,
      ),
      child: _TopicosFormContent(
        disciplineName: disciplineName,
        topico: topico,
      ),
    );
  }
}

class _TopicosFormContent extends StatefulWidget {
  const _TopicosFormContent({
    required this.disciplineName,
    required this.topico,
  });

  final String disciplineName;
  final TopicoListItemData? topico;

  @override
  State<_TopicosFormContent> createState() => _TopicosFormContentState();
}

class _TopicosFormContentState extends State<_TopicosFormContent> {
  final _nameFocus = FocusNode();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.topico?.name,
  );

  List<String> get _names => _parseTopicNames(_nameController.text);

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<TopicosFormBloc, TopicosFormState>(
    listenWhen: (previous, current) => previous.status != current.status && current.status == TopicosFormStatus.success,
    listener: (context, state) => Navigator.pop(context, true),
    builder: (context, state) =>
        widget.topico == null ? _buildQuickTopicsForm(context, state) : _buildEditTopicForm(context, state),
  );

  Widget _buildQuickTopicsForm(
    BuildContext context,
    TopicosFormState state,
  ) => AppForm(
    firstInvalidFocusNode: () => _nameFocus,
    onSubmit: _submit,
    contentBuilder: (context, submitting, submit) => [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.topics, style: context.tokens.typography.controlLabel),
          SizedBox(height: context.tokens.spacing.xs),
          AppTextarea(
            controller: _nameController,
            focusNode: _nameFocus,
            placeholder: context.l10n.topicsPerLineExample,
            errorText: state.errorCode == null ? null : context.l10n.topicFormError(state.errorCode),
            autofocus: true,
            minLines: 6,
            maxLines: 10,
            validator: (value) => _parseTopicNames(value ?? '').isEmpty ? context.l10n.requiredField : null,
            onChanged: (_) => setState(() {}),
            semanticLabel: '${context.l10n.topics}, ${context.l10n.requiredSuffix}',
          ),
          SizedBox(height: context.tokens.spacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _nameController.text.isEmpty
                  ? null
                  : () {
                      _nameController.clear();
                      setState(() {});
                    },
              child: Text(context.l10n.clear),
            ),
          ),
          SizedBox(height: context.tokens.spacing.xl),
          Row(
            children: [
              Expanded(child: Text(context.l10n.preview, style: context.tokens.typography.catalogOverline)),
              Text(
                context.l10n.itemsCount(_names.length),
                style: context.tokens.typography.supportingText,
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.sm),
          if (_names.isEmpty)
            Container(
              padding: EdgeInsets.all(context.tokens.spacing.xl),
              decoration: BoxDecoration(
                color: context.tokens.colors.surfaceSubtle,
                borderRadius: context.tokens.borders.lg,
              ),
              child: Text(
                context.l10n.topicsPreviewEmpty,
                textAlign: TextAlign.center,
                style: context.tokens.typography.supportingText,
              ),
            )
          else
            for (var index = 0; index < _names.length; index++) _TopicPreviewRow(index: index, name: _names[index]),
        ],
      ),
    ],
    builder: (context, submitting, submit, content) => AppDrawer(
      eyebrow: widget.disciplineName.toUpperCase(),
      title: context.l10n.addTopics,
      description: context.l10n.addTopicsQuickDescription,
      dismissible: !submitting,
      scrollable: true,
      footer: Container(
        padding: EdgeInsets.all(context.tokens.spacing.xxl),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.tokens.colors.border)),
        ),
        child: AppButton(
          label: context.l10n.addTopicsCount(_names.length),
          icon: AppIcons.add,
          onPressed: _names.isEmpty ? null : submit,
          loading: submitting,
        ),
      ),
      child: content,
    ),
  );

  Widget _buildEditTopicForm(
    BuildContext context,
    TopicosFormState state,
  ) => AppForm(
    firstInvalidFocusNode: () => _nameFocus,
    onSubmit: _submit,
    contentBuilder: (context, submitting, submit) => [
      AppField(
        label: context.l10n.name,
        errorText: state.errorCode == null ? null : context.l10n.topicFormError(state.errorCode),
        required: true,
        control: AppTextInput(
          controller: _nameController,
          focusNode: _nameFocus,
          errorText: state.errorCode == null ? null : context.l10n.topicFormError(state.errorCode),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => submit(),
          validator: (value) => value == null || value.trim().isEmpty ? context.l10n.requiredField : null,
          semanticLabel: '${context.l10n.name}, ${context.l10n.requiredSuffix}',
        ),
      ),
    ],
    builder: (context, submitting, submit, content) => AppDrawer(
      title: context.l10n.editTopic,
      description: context.l10n.editTopicDescription,
      dismissible: !submitting,
      primaryLabel: context.l10n.saveChanges,
      onPrimary: submit,
      loading: submitting,
      child: content,
    ),
  );

  Future<void> _submit() async {
    final bloc = context.read<TopicosFormBloc>()..add(TopicosFormSubmitted(_names));
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
        Expanded(child: Text(name, style: context.tokens.typography.contentTitle)),
      ],
    ),
  );
}

List<String> _parseTopicNames(String value) {
  final seen = <String>{};
  return value
      .split(RegExp(r'[\r\n]+'))
      .map((name) => name.trim().replaceFirst(RegExp(r'^[\d\-\u2022.)\s]+'), ''))
      .where((name) => name.isNotEmpty && seen.add(name.toLowerCase()))
      .toList(growable: false);
}
