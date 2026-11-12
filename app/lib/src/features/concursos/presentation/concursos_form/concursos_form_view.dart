import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/models/concurso.dart';
import '../../domain/use_cases/concursos_use_cases.dart';
import '../concurso_formatters.dart';
import 'concursos_form_bloc.dart';
import 'concursos_form_event.dart';
import 'concursos_form_state.dart';

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
        if (_validNonNegativeInteger(_quantidadeVagas.text) != null) return _quantidadeVagasFocus;
        if (_validRemuneration(_vencimento.text) != null) return _vencimentoFocus;
        if (_validWeeklyWorkload(_cargaHoraria.text) != null) return _cargaHorariaFocus;
        if (_validDate(_dataProva.text) != null) return _dataProvaFocus;
        if (_validTimeRange(_horarioInicio.text) != null) return _horarioInicioFocus;
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
        AppField(
          label: AppMessages.institution,
          errorText: state.errorMessage,
          required: true,
          control: AppTextInput(
            controller: _instituicao,
            focusNode: _instituicaoFocus,
            errorText: state.errorMessage,
            autofocus: true,
            validator: _required,
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
            validator: _required,
            semanticLabel: '${AppMessages.role}, ${AppMessages.requiredSuffix}',
          ),
        ),
        AppField(
          label: AppMessages.board,
          control: AppTextInput(controller: _banca, semanticLabel: AppMessages.board),
        ),
        AppField(
          label: AppMessages.vacancies,
          control: AppTextInput(
            controller: _quantidadeVagas,
            focusNode: _quantidadeVagasFocus,
            keyboardType: TextInputType.number,
            validator: _validNonNegativeInteger,
            semanticLabel: AppMessages.vacancies,
          ),
        ),
        AppField(
          label: AppMessages.remuneration,
          control: AppTextInput(
            controller: _vencimento,
            focusNode: _vencimentoFocus,
            placeholder: AppMessages.remunerationPlaceholder,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validRemuneration,
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
            validator: _validWeeklyWorkload,
            semanticLabel: AppMessages.weeklyWorkload,
          ),
        ),
        AppField(
          label: AppMessages.examDate,
          control: AppTextInput(
            controller: _dataProva,
            focusNode: _dataProvaFocus,
            placeholder: AppMessages.examDatePlaceholder,
            keyboardType: TextInputType.datetime,
            validator: _validDate,
            semanticLabel: AppMessages.examDate,
          ),
        ),
        AppField(
          label: AppMessages.examStartTime,
          control: AppTextInput(
            controller: _horarioInicio,
            focusNode: _horarioInicioFocus,
            placeholder: AppMessages.timePlaceholder,
            keyboardType: TextInputType.datetime,
            validator: _validTimeRange,
            semanticLabel: AppMessages.examStartTime,
          ),
        ),
        AppField(
          label: AppMessages.examEndTime,
          control: AppTextInput(
            controller: _horarioFim,
            focusNode: _horarioFimFocus,
            placeholder: AppMessages.timePlaceholder,
            keyboardType: TextInputType.datetime,
            validator: _validTimeRange,
            semanticLabel: AppMessages.examEndTime,
          ),
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
          control: AppTextInput(
            controller: _requisitos,
            minLines: 3,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            semanticLabel: AppMessages.requirements,
          ),
        ),
        AppField(
          label: AppMessages.scoringCriteria,
          description: AppMessages.scoringCriteriaHelp,
          control: AppTextInput(
            controller: _criteriosPontuacao,
            minLines: 3,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
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
        dismissible: !submitting,
        primaryLabel: widget.concurso == null ? AppMessages.criarConcurso : AppMessages.saveChanges,
        onPrimary: submit,
        loading: submitting,
        secondaryLabel: AppMessages.cancel,
        onSecondary: submitting ? null : () => Navigator.pop(context),
        child: content,
      ),
    ),
  );

  String? _required(String? value) => value == null || value.trim().isEmpty ? AppMessages.requiredField : null;

  String? _validDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      parseBrazilianDate(value);
      return null;
    } on FormatException {
      return AppMessages.invalidExamDate;
    }
  }

  String? _validNonNegativeInteger(String? value) {
    try {
      final parsed = parseOptionalInteger(value ?? '');
      return parsed != null && parsed > 1000000 ? AppMessages.invalidNonNegativeInteger : null;
    } on FormatException {
      return AppMessages.invalidNonNegativeInteger;
    }
  }

  String? _validWeeklyWorkload(String? value) {
    try {
      final parsed = parseOptionalInteger(value ?? '');
      return parsed != null && (parsed < 1 || parsed > 168) ? AppMessages.invalidWeeklyWorkload : null;
    } on FormatException {
      return AppMessages.invalidWeeklyWorkload;
    }
  }

  String? _validRemuneration(String? value) {
    try {
      parseBrazilianCurrency(value ?? '');
      return null;
    } on FormatException {
      return AppMessages.invalidRemuneration;
    }
  }

  String? _validTimeRange(String? _) {
    final start = _horarioInicio.text.trim();
    final end = _horarioFim.text.trim();
    if (start.isEmpty && end.isEmpty) return null;
    if (start.isEmpty || end.isEmpty || !isValidTime(start) || !isValidTime(end)) {
      return AppMessages.invalidExamTimeRange;
    }
    return end.compareTo(start) > 0 ? null : AppMessages.invalidExamTimeRange;
  }
}

String _integerText(int? value) => value?.toString() ?? '';

String? _optionalText(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
