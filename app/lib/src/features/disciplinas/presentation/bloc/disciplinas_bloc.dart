import 'package:bloc/bloc.dart';

import '../../domain/repositories/disciplinas_repository.dart';
import '../../domain/use_cases/create_disciplina_use_case.dart';
import 'disciplinas_event.dart';
import 'disciplinas_state.dart';

class DisciplinasBloc extends Bloc<DisciplinasEvent, DisciplinasState> {
  DisciplinasBloc({required DisciplinasRepository repository})
    : _repository = repository,
      _createDisciplina = CreateDisciplinaUseCase(repository),
      super(DisciplinasState()) {
    on<LoadDisciplinasRequested>(_onLoadRequested);
    on<RefreshDisciplinasRequested>(_onRefreshRequested);
    on<SearchDisciplinasChanged>(_onSearchChanged);
    on<ToggleTopicoRequested>(_onToggleTopico);
    on<CreateDisciplinaRequested>(_onCreateDisciplina);
    on<UpdateDisciplinaRequested>(_onUpdateDisciplina);
    on<DeleteDisciplinaRequested>(_onDeleteDisciplina);
    on<CreateTopicoRequested>(_onCreateTopico);
    on<UpdateTopicoRequested>(_onUpdateTopico);
    on<DeleteTopicoRequested>(_onDeleteTopico);
    on<CreateSubtopicoRequested>(_onCreateSubtopico);
    on<UpdateSubtopicoRequested>(_onUpdateSubtopico);
    on<DeleteSubtopicoRequested>(_onDeleteSubtopico);
  }

  final DisciplinasRepository _repository;
  final CreateDisciplinaUseCase _createDisciplina;

  Future<void> _onLoadRequested(
    LoadDisciplinasRequested event,
    Emitter<DisciplinasState> emit,
  ) async {
    emit(state.copyWith(status: DisciplinasStatus.loading, feedback: null));
    try {
      final disciplinas = await _repository.getDisciplinas(forceRefresh: true);
      emit(state.copyWith(status: DisciplinasStatus.success, disciplinas: disciplinas));
    } on Object {
      emit(state.copyWith(status: DisciplinasStatus.failure));
    }
  }

  Future<void> _onRefreshRequested(
    RefreshDisciplinasRequested event,
    Emitter<DisciplinasState> emit,
  ) async {
    if (state.isRefreshing || state.isMutating) return;
    emit(state.copyWith(isRefreshing: true, feedback: null));
    try {
      final disciplinas = await _repository.getDisciplinas(forceRefresh: true);
      emit(
        state.copyWith(
          status: DisciplinasStatus.success,
          disciplinas: disciplinas,
          isRefreshing: false,
          feedback: DisciplinasFeedback.disciplinasAtualizadas,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isRefreshing: false,
          feedback: DisciplinasFeedback.atualizacaoFalhou,
        ),
      );
    }
  }

  void _onSearchChanged(SearchDisciplinasChanged event, Emitter<DisciplinasState> emit) {
    emit(state.copyWith(query: event.query, feedback: null));
  }

  void _onToggleTopico(ToggleTopicoRequested event, Emitter<DisciplinasState> emit) {
    final expanded = {...state.expandedTopicIds};
    if (!expanded.add(event.topicId)) expanded.remove(event.topicId);
    emit(state.copyWith(expandedTopicIds: expanded, feedback: null));
  }

  Future<void> _onCreateDisciplina(
    CreateDisciplinaRequested event,
    Emitter<DisciplinasState> emit,
  ) => _mutate(
    emit,
    () async => _createDisciplina(event.input),
    DisciplinasFeedback.disciplinaCriada,
  );

  Future<void> _onUpdateDisciplina(
    UpdateDisciplinaRequested event,
    Emitter<DisciplinasState> emit,
  ) => _mutate(
    emit,
    () => _repository.updateDisciplina(event.disciplineId, event.input),
    DisciplinasFeedback.disciplinaAtualizada,
  );

  Future<void> _onDeleteDisciplina(
    DeleteDisciplinaRequested event,
    Emitter<DisciplinasState> emit,
  ) => _mutate(
    emit,
    () => _repository.deleteDisciplina(event.disciplineId),
    DisciplinasFeedback.disciplinaExcluida,
  );

  Future<void> _onCreateTopico(CreateTopicoRequested event, Emitter<DisciplinasState> emit) => _mutate(
    emit,
    () => _repository.createTopico(disciplineId: event.disciplineId, name: event.name),
    DisciplinasFeedback.topicoCriado,
  );

  Future<void> _onUpdateTopico(UpdateTopicoRequested event, Emitter<DisciplinasState> emit) => _mutate(
    emit,
    () => _repository.updateTopico(topicId: event.topicId, name: event.name),
    DisciplinasFeedback.topicoAtualizado,
  );

  Future<void> _onDeleteTopico(DeleteTopicoRequested event, Emitter<DisciplinasState> emit) => _mutate(
    emit,
    () => _repository.deleteTopico(event.topicId),
    DisciplinasFeedback.topicoExcluido,
  );

  Future<void> _onCreateSubtopico(
    CreateSubtopicoRequested event,
    Emitter<DisciplinasState> emit,
  ) => _mutate(
    emit,
    () => _repository.createSubtopico(topicId: event.topicId, name: event.name),
    DisciplinasFeedback.subtopicoCriado,
    expandTopicId: event.topicId,
  );

  Future<void> _onUpdateSubtopico(
    UpdateSubtopicoRequested event,
    Emitter<DisciplinasState> emit,
  ) => _mutate(
    emit,
    () => _repository.updateSubtopico(subtopicId: event.subtopicId, name: event.name),
    DisciplinasFeedback.subtopicoAtualizado,
  );

  Future<void> _onDeleteSubtopico(
    DeleteSubtopicoRequested event,
    Emitter<DisciplinasState> emit,
  ) => _mutate(
    emit,
    () => _repository.deleteSubtopico(event.subtopicId),
    DisciplinasFeedback.subtopicoExcluido,
  );

  Future<void> _mutate(
    Emitter<DisciplinasState> emit,
    Future<Object?> Function() operation,
    DisciplinasFeedback successFeedback, {
    String? expandTopicId,
  }) async {
    if (state.isMutating || state.isRefreshing) return;
    emit(state.copyWith(isMutating: true, feedback: null));
    try {
      await operation();
      final disciplinas = await _repository.getDisciplinas();
      final expanded = {...state.expandedTopicIds};
      if (expandTopicId != null) expanded.add(expandTopicId);
      emit(
        state.copyWith(
          status: DisciplinasStatus.success,
          disciplinas: disciplinas,
          expandedTopicIds: expanded,
          isMutating: false,
          feedback: successFeedback,
        ),
      );
    } on DisciplinasSynchronizationException {
      emit(
        state.copyWith(
          isMutating: false,
          feedback: DisciplinasFeedback.sincronizacaoPendente,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isMutating: false,
          feedback: DisciplinasFeedback.operacaoFalhou,
        ),
      );
    }
  }
}
