import 'package:bloc/bloc.dart';

import '../../../../core/domain/resultado.dart';
import '../../domain/use_cases/create_subtopico_use_case.dart';
import '../../domain/use_cases/disciplinas_resultado_codes.dart';
import '../../domain/use_cases/update_subtopico_use_case.dart';
import 'subtopicos_form_event.dart';
import 'subtopicos_form_state.dart';

class SubtopicosFormBloc extends Bloc<SubtopicosFormEvent, SubtopicosFormState> {
  SubtopicosFormBloc({
    required this.createSubtopico,
    required this.updateSubtopico,
    required this.topicId,
    this.subtopicId,
  }) : super(const SubtopicosFormState()) {
    on<SubtopicosFormSubmitted>(_onSubmitted);
  }

  final CreateSubtopicoUseCase createSubtopico;
  final UpdateSubtopicoUseCase updateSubtopico;
  final String topicId;
  final String? subtopicId;

  Future<void> _onSubmitted(
    SubtopicosFormSubmitted event,
    Emitter<SubtopicosFormState> emit,
  ) async {
    if (state.status == SubtopicosFormStatus.submitting) return;
    emit(const SubtopicosFormState(status: SubtopicosFormStatus.submitting));
    final id = subtopicId;
    final result = id == null
        ? await createSubtopico(topicId: topicId, name: event.name)
        : await updateSubtopico(subtopicId: id, name: event.name);
    switch (result) {
      case Sucesso<void>():
        emit(const SubtopicosFormState(status: SubtopicosFormStatus.success));
      case ViolacaoRegra<void>(:final mensagem):
        emit(
          SubtopicosFormState(
            status: SubtopicosFormStatus.failure,
            errorMessage: mensagem,
          ),
        );
      case FalhaTecnica<void>(
        codigo: DisciplinasResultadoCodes.sincronizacaoPendente,
      ):
        emit(const SubtopicosFormState(status: SubtopicosFormStatus.success));
      case FalhaTecnica<void>(:final mensagem):
        emit(
          SubtopicosFormState(
            status: SubtopicosFormStatus.failure,
            errorMessage: mensagem ?? 'Não foi possível salvar o Subtópico. Tente novamente.',
          ),
        );
    }
  }
}
