import 'package:bloc/bloc.dart';

import '../../../../core/domain/resultado.dart';
import '../../domain/models/disciplina.dart';
import '../../domain/use_cases/delete_subtopico_use_case.dart';
import '../../domain/use_cases/disciplinas_resultado_codes.dart';
import '../../domain/use_cases/get_disciplinas_use_case.dart';
import 'subtopicos_list_event.dart';
import 'subtopicos_list_state.dart';

class SubtopicosListBloc extends Bloc<SubtopicosListEvent, SubtopicosListState> {
  SubtopicosListBloc({
    required this.getDisciplinas,
    required this.deleteSubtopico,
  }) : super(SubtopicosListState()) {
    on<SubtopicosListDisciplineChanged>(_onDisciplineChanged);
    on<SubtopicosListRefreshRequested>(_onRefresh);
    on<SubtopicosListDeleteRequested>(_onDelete);
  }

  final GetDisciplinasUseCase getDisciplinas;
  final DeleteSubtopicoUseCase deleteSubtopico;

  Future<void> _onDisciplineChanged(
    SubtopicosListDisciplineChanged event,
    Emitter<SubtopicosListState> emit,
  ) async {
    final id = event.disciplineId;
    if (id == null) {
      emit(SubtopicosListState());
      return;
    }
    emit(SubtopicosListState(status: SubtopicosListStatus.loading, disciplineId: id));
    await _load(emit, disciplineId: id);
  }

  Future<void> _onRefresh(
    SubtopicosListRefreshRequested event,
    Emitter<SubtopicosListState> emit,
  ) async {
    final id = state.disciplineId;
    if (id == null || state.byTopic.values.any((topic) => topic.isDeleting)) {
      return;
    }
    emit(
      SubtopicosListState(
        status: state.status,
        disciplineId: id,
        byTopic: state.byTopic,
      ),
    );
    await _load(emit, disciplineId: id, feedback: event.feedback);
  }

  Future<void> _onDelete(
    SubtopicosListDeleteRequested event,
    Emitter<SubtopicosListState> emit,
  ) async {
    final topicId = _topicIdFor(event.subtopicId);
    final disciplineId = state.disciplineId;
    if (topicId == null || disciplineId == null) return;
    final current = state.topic(topicId)!;
    emit(
      SubtopicosListState(
        status: state.status,
        disciplineId: disciplineId,
        byTopic: {
          ...state.byTopic,
          topicId: SubtopicosTopicState(
            topicId: topicId,
            items: current.items,
            isDeleting: true,
          ),
        },
      ),
    );
    final result = await deleteSubtopico(event.subtopicId);
    switch (result) {
      case Sucesso<void>():
        await _load(
          emit,
          disciplineId: disciplineId,
          feedback: SubtopicosListFeedback.deleted,
        );
      case FalhaTecnica<void>(
        codigo: DisciplinasResultadoCodes.sincronizacaoPendente,
      ):
        emit(_failureState(topicId, SubtopicosListFeedback.synchronizationPending));
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        emit(_failureState(topicId, SubtopicosListFeedback.operationFailed));
    }
  }

  Future<void> _load(
    Emitter<SubtopicosListState> emit, {
    required String disciplineId,
    SubtopicosListFeedback? feedback,
  }) async {
    final result = await getDisciplinas();
    switch (result) {
      case Sucesso<List<Disciplina>>(:final valor):
        final discipline = valor.where((item) => item.id == disciplineId).firstOrNull;
        if (discipline == null) {
          emit(SubtopicosListState(status: SubtopicosListStatus.failure, disciplineId: disciplineId));
          return;
        }
        final byTopic = <String, SubtopicosTopicState>{};
        for (final topic in discipline.topics) {
          final candidate = SubtopicosTopicState(
            topicId: topic.id,
            items: [
              for (final subtopic in topic.subtopics) SubtopicoListItemData(id: subtopic.id, name: subtopic.name),
            ],
          );
          final previous = state.topic(topic.id);
          byTopic[topic.id] = candidate == previous ? previous! : candidate;
        }
        emit(
          SubtopicosListState(
            status: SubtopicosListStatus.success,
            disciplineId: disciplineId,
            byTopic: byTopic,
            feedback: feedback,
          ),
        );
      case ViolacaoRegra<List<Disciplina>>() || FalhaTecnica<List<Disciplina>>():
        emit(SubtopicosListState(status: SubtopicosListStatus.failure, disciplineId: disciplineId));
    }
  }

  SubtopicosListState _failureState(
    String topicId,
    SubtopicosListFeedback feedback,
  ) {
    final current = state.topic(topicId)!;
    return SubtopicosListState(
      status: state.status,
      disciplineId: state.disciplineId,
      byTopic: {
        ...state.byTopic,
        topicId: SubtopicosTopicState(topicId: topicId, items: current.items),
      },
      feedback: feedback,
    );
  }

  String? _topicIdFor(String subtopicId) {
    for (final entry in state.byTopic.entries) {
      if (entry.value.items.any((item) => item.id == subtopicId)) return entry.key;
    }
    return null;
  }
}
