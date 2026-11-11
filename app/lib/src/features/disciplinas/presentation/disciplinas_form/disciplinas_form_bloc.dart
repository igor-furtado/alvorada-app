import 'package:bloc/bloc.dart';

import '../../../../core/domain/resultado.dart';
import '../../domain/models/disciplina_input.dart';
import '../../domain/use_cases/create_disciplina_use_case.dart';
import '../../domain/use_cases/disciplinas_resultado_codes.dart';
import '../../domain/use_cases/update_disciplina_use_case.dart';
import 'disciplinas_form_event.dart';
import 'disciplinas_form_state.dart';

class DisciplinasFormBloc extends Bloc<DisciplinasFormEvent, DisciplinasFormState> {
  DisciplinasFormBloc({
    required this.createDisciplina,
    required this.updateDisciplina,
    this.disciplineId,
  }) : super(const DisciplinasFormState()) {
    on<DisciplinasFormSubmitted>(_onSubmitted);
  }

  final CreateDisciplinaUseCase createDisciplina;
  final UpdateDisciplinaUseCase updateDisciplina;
  final String? disciplineId;

  Future<void> _onSubmitted(
    DisciplinasFormSubmitted event,
    Emitter<DisciplinasFormState> emit,
  ) async {
    if (state.status == DisciplinasFormStatus.submitting) return;
    emit(const DisciplinasFormState(status: DisciplinasFormStatus.submitting));
    final id = disciplineId;
    if (id == null) {
      _emitResult(
        await createDisciplina(CreateDisciplinaInput(name: event.name)),
        emit,
      );
      return;
    }
    _emitResult(
      await updateDisciplina(id, UpdateDisciplinaInput(name: event.name)),
      emit,
    );
  }

  void _emitResult<T>(
    Resultado<T> result,
    Emitter<DisciplinasFormState> emit,
  ) {
    switch (result) {
      case Sucesso<T>():
        emit(const DisciplinasFormState(status: DisciplinasFormStatus.success));
      case FalhaTecnica<T>(
        codigo: DisciplinasResultadoCodes.sincronizacaoPendente,
      ):
        emit(const DisciplinasFormState(status: DisciplinasFormStatus.success));
      case ViolacaoRegra<T>(:final mensagem):
        emit(
          DisciplinasFormState(
            status: DisciplinasFormStatus.failure,
            errorMessage: mensagem,
          ),
        );
      case FalhaTecnica<T>(:final mensagem):
        emit(
          DisciplinasFormState(
            status: DisciplinasFormStatus.failure,
            errorMessage: mensagem ?? 'Não foi possível salvar a Disciplina. Tente novamente.',
          ),
        );
    }
  }
}
