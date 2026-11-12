import 'package:bloc/bloc.dart';

import '../../../../core/domain/resultado.dart';
import '../../domain/models/concurso_input.dart';
import '../../domain/use_cases/concursos_resultado_codes.dart';
import '../../domain/use_cases/create_concurso_use_case.dart';
import '../../domain/use_cases/update_concurso_use_case.dart';
import 'concursos_form_event.dart';
import 'concursos_form_state.dart';

class ConcursosFormBloc extends Bloc<ConcursosFormEvent, ConcursosFormState> {
  ConcursosFormBloc({
    required this.createConcurso,
    required this.updateConcurso,
    this.concursoId,
  }) : super(const ConcursosFormState()) {
    on<ConcursosFormSubmitted>(_onSubmitted);
  }

  final CreateConcursoUseCase createConcurso;
  final UpdateConcursoUseCase updateConcurso;
  final String? concursoId;

  Future<void> _onSubmitted(
    ConcursosFormSubmitted event,
    Emitter<ConcursosFormState> emit,
  ) async {
    if (state.status == ConcursosFormStatus.submitting) return;
    emit(const ConcursosFormState(status: ConcursosFormStatus.submitting));
    final id = concursoId;
    if (id == null) {
      _emitResult(
        await createConcurso(
          CreateConcursoInput(
            instituicao: event.instituicao,
            cargo: event.cargo,
            banca: event.banca,
            dataProva: event.dataProva,
            prioritario: event.prioritario,
            sigla: event.sigla,
            quantidadeVagas: event.quantidadeVagas,
            vencimentoCentavos: event.vencimentoCentavos,
            cargaHorariaSemanal: event.cargaHorariaSemanal,
            localProva: event.localProva,
            horarioInicioProva: event.horarioInicioProva,
            horarioFimProva: event.horarioFimProva,
            requisitos: event.requisitos,
            criteriosPontuacao: event.criteriosPontuacao,
          ),
        ),
        emit,
      );
      return;
    }
    _emitResult(
      await updateConcurso(
        id,
        UpdateConcursoInput(
          instituicao: event.instituicao,
          cargo: event.cargo,
          banca: event.banca,
          dataProva: event.dataProva,
          prioritario: event.prioritario,
          sigla: event.sigla,
          quantidadeVagas: event.quantidadeVagas,
          vencimentoCentavos: event.vencimentoCentavos,
          cargaHorariaSemanal: event.cargaHorariaSemanal,
          localProva: event.localProva,
          horarioInicioProva: event.horarioInicioProva,
          horarioFimProva: event.horarioFimProva,
          requisitos: event.requisitos,
          criteriosPontuacao: event.criteriosPontuacao,
        ),
      ),
      emit,
    );
  }

  void _emitResult<T>(
    Resultado<T> result,
    Emitter<ConcursosFormState> emit,
  ) {
    switch (result) {
      case Sucesso<T>():
        emit(const ConcursosFormState(status: ConcursosFormStatus.success));
      case ViolacaoRegra<T>(:final mensagem):
        emit(
          ConcursosFormState(
            status: ConcursosFormStatus.failure,
            errorMessage: mensagem,
          ),
        );
      case FalhaTecnica<T>(
        codigo: ConcursosResultadoCodes.sincronizacaoPendente,
      ):
        emit(const ConcursosFormState(status: ConcursosFormStatus.success));
      case FalhaTecnica<T>(:final mensagem):
        emit(
          ConcursosFormState(
            status: ConcursosFormStatus.failure,
            errorMessage: mensagem ?? 'Não foi possível salvar o Concurso. Tente novamente.',
          ),
        );
    }
  }
}
