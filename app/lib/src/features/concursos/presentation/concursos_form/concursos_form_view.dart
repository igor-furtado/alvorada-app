import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/models/concurso.dart';
import '../../domain/use_cases/concursos_use_cases.dart';
import '../concurso_formatters.dart';
import 'concursos_form_bloc.dart';
import 'concursos_form_event.dart';
import 'concursos_form_input_formatters.dart';
import 'concursos_form_state.dart';
import 'concursos_form_validators.dart';

class ConcursosFormView extends StatelessWidget {
  const ConcursosFormView({this.concurso, super.key});

  final Concurso? concurso;

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<ConcursosUseCases>();
    return BlocProvider(
      create: (_) => ConcursosFormBloc(
        createConcurso: useCases.createConcurso,
        updateConcurso: useCases.updateConcurso,
        concursoId: concurso?.id,
      ),
      child: _ConcursosFormContent(concurso: concurso),
    );
  }
}

class _ConcursosFormContent extends StatefulWidget {
  const _ConcursosFormContent({required this.concurso});

  final Concurso? concurso;

  @override
  State<_ConcursosFormContent> createState() => _ConcursosFormContentState();
}

class _ConcursosFormContentState extends State<_ConcursosFormContent> {
  late final TextEditingController _instituicao = TextEditingController(
    text: widget.concurso?.instituicao,
  );
  late final TextEditingController _sigla = TextEditingController(
    text: widget.concurso?.sigla,
  );
  late final TextEditingController _cargo = TextEditingController(
    text: widget.concurso?.cargo,
  );
  late final TextEditingController _banca = TextEditingController(
    text: widget.concurso?.banca,
  );
  late final TextEditingController _dataProva = TextEditingController(
    text: formatBrazilianInputDate(widget.concurso?.dataProva),
  );
  late final TextEditingController _quantidadeVagas = TextEditingController(
    text: _integerText(widget.concurso?.quantidadeVagas),
  );
  late final TextEditingController _vencimento = TextEditingController(
    text: formatBrazilianCurrencyInput(widget.concurso?.vencimentoCentavos),
  );
  late final TextEditingController _cargaHoraria = TextEditingController(
    text: _integerText(widget.concurso?.cargaHorariaSemanal),
  );
  late final TextEditingController _localProva = TextEditingController(
    text: widget.concurso?.localProva,
  );
  late final TextEditingController _horarioInicio = TextEditingController(
    text: widget.concurso?.horarioInicioProva,
  );
  late final TextEditingController _horarioFim = TextEditingController(
    text: widget.concurso?.horarioFimProva,
  );
  late final TextEditingController _requisitos = TextEditingController(
    text: widget.concurso?.requisitos,
  );
  late final TextEditingController _criteriosPontuacao = TextEditingController(
    text: widget.concurso?.criteriosPontuacao,
  );
  final _instituicaoFocus = FocusNode();
  final _cargoFocus = FocusNode();
  final _quantidadeVagasFocus = FocusNode();
  final _vencimentoFocus = FocusNode();
  final _cargaHorariaFocus = FocusNode();
  final _dataProvaFocus = FocusNode();
  final _horarioInicioFocus = FocusNode();
  final _horarioFimFocus = FocusNode();
  late RegimeContratacao? _regimeContratacao = widget.concurso?.regimeContratacao;
  late var _prioritario = widget.concurso?.prioritario ?? false;

  @override
  void dispose() {
    _instituicao.dispose();
    _sigla.dispose();
    _cargo.dispose();
    _banca.dispose();
    _dataProva.dispose();
    _quantidadeVagas.dispose();
    _vencimento.dispose();
    _cargaHoraria.dispose();
    _localProva.dispose();
    _horarioInicio.dispose();
    _horarioFim.dispose();
    _requisitos.dispose();
    _criteriosPontuacao.dispose();
    _instituicaoFocus.dispose();
    _cargoFocus.dispose();
    _quantidadeVagasFocus.dispose();
    _vencimentoFocus.dispose();
    _cargaHorariaFocus.dispose();
    _dataProvaFocus.dispose();
    _horarioInicioFocus.dispose();
    _horarioFimFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ConcursosFormBloc, ConcursosFormState>(
    listenWhen: (previous, current) =>
        previous.status != current.status && current.status == ConcursosFormStatus.success,
    listener: (context, state) => Navigator.pop(context, true),
    builder: (context, state) => AppForm(
      firstInvalidFocusNode: () {
        if (_instituicao.text.trim().isEmpty) return _instituicaoFocus;
        if (_cargo.text.trim().isEmpty) return _cargoFocus;
        if (ConcursosFormValidators.nonNegativeInteger(_quantidadeVagas.text) != null) {
          return _quantidadeVagasFocus;
        }
        if (ConcursosFormValidators.remuneration(_vencimento.text) != null) return _vencimentoFocus;
        if (ConcursosFormValidators.weeklyWorkload(_cargaHoraria.text) != null) return _cargaHorariaFocus;
        if (ConcursosFormValidators.examDate(_dataProva.text) != null) return _dataProvaFocus;
        if (ConcursosFormValidators.examTimeRange(_horarioInicio.text, _horarioFim.text) != null) {
          if (!isValidTime(_horarioInicio.text.trim())) return _horarioInicioFocus;
          return _horarioFimFocus;
        }
        return null;
      },
      onSubmit: () async {
        final bloc = context.read<ConcursosFormBloc>()
          ..add(
            ConcursosFormSubmitted(
              instituicao: _instituicao.text,
              cargo: _cargo.text,
              banca: _banca.text,
              dataProva: parseBrazilianDate(_dataProva.text),
              prioritario: _prioritario,
              sigla: _sigla.text,
              regimeContratacao: _regimeContratacao,
              quantidadeVagas: parseOptionalInteger(_quantidadeVagas.text),
              vencimentoCentavos: parseBrazilianCurrency(_vencimento.text),
              cargaHorariaSemanal: parseOptionalInteger(_cargaHoraria.text),
              localProva: _localProva.text,
              horarioInicioProva: _optionalText(_horarioInicio.text),
              horarioFimProva: _optionalText(_horarioFim.text),
              requisitos: _requisitos.text,
              criteriosPontuacao: _criteriosPontuacao.text,
            ),
          );
        await bloc.stream.firstWhere(
          (state) => state.status == ConcursosFormStatus.success || state.status == ConcursosFormStatus.failure,
        );
      },
      contentBuilder: (context, submitting, submit) => [
        if (state.errorMessage != null)
          AppAlert(
            title: state.errorMessage!,
            description: 'Tente novamente em instantes.',
            icon: AppIcons.attention,
            variant: AppAlertVariant.destructive,
          ),
        AppField(
          label: AppMessages.institution,
          required: true,
          control: AppTextInput(
            controller: _instituicao,
            focusNode: _instituicaoFocus,
            autofocus: true,
            validator: ConcursosFormValidators.requiredText,
            semanticLabel: '${AppMessages.institution}, ${AppMessages.requiredSuffix}',
          ),
        ),
        AppField(
          label: AppMessages.organizationAcronym,
          control: AppTextInput(
            controller: _sigla,
            semanticLabel: AppMessages.organizationAcronym,
          ),
        ),
        AppField(
          label: AppMessages.role,
          required: true,
          control: AppTextInput(
            controller: _cargo,
            focusNode: _cargoFocus,
            validator: ConcursosFormValidators.requiredText,
            semanticLabel: '${AppMessages.role}, ${AppMessages.requiredSuffix}',
          ),
        ),
        AppField(
          label: AppMessages.board,
          control: AppTextInput(controller: _banca, semanticLabel: AppMessages.board),
        ),
        AppField(
          label: AppMessages.hiringRegime,
          control: AppCombobox<RegimeContratacao>(
            options: const [
              RegimeContratacao.estatutario,
              RegimeContratacao.celetista,
            ],
            displayStringForOption: (option) => switch (option) {
              RegimeContratacao.estatutario => AppMessages.statutoryHiringRegime,
              RegimeContratacao.celetista => AppMessages.cltHiringRegime,
            },
            value: _regimeContratacao,
            placeholder: AppMessages.hiringRegimePlaceholder,
            semanticLabel: AppMessages.hiringRegime,
            showClear: true,
            disabled: submitting,
            onChanged: (value) => setState(() {
              _regimeContratacao = value;
            }),
          ),
        ),
        AppField(
          label: AppMessages.vacancies,
          control: AppTextInput(
            controller: _quantidadeVagas,
            focusNode: _quantidadeVagasFocus,
            keyboardType: TextInputType.number,
            inputFormatters: [concursoIntegerInputFormatter],
            validator: ConcursosFormValidators.nonNegativeInteger,
            semanticLabel: AppMessages.vacancies,
          ),
        ),
        AppField(
          label: AppMessages.remuneration,
          control: AppTextInput(
            controller: _vencimento,
            focusNode: _vencimentoFocus,
            placeholder: AppMessages.remunerationPlaceholder,
            keyboardType: TextInputType.number,
            inputFormatters: [concursoCurrencyInputFormatter],
            prefixIcon: const _CurrencyPrefix(),
            validator: ConcursosFormValidators.remuneration,
            semanticLabel: AppMessages.remuneration,
          ),
        ),
        AppField(
          label: AppMessages.weeklyWorkload,
          description: AppMessages.weeklyWorkloadHelp,
          control: AppTextInput(
            controller: _cargaHoraria,
            focusNode: _cargaHorariaFocus,
            keyboardType: TextInputType.number,
            inputFormatters: [concursoIntegerInputFormatter],
            validator: ConcursosFormValidators.weeklyWorkload,
            semanticLabel: AppMessages.weeklyWorkload,
          ),
        ),
        AppField(
          label: AppMessages.examDate,
          control: AppTextInput(
            controller: _dataProva,
            focusNode: _dataProvaFocus,
            placeholder: AppMessages.examDatePlaceholder,
            keyboardType: TextInputType.number,
            inputFormatters: [concursoDateInputFormatter],
            validator: ConcursosFormValidators.examDate,
            semanticLabel: AppMessages.examDate,
          ),
        ),
        Row(
          key: const ValueKey('exam-time-fields'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppField(
                label: AppMessages.examStartTime,
                control: AppTextInput(
                  controller: _horarioInicio,
                  focusNode: _horarioInicioFocus,
                  placeholder: AppMessages.timePlaceholder,
                  keyboardType: TextInputType.number,
                  inputFormatters: [concursoTimeInputFormatter],
                  validator: (_) => ConcursosFormValidators.examTimeRange(
                    _horarioInicio.text,
                    _horarioFim.text,
                  ),
                  semanticLabel: AppMessages.examStartTime,
                ),
              ),
            ),
            SizedBox(width: context.tokens.spacing.lg),
            Expanded(
              child: AppField(
                label: AppMessages.examEndTime,
                control: AppTextInput(
                  controller: _horarioFim,
                  focusNode: _horarioFimFocus,
                  placeholder: AppMessages.timePlaceholder,
                  keyboardType: TextInputType.number,
                  inputFormatters: [concursoTimeInputFormatter],
                  validator: (_) => ConcursosFormValidators.examTimeRange(
                    _horarioInicio.text,
                    _horarioFim.text,
                  ),
                  semanticLabel: AppMessages.examEndTime,
                ),
              ),
            ),
          ],
        ),
        AppField(
          label: AppMessages.examLocation,
          control: AppTextInput(
            controller: _localProva,
            semanticLabel: AppMessages.examLocation,
          ),
        ),
        AppField(
          label: AppMessages.requirements,
          description: AppMessages.requirementsHelp,
          control: AppTextarea(
            key: const ValueKey('requirements-textarea'),
            controller: _requisitos,
            minLines: 5,
            maxLines: 8,
            semanticLabel: AppMessages.requirements,
          ),
        ),
        AppField(
          label: AppMessages.scoringCriteria,
          description: AppMessages.scoringCriteriaHelp,
          control: AppTextarea(
            key: const ValueKey('scoring-criteria-textarea'),
            controller: _criteriosPontuacao,
            minLines: 5,
            maxLines: 8,
            semanticLabel: AppMessages.scoringCriteria,
          ),
        ),
        AppField(
          label: AppMessages.concursoPrioritarioField,
          description: AppMessages.concursoPrioritarioHelp,
          orientation: AppFieldOrientation.horizontal,
          control: AppCheckbox(
            value: _prioritario,
            semanticLabel: AppMessages.concursoPrioritarioField,
            onChanged: submitting
                ? null
                : (value) => setState(
                    () => _prioritario = value ?? false,
                  ),
          ),
        ),
      ],
      builder: (context, submitting, submit, content) => AppDrawer(
        title: widget.concurso == null ? AppMessages.novoConcurso : AppMessages.editarConcurso,
        description: widget.concurso == null
            ? AppMessages.novoConcursoDescription
            : AppMessages.editarConcursoDescription,
        dismissible: !submitting,
        primaryLabel: widget.concurso == null ? AppMessages.criarConcurso : AppMessages.saveChanges,
        onPrimary: submit,
        loading: submitting,
        child: content,
      ),
    ),
  );
}

class _CurrencyPrefix extends StatelessWidget {
  const _CurrencyPrefix();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: context.tokens.spacing.md, right: context.tokens.spacing.sm),
    child: Align(
      widthFactor: 1,
      heightFactor: 1,
      child: Text(r'R$', style: context.tokens.typography.labelLarge),
    ),
  );
}

String _integerText(int? value) => value?.toString() ?? '';

String? _optionalText(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
