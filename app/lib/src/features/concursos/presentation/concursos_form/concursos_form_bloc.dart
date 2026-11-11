import 'package:bloc/bloc.dart';

import '../../../../core/domain/resultado.dart';
import '../../domain/models/concurso.dart';
import '../../domain/use_cases/concursos_resultado_codes.dart';
import '../../domain/use_cases/create_concurso_use_case.dart';
import 'concursos_form_event.dart';
import 'concursos_form_state.dart';

class ConcursosFormBloc extends Bloc<ConcursosFormEvent, ConcursosFormState> {
  ConcursosFormBloc({required this.createConcurso}) : super(const ConcursosFormState()) {
    on<ConcursosFormSubmitted>(_onSubmitted);
  }

  final CreateConcursoUseCase createConcurso;

  Future<void> _onSubmitted(
    ConcursosFormSubmitted event,
    Emitter<ConcursosFormState> emit,
  ) async {
    if (state.status == ConcursosFormStatus.submitting) return;
    emit(const ConcursosFormState(status: ConcursosFormStatus.submitting));
    final result = await createConcurso(event.input);
    switch (result) {
      case Sucesso<Concurso>():
        emit(const ConcursosFormState(status: ConcursosFormStatus.success));
      case ViolacaoRegra<Concurso>(:final mensagem):
        emit(
          ConcursosFormState(
            status: ConcursosFormStatus.failure,
            errorMessage: mensagem,
          ),
        );
      case FalhaTecnica<Concurso>(
        codigo: ConcursosResultadoCodes.sincronizacaoPendente,
      ):
        emit(const ConcursosFormState(status: ConcursosFormStatus.success));
      case FalhaTecnica<Concurso>(:final mensagem):
        emit(
          ConcursosFormState(
            status: ConcursosFormStatus.failure,
            errorMessage: mensagem ?? 'Não foi possível criar o Concurso. Tente novamente.',
          ),
        );
    }
  }
}
