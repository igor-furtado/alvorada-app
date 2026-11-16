import 'package:bloc/bloc.dart';

import 'package:estudos_app/core/result.dart';

import '../../domain/models/disciplina.dart';
import '../../domain/use_cases/delete_topico_use_case.dart';
import '../../domain/use_cases/disciplinas_resultado_codes.dart';
import '../../domain/use_cases/get_disciplinas_use_case.dart';
import '../../domain/use_cases/reorder_topicos_use_case.dart';
import 'topicos_list_event.dart';
import 'topicos_list_state.dart';

class TopicosListBloc extends Bloc<TopicosListEvent, TopicosListState> {
  TopicosListBloc({
    required this.getDisciplinas,
    required this.deleteTopico,
    required this.reorderTopicos,
  }) : super(TopicosListState()) {
    on<TopicosListDisciplineChanged>(_onDisciplineChanged);
    on<TopicosListRefreshRequested>(_onRefresh);
    on<TopicosListDeleteRequested>(_onDelete);
    on<TopicosListReorderRequested>(_onReorder);
  }

  final GetDisciplinasUseCase getDisciplinas;
  final DeleteTopicoUseCase deleteTopico;
  final ReorderTopicosUseCase reorderTopicos;

  Future<void> _onDisciplineChanged(
    TopicosListDisciplineChanged event,
    Emitter<TopicosListState> emit,
  ) async {
    final id = event.disciplineId;
    if (id == null) {
      emit(TopicosListState());
      return;
    }
    emit(TopicosListState(status: TopicosListStatus.loading, disciplineId: id));
    await _load(emit, disciplineId: id);
  }

  Future<void> _onRefresh(
    TopicosListRefreshRequested event,
    Emitter<TopicosListState> emit,
  ) async {
    final id = state.disciplineId;
    if (id == null || state.isDeleting || state.isReordering) return;
    emit(
      TopicosListState(
        status: state.status,
        disciplineId: id,
        items: state.items,
        isDeleting: state.isDeleting,
        isReordering: state.isReordering,
      ),
    );
    await _load(
      emit,
      disciplineId: id,
      feedback: event.feedback,
    );
  }

  Future<void> _onDelete(
    TopicosListDeleteRequested event,
    Emitter<TopicosListState> emit,
  ) async {
    final id = state.disciplineId;
    if (id == null || state.isDeleting || state.isReordering) return;
    emit(
      TopicosListState(
        status: state.status,
        disciplineId: id,
        items: state.items,
        isDeleting: true,
      ),
    );
    final result = await deleteTopico(event.topicId);
    switch (result) {
      case Sucesso<void>():
        await _load(
          emit,
          disciplineId: id,
          feedback: TopicosListFeedback.deleted,
        );
      case FalhaTecnica<void>(
        codigo: DisciplinasResultadoCodes.sincronizacaoPendente,
      ):
        emit(_failureState(TopicosListFeedback.synchronizationPending));
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        emit(_failureState(TopicosListFeedback.operationFailed));
    }
  }

  Future<void> _onReorder(
    TopicosListReorderRequested event,
    Emitter<TopicosListState> emit,
  ) async {
    final disciplineId = state.disciplineId;
    final originalItems = state.items;
    final regularItems = state.regularItems;
    if (disciplineId == null || !state.canMutate || regularItems.length < 2) return;
    if (event.oldIndex < 0 ||
        event.oldIndex >= regularItems.length ||
        event.newIndex < 0 ||
        event.newIndex >= regularItems.length ||
        event.oldIndex == event.newIndex) {
      return;
    }
    final reordered = [...regularItems];
    final moved = reordered.removeAt(event.oldIndex);
    reordered.insert(event.newIndex, moved);
    final optimisticItems = [...reordered, ...state.mandatoryItems];
    emit(
      TopicosListState(
        status: state.status,
        disciplineId: disciplineId,
        items: optimisticItems,
        isReordering: true,
      ),
    );
    final result = await reorderTopicos(
      disciplineId: disciplineId,
      topicIds: reordered.map((item) => item.id).toList(growable: false),
    );
    switch (result) {
      case Sucesso<void>():
        emit(
          TopicosListState(
            status: TopicosListStatus.success,
            disciplineId: disciplineId,
            items: optimisticItems,
            feedback: TopicosListFeedback.reordered,
          ),
        );
      case FalhaTecnica<void>(
        codigo: DisciplinasResultadoCodes.sincronizacaoPendente,
      ):
        emit(
          TopicosListState(
            status: TopicosListStatus.success,
            disciplineId: disciplineId,
            items: optimisticItems,
            feedback: TopicosListFeedback.synchronizationPending,
          ),
        );
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        emit(
          TopicosListState(
            status: TopicosListStatus.success,
            disciplineId: disciplineId,
            items: originalItems,
            feedback: TopicosListFeedback.operationFailed,
          ),
        );
    }
  }

  Future<void> _load(
    Emitter<TopicosListState> emit, {
    required String disciplineId,
    TopicosListFeedback? feedback,
  }) async {
    final result = await getDisciplinas();
    switch (result) {
      case Sucesso<List<Disciplina>>(:final valor):
        final discipline = valor.where((item) => item.id == disciplineId).firstOrNull;
        if (discipline == null) {
          emit(TopicosListState(status: TopicosListStatus.failure, disciplineId: disciplineId));
          return;
        }
        final items = [
          for (final topic in discipline.topics)
            TopicoListItemData(
              id: topic.id,
              name: topic.name,
              mandatory: topic.mandatory,
            ),
        ];
        emit(
          TopicosListState(
            status: TopicosListStatus.success,
            disciplineId: disciplineId,
            items: items,
            feedback: feedback,
          ),
        );
      case ViolacaoRegra<List<Disciplina>>() || FalhaTecnica<List<Disciplina>>():
        emit(TopicosListState(status: TopicosListStatus.failure, disciplineId: disciplineId));
    }
  }

  TopicosListState _failureState(TopicosListFeedback feedback) => TopicosListState(
    status: state.status,
    disciplineId: state.disciplineId,
    items: state.items,
    isDeleting: false,
    isReordering: false,
    feedback: feedback,
  );
}
