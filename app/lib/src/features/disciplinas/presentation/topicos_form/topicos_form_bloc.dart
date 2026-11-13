import 'package:bloc/bloc.dart';

import '../../../../core/domain/resultado.dart';
import '../../domain/use_cases/create_topicos_use_case.dart';
import '../../domain/use_cases/disciplinas_resultado_codes.dart';
import '../../domain/use_cases/update_topico_use_case.dart';
import 'topicos_form_event.dart';
import 'topicos_form_state.dart';

class TopicosFormBloc extends Bloc<TopicosFormEvent, TopicosFormState> {
  TopicosFormBloc({
    required this.createTopicos,
    required this.updateTopico,
    required this.disciplineId,
    this.topicId,
  }) : super(const TopicosFormState()) {
    on<TopicosFormSubmitted>(_onSubmitted);
  }

  final CreateTopicosUseCase createTopicos;
  final UpdateTopicoUseCase updateTopico;
  final String disciplineId;
  final String? topicId;

  Future<void> _onSubmitted(
    TopicosFormSubmitted event,
    Emitter<TopicosFormState> emit,
  ) async {
    if (state.status == TopicosFormStatus.submitting) return;
    emit(const TopicosFormState(status: TopicosFormStatus.submitting));
    final id = topicId;
    final result = id == null
        ? await createTopicos(disciplineId: disciplineId, names: event.names)
        : await updateTopico(
            topicId: id,
            name: event.names.isEmpty ? '' : event.names.first,
          );
    switch (result) {
      case Sucesso<void>():
        emit(const TopicosFormState(status: TopicosFormStatus.success));
      case ViolacaoRegra<void>(:final mensagem):
        emit(
          TopicosFormState(
            status: TopicosFormStatus.failure,
            errorMessage: mensagem,
          ),
        );
      case FalhaTecnica<void>(
        codigo: DisciplinasResultadoCodes.sincronizacaoPendente,
      ):
        emit(const TopicosFormState(status: TopicosFormStatus.success));
      case FalhaTecnica<void>(:final mensagem):
        emit(
          TopicosFormState(
            status: TopicosFormStatus.failure,
            errorMessage: mensagem ?? 'Não foi possível salvar o Tópico. Tente novamente.',
          ),
        );
    }
  }
}
